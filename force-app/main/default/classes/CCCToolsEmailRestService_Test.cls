/*
***********************************************************************************************************
* Program Name      : CCCToolsEmailRestService_Test
* Description       : Test class for CCCToolsEmailRestService covering GET, POST, PUT, DELETE
*                     with all status code branches (200, 400, 404, 500, 503, and other).
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01                        1.0                             2021            Created Test class.
***********************************************************************************************************
*/
@isTest
public class CCCToolsEmailRestService_Test {

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Inner mock class that returns a configurable status code and body
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ServiceMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public ServiceMock( Integer statusCode, String responseBody ) {
            this.statusCode   = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond( HTTPRequest req ) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode( statusCode );
            res.setBody( responseBody );
            return res;
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Helper: build a fake LBrands_API_Integration_Setting__mdt record
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static LBrands_API_Integration_Setting__mdt buildMetadata() {
        return ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
            '{ "Active__c": true,' +
            '  "Endpoint__c": "https://apitest.victoriassecret.com/ccc/v5/customer",' +
            '  "Status_Code_200_Message__c": "Success",' +
            '  "Status_Code_400_Message__c": "Bad Request",' +
            '  "Status_Code_404_Message__c": "Not Found",' +
            '  "Status_Code_500_Message__c": "Internal Server Error",' +
            '  "Status_Code_503_Message__c": "Service Unavailable" }',
            LBrands_API_Integration_Setting__mdt.class
        );
    }


    // ─── authenticate / doPut / doDelete (coverage for stub methods) ─────────────

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Calling stub methods for coverage
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testAuthenticate() {
        CCCToolsEmailRestService service = new CCCToolsEmailRestService();
        service.endPointMetadataObj = buildMetadata();
        Test.startTest();
            service.authenticate();
        Test.stopTest();
        // No assertion required – method body is intentionally empty
    }

    @isTest
    static void testDoPut() {
        CCCToolsEmailRestService service = new CCCToolsEmailRestService();
        service.endPointMetadataObj = buildMetadata();
        Test.startTest();
            RestResponse response = service.doPut( new PostRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
    }

    @isTest
    static void testDoDelete() {
        CCCToolsEmailRestService service = new CCCToolsEmailRestService();
        service.endPointMetadataObj = buildMetadata();
        Test.startTest();
            RestResponse response = service.doDelete( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
    }


    // ─── doGet ───────────────────────────────────────────────────────────────────

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * GET – 200 success: response body should be populated
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoGet200() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 200, '{"result":"success"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            RestResponse response = service.doGet( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 200, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * GET – 400 Bad Request: error branch executes and Logger called
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoGet400() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 400, '{"result":"bad request"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            RestResponse response = service.doGet( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 400, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * GET – 404 Not Found: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoGet404() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 404, '{"result":"not found"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            RestResponse response = service.doGet( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 404, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * GET – 500 Internal Server Error: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoGet500() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 500, '{"result":"server error"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            RestResponse response = service.doGet( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 500, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * GET – 503 Service Unavailable: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoGet503() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 503, '{"result":"service unavailable"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            RestResponse response = service.doGet( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 503, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * GET – unhandled status code (e.g. 510): falls into else branch, uses resp.getBody()
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoGet510() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 510, '{"result":"unknown error"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            RestResponse response = service.doGet( new GetRequest() );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 510, response.getStatusCode() );
    }


    // ─── doPost ──────────────────────────────────────────────────────────────────

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * POST – 200 success: response body should be populated
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoPost200() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 200, '{"result":"success"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            PostRequest req = new PostRequest();
            req.setBody( '{"email":"test@host.com"}' );
            RestResponse response = service.doPost( req );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 200, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * POST – 400 Bad Request: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoPost400() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 400, '{"result":"bad request"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            PostRequest req = new PostRequest();
            req.setBody( '{"email":"test@host.com"}' );
            RestResponse response = service.doPost( req );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 400, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * POST – 404 Not Found: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoPost404() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 404, '{"result":"not found"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            PostRequest req = new PostRequest();
            req.setBody( '{"email":"test@host.com"}' );
            RestResponse response = service.doPost( req );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 404, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * POST – 500 Internal Server Error: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoPost500() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 500, '{"result":"server error"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            PostRequest req = new PostRequest();
            req.setBody( '{"email":"test@host.com"}' );
            RestResponse response = service.doPost( req );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 500, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * POST – 503 Service Unavailable: error branch executes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoPost503() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 503, '{"result":"service unavailable"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            PostRequest req = new PostRequest();
            req.setBody( '{"email":"test@host.com"}' );
            RestResponse response = service.doPost( req );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 503, response.getStatusCode() );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * POST – unhandled status code (e.g. 510): falls into else branch
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void testDoPost510() {
        Test.startTest();
            Test.setMock( HttpCalloutMock.class, new ServiceMock( 510, '{"result":"unknown error"}' ) );
            CCCToolsEmailRestService service = new CCCToolsEmailRestService();
            service.endPointMetadataObj = buildMetadata();
            PostRequest req = new PostRequest();
            req.setBody( '{"email":"test@host.com"}' );
            RestResponse response = service.doPost( req );
        Test.stopTest();
        System.assertNotEquals( null, response );
        System.assertEquals( 510, response.getStatusCode() );
    }
}