@isTest
private class AOAuthProviderTest {

    // ─────────────────────────────────────────────
    // Mock HTTP callout
    // ─────────────────────────────────────────────
    private class MockHttpSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"mock_access_token_123"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    private class MockHttpFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('Unauthorized');
            return res;
        }
    }

    // ─────────────────────────────────────────────
    // Helper: build config map (mirrors Custom Metadata fields)
    // ─────────────────────────────────────────────
    private static Map<String, String> buildConfig() {
        Map<String, String> config = new Map<String, String>();
        config.put('Endpoint__c',       'https://mock-token-endpoint.example.com/token');
        config.put('Request_Method__c', 'POST');
        return config;
    }

    // ─────────────────────────────────────────────
    // Test: getCustomMetadataType
    // ─────────────────────────────────────────────
    @isTest
    static void testGetCustomMetadataType() {
        AOAuthProvider provider = new AOAuthProvider();

        Test.startTest();
        String mdtName = provider.getCustomMetadataType();
        Test.stopTest();

        System.assertEquals(
            'LBrands_API_Integration_Setting__mdt',
            mdtName,
            'Custom metadata type name should match the expected MDT API name'
        );
    }

    // ─────────────────────────────────────────────
    // Test: initiate — returns PageReference with correct callback URL + state
    // ─────────────────────────────────────────────
    @isTest
    static void testInitiate() {
        AOAuthProvider provider  = new AOAuthProvider();
        Map<String, String> cfg  = buildConfig();
        String stateToPropagate  = 'testStateValue';

        Test.startTest();
        PageReference pageRef = provider.initiate(cfg, stateToPropagate);
        Test.stopTest();

        System.assertNotEquals(null, pageRef, 'initiate() should return a non-null PageReference');

        String url = pageRef.getUrl();
        System.assert(
            url.contains('/services/authcallback/AOAuthorization'),
            'Callback URL should contain the AOAuthorization path. Got: ' + url
        );
        System.assert(
            url.contains('?state=' + stateToPropagate),
            'URL should contain the state parameter. Got: ' + url
        );
    }

    // ─────────────────────────────────────────────
    // Test: getUserInfo — always returns empty Auth.UserData
    // ─────────────────────────────────────────────
    @isTest
    static void testGetUserInfo() {
        AOAuthProvider provider = new AOAuthProvider();
        Map<String, String> cfg = buildConfig();

        Auth.AuthProviderTokenResponse tokenResponse =
            new Auth.AuthProviderTokenResponse('AOAuthorization', 'access_tok', 'refresh_tok', 'state_val');

        Test.startTest();
        Auth.UserData userData = provider.getUserInfo(cfg, tokenResponse);
        Test.stopTest();

        System.assertNotEquals(null, userData, 'getUserInfo() should return a non-null Auth.UserData object');
    }

    // ─────────────────────────────────────────────
    // Test: handleCallback — success path
    // ─────────────────────────────────────────────
    @isTest
    static void testHandleCallback_Success() {
        AOAuthProvider provider = new AOAuthProvider();
        Map<String, String> cfg = buildConfig();

        Map<String, String> queryParams = new Map<String, String>{ 'state' => 'myState' };
        Auth.AuthProviderCallbackState callbackState =
            new Auth.AuthProviderCallbackState(null, null, queryParams);

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();
        Auth.AuthProviderTokenResponse tokenResp = provider.handleCallback(cfg, callbackState);
        Test.stopTest();

        System.assertNotEquals(null, tokenResp, 'handleCallback() should return a non-null token response');
        System.assertEquals('AOAuthorization', tokenResp.provider,      'Provider name should be AOAuthorization');
        System.assertEquals('mock_access_token_123', tokenResp.oauthToken, 'Access token should match mock response');
        System.assertEquals('dummy_refresh_token',   tokenResp.oauthSecretOrRefreshToken, 'Refresh token should be the dummy value');
        System.assertEquals('myState',               tokenResp.state,   'State should be propagated from query params');
    }

    // ─────────────────────────────────────────────
    // Test: handleCallback — HTTP failure throws CalloutException
    // ─────────────────────────────────────────────
    @isTest
    static void testHandleCallback_HttpFailure() {
        AOAuthProvider provider = new AOAuthProvider();
        Map<String, String> cfg = buildConfig();

        Map<String, String> queryParams = new Map<String, String>{ 'state' => 'errorState' };
        Auth.AuthProviderCallbackState callbackState =
            new Auth.AuthProviderCallbackState(null, null, queryParams);

        Test.setMock(HttpCalloutMock.class, new MockHttpFailure());

        Test.startTest();
        try {
            provider.handleCallback(cfg, callbackState);
            System.assert(false, 'Expected a CalloutException to be thrown for non-200 response');
        } catch (CalloutException e) {
            System.assert(
                e.getMessage().contains('Token fetch failed:'),
                'Exception message should contain "Token fetch failed:". Got: ' + e.getMessage()
            );
            System.assert(
                e.getMessage().contains('401'),
                'Exception message should include the HTTP status code 401. Got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    // ─────────────────────────────────────────────
    // Test: refresh — success path
    // ─────────────────────────────────────────────
    @isTest
    static void testRefresh_Success() {
        AOAuthProvider provider = new AOAuthProvider();
        Map<String, String> cfg = buildConfig();

        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());

        Test.startTest();
        Auth.OAuthRefreshResult refreshResult = provider.refresh(cfg, 'existing_refresh_token');
        Test.stopTest();

        System.assertNotEquals(null, refreshResult, 'refresh() should return a non-null OAuthRefreshResult');
        System.assertEquals(
            'mock_access_token_123',
            refreshResult.accessToken,
            'Access token from refresh should match the mock response'
        );
        System.assertEquals(
            'dummy_refresh_token',
            refreshResult.refreshToken,
            'Refresh token should be the static dummy value'
        );
    }

    // ─────────────────────────────────────────────
    // Test: refresh — HTTP failure throws CalloutException
    // ─────────────────────────────────────────────
    @isTest
    static void testRefresh_HttpFailure() {
        AOAuthProvider provider = new AOAuthProvider();
        Map<String, String> cfg = buildConfig();

        Test.setMock(HttpCalloutMock.class, new MockHttpFailure());

        Test.startTest();
        try {
            provider.refresh(cfg, 'stale_refresh_token');
            System.assert(false, 'Expected a CalloutException for non-200 response during refresh');
        } catch (CalloutException e) {
            System.assert(
                e.getMessage().contains('Token fetch failed:'),
                'Exception message should contain "Token fetch failed:". Got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    // ─────────────────────────────────────────────
    // Test: retrieveToken — verifies correct HTTP request construction
    // ─────────────────────────────────────────────
    @isTest
    static void testRetrieveToken_RequestConstruction() {
        AOAuthProvider provider = new AOAuthProvider();
        Map<String, String> cfg = buildConfig();

        // Use a capturing mock to inspect the outbound request
        CapturingMock captor = new CapturingMock();
        Test.setMock(HttpCalloutMock.class, captor);

        Map<String, String> queryParams = new Map<String, String>{ 'state' => 's' };
        Auth.AuthProviderCallbackState callbackState =
            new Auth.AuthProviderCallbackState(null, null, queryParams);

        Test.startTest();
        provider.handleCallback(cfg, callbackState);
        Test.stopTest();

        System.assertEquals(
            'https://mock-token-endpoint.example.com/token',
            captor.capturedRequest.getEndpoint(),
            'Endpoint should be set from Endpoint__c config field'
        );
        System.assertEquals(
            'POST',
            captor.capturedRequest.getMethod(),
            'HTTP method should be POST as per Request_Method__c config field'
        );
        System.assertEquals(
            'application/x-www-form-urlencoded',
            captor.capturedRequest.getHeader('Content-Type'),
            'Content-Type header should be application/x-www-form-urlencoded'
        );

        String body = captor.capturedRequest.getBody();
        System.assert(body.contains('grant_type=password'), 'Request body should contain grant_type=password. Got: ' + body);
        System.assert(body.contains('&username='),          'Request body should contain &username=. Got: ' + body);
        System.assert(body.contains('&password='),          'Request body should contain &password=. Got: ' + body);
    }

    // ─────────────────────────────────────────────
    // Capturing mock for request-construction test
    // ─────────────────────────────────────────────
    private class CapturingMock implements HttpCalloutMock {
        public HttpRequest capturedRequest;

        public HttpResponse respond(HttpRequest req) {
            this.capturedRequest = req;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"captured_token"}');
            return res;
        }
    }
}