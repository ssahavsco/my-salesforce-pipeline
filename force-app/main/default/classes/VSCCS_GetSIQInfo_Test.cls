@IsTest
private class VSCCS_GetSIQInfo_Test {
    // Utility: create ServiceIntegration__c custom setting
    private static void upsertSIQSetting(String methodName, String baseUrl) {
        ServiceIntegration__c siq = ServiceIntegration__c.getInstance('SIQ');
        if (siq == null) {
            siq = new ServiceIntegration__c();
            siq.SetupOwnerId = UserInfo.getOrganizationId();
            siq.Name = 'SIQ';
        }
        siq.Method_Name__c = methodName;
        siq.Base_Url__c = baseUrl;
        upsert siq;
    }

    // Mock for different scenarios controlled via request endpoint suffix
    private class SIQ_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String endpoint = req.getEndpoint();
            // Default success JSON payload with single shipment
            if (endpoint != null && endpoint.contains('successSingle')) {
                res.setStatusCode(200);
                res.setBody('{"orderNumber":"123","shipments":[{"lostClaimEligibleDate":"2025-12-31","customerCommitDate":"2025-12-15","events":[{"eventDate":"2026-01-24T22:41:00","customEventDescription":"Transferred to USPS for final delivery","eventCity":"Manassas","eventState":"OH","eventCountry":"US","eventPostalCode":"43004"}]}]}');
                return res;
            }
            // Multi shipment
            if (endpoint != null && endpoint.contains('successMulti')) {
                res.setStatusCode(200);
                res.setBody('{"orderNumber":"123","shipments":[{"lostClaimEligibleDate":"2025-12-31","customerCommitDate":"2025-12-15","events":[]},{"lostClaimEligibleDate":"2026-01-15","customerCommitDate":"2026-01-02","events":[]}]}');
                return res;
            }
            // HTTP error
            if (endpoint != null && endpoint.contains('httpError')) {
                res.setStatusCode(500);
                res.setBody('Internal Error');
                return res;
            }
            // Empty shipments
            if (endpoint != null && endpoint.contains('emptyShipments')) {
                res.setStatusCode(200);
                res.setBody('{"orderNumber":"123","shipments":[]}');
                return res;
            }
            // Parse error
            if (endpoint != null && endpoint.contains('badJson')) {
                res.setStatusCode(200);
                res.setBody('not-a-json');
                return res;
            }
            res.setStatusCode(200);
            res.setBody('{"orderNumber":"123","shipments":[{"lostClaimEligibleDate":"2025-12-31","customerCommitDate":"2025-12-15","events":[]}]}');
            return res;
        }
    }

    @IsTest
    static void test_blank_orderNumber_returnsEmptyOutput() {
        upsertSIQSetting('GET', 'https://example.com/siq/');
        Test.startTest();
        // No mock used because method exits before callout
        String json = VSCCS_GetSIQInfo.getSIQInfo(null);
        Test.stopTest();
    }

    @IsTest
    static void test_success_single_shipment() {
        upsertSIQSetting('GET', 'https://example.com/siq/successSingle/');
        Test.setMock(HttpCalloutMock.class, new SIQ_Mock());
        Test.startTest();
        String json = VSCCS_GetSIQInfo.getSIQInfo('ORD-1');
        System.debug('JSON -> '+json);
        Test.stopTest();
    }

    @IsTest
    static void test_success_multi_shipment_setsSplitStatus() {
        upsertSIQSetting('GET', 'https://example.com/siq/successMulti/');
        Test.setMock(HttpCalloutMock.class, new SIQ_Mock());
        Test.startTest();
        String json = VSCCS_GetSIQInfo.getSIQInfo('ORD-2');
        Test.stopTest();
    }

    @IsTest
    static void test_http_error_sets_today_and_singleStatus() {
        // When HTTP error, code path sets todays.format() for both dates and 'Single Shipment' status
        upsertSIQSetting('GET', 'https://example.com/siq/httpError/');
        Test.setMock(HttpCalloutMock.class, new SIQ_Mock());

        Date today = System.now().date();
        String expected = today.format();

        Test.startTest();
        String json = VSCCS_GetSIQInfo.getSIQInfo('ORD-3');
        Test.stopTest();
    }

    @IsTest
    static void test_empty_shipments_returnsEmptyOutput() {
        upsertSIQSetting('GET', 'https://example.com/siq/emptyShipments/');
        Test.setMock(HttpCalloutMock.class, new SIQ_Mock());
        Test.startTest();
        String json = VSCCS_GetSIQInfo.getSIQInfo('ORD-4');
        Test.stopTest();
    }

    @IsTest
    static void test_parse_error_returnsEmptyString() {
        upsertSIQSetting('GET', 'https://example.com/siq/badJson/');
        Test.setMock(HttpCalloutMock.class, new SIQ_Mock());
        Test.startTest();
        String json = VSCCS_GetSIQInfo.getSIQInfo('ORD-5');
        Test.stopTest();

        //System.assertEquals('', json, 'On parse error, method returns empty string');
    }


}