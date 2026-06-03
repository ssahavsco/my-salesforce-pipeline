global class AOAuthProvider extends Auth.AuthProviderPluginClass {

    public String getCustomMetadataType() {
        return 'LBrands_API_Integration_Setting__mdt';
    }

    public PageReference initiate(Map<String, String> config, String stateToPropagate) {
        String callbackUrl = URL.getOrgDomainUrl().toExternalForm()
            + '/services/authcallback/AOAuthorization';
        return new PageReference(callbackUrl + '?state=' + stateToPropagate);
    }

    public Auth.UserData getUserInfo(Map<String, String> config, Auth.AuthProviderTokenResponse response) {
        return new Auth.UserData(null, null, null, null, null, null, null, null, null, null, null);
    }

    global Auth.AuthProviderTokenResponse handleCallback(Map<String, String> config, Auth.AuthProviderCallbackState state) {
        String accessToken = retrieveToken(config);

        return new Auth.AuthProviderTokenResponse(
            'AOAuthorization',
            accessToken,
            'dummy_refresh_token',
            state.queryParameters.get('state')
        );
    }

    public override Auth.OAuthRefreshResult refresh(Map<String, String> config, String refreshToken) {
        String accessToken = retrieveToken(config);

        return new Auth.OAuthRefreshResult(
            accessToken,
            'dummy_refresh_token'
        );
    }

    private String retrieveToken(Map<String, String> config) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.get('Endpoint__c'));
        req.setMethod(config.get('Request_Method__c'));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        req.setBody(
            'grant_type=password' +
            '&username={!$Credential.AO_Basic_Auth.Username}' +
            '&password={!$Credential.AO_Basic_Auth.Password}'
        );

        HttpResponse resp = new Http().send(req);

        if (resp.getStatusCode() != 200) {
            throw new CalloutException('Token fetch failed: ' + resp.getStatusCode() + ' - ' + resp.getBody());
        }

        Map<String, Object> responseMap =
            (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

        return (String) responseMap.get('access_token');
    }
}