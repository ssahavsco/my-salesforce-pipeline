/** Created by SUMIT SAHA | ssaha@victoria.com
 *  on 7th Jan 2024
 */

@isTest
public with sharing class VS_MostRecentCustomerOrderTest {

    private static void testSetupData() {
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd',
            Origin__c = 'Origin',
            AO_Access_Token_1__c = 'Invalid_Token'
        );
        insert testLBrandsAPI;
    }

    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    public static void authTest(){
        VS_MostRecentCustomerOrder v = new VS_MostRecentCustomerOrder();
        
        String obj = '{"access_token":"eyJhbG"}' ;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpAuthResponseGenerator(obj));
        v.authenticate();
        Test.stopTest();
    }

    @isTest
    public static void getOrder(){
        String input = '{"Query":"CustomerEmail = \'dwilcox@victoria.com\' AND CreatedBy = \'dwilcox\' AND CreatedTimestamp > CURRENTTIME(-1H)","Size":1,"Sort":{"attribute":"CreatedTimestamp","direction":"DESC"},"Template":{"OrderId":null,"CreatedTimestamp":null,"CustomerEmail":null,"CreatedBy":null}}';

        String obj = '{"data":[{"OrderId":"C300068584","CustomerEmail":"DWILCOX@VICTORIA.COM"}]}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpOrderResponseGenerator(obj));
        VS_MostRecentCustomerOrder.getOrderNumber(input);
 
        Test.setMock(HttpCalloutMock.class, new MockHttpOrderResponseGeneratorFail(obj));
        VS_MostRecentCustomerOrder.getOrderNumber(input);
        Test.stopTest();


    }

    private class MockHttpAuthResponseGenerator implements HttpCalloutMock {
         String response ;
        MockHttpAuthResponseGenerator(String query){
            response = query;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug(JSON.serialize(JSON.serialize(response)));
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    private class MockHttpOrderResponseGenerator implements HttpCalloutMock {
         String response ;
         MockHttpOrderResponseGenerator(String query){
            response = query;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug(JSON.serialize(JSON.serialize(response)));
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    private class MockHttpOrderResponseGeneratorFail implements HttpCalloutMock {
         String response ;
         MockHttpOrderResponseGeneratorFail(String query){
            response = query;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug(JSON.serialize(JSON.serialize(response)));
            res.setBody(response);
            res.setStatusCode(401);
            return res;
        }
    }
}