/****************************************************************************************************************
* Program Name         : LoyaltyAccountIntegration
* Description          : This class is used to get the Loyalty details to CGrid.
* Version              : 1.1
* Modification Log     : 19 July, 2022 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   SK_01          DP-37893       1.1       Sumit Saha      07/19/2022      This class is used to get the Loyalty details to CGrid.

*                                                                                                                                 
*****************************************************************************************************************/

@isTest
public with sharing class LoyaltyAccountIntegrationTest {

    @isTest 
    public static void getAccountCIDTest(){

        Account account = new Account();
        account.FirstName = 'Sumit';
        account.LastName = 'Saha';
        account.AccountEmail__c = 'ssaha@lb.com';
        account.Phone = '9803207694';
        account.CID__c = 'b64140e5-1fba-4c32-abba-bfb3ad0f72df';
        insert account;

        LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        String out = LoyaltyAccountIntegration.getAccountCID(account.Id);
        LoyaltyAccountIntegration.Loyalty loyalty = (LoyaltyAccountIntegration.Loyalty) JSON.deserialize(out, LoyaltyAccountIntegration.Loyalty.class);
        System.assertEquals('21779375655', loyalty.id);
        System.assertEquals('Active', loyalty.status);
        Test.stopTest();
    }

    @isTest
    public static void getAccountCID_LoyaltyExist_Test(){

        Account account = new Account();
        account.FirstName = 'Sumit';
        account.LastName = 'Saha';
        account.AccountEmail__c = 'ssaha@lb.com';
        account.Phone = '9803207694';
        account.CID__c = 'b64140e5-1fba-4c32-abba-bfb3ad0f72df';
        account.Loyalty_ID__pc = '21779375655';
        account.Loyalty_account_Status__pc = 'Active';
        account.Customer_Type__pc = 'Individual - Pilot';
        insert account;

        LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        String out =  LoyaltyAccountIntegration.getAccountCID(account.Id);
        LoyaltyAccountIntegration.Loyalty loyalty = (LoyaltyAccountIntegration.Loyalty) JSON.deserialize(out, LoyaltyAccountIntegration.Loyalty.class);
        System.assertEquals(account.Loyalty_ID__pc, loyalty.id);
        System.assertEquals(account.Loyalty_account_Status__pc, loyalty.status);
        Test.stopTest();
    }

    @isTest
    public static void loyaltyDetailsLookupTest(){
        LoyaltyAccountIntegration.Input input = new LoyaltyAccountIntegration.Input();
        input.brand = 'VSS';
        input.loyaltyId.id = '21779375655';
        input.direct = false;

        LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        String out = LoyaltyAccountIntegration.loyaltyDetailsLookup(JSON.serialize(input));
        LoyaltyAccountIntegration.GetCustomerLoyalty res = (LoyaltyAccountIntegration.GetCustomerLoyalty) JSON.deserialize(out, LoyaltyAccountIntegration.GetCustomerLoyalty.class);
        System.assertEquals(200, res.response.statusCode);
        Test.stopTest();
    }

    @isTest
    public static void loyaltyDetailsLookup_Mapping_Test(){
        LoyaltyAccountIntegration.Input input = new LoyaltyAccountIntegration.Input();
        input.brand = 'VSS';
        input.loyaltyId.id = '21779375655';
        input.direct = false;

        LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();
        obj.loyalty.tierCode = 'XX';
        obj.loyalty.status = 'YY';
        obj.loyalty.customerType = 'ZZ';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        String out = LoyaltyAccountIntegration.loyaltyDetailsLookup(JSON.serialize(input));
        LoyaltyAccountIntegration.GetCustomerLoyalty res = (LoyaltyAccountIntegration.GetCustomerLoyalty) JSON.deserialize(out, LoyaltyAccountIntegration.GetCustomerLoyalty.class);
        System.assertEquals(null, res.customer[0].loyalty.tierCode );
        System.assertEquals(null, res.customer[0].loyalty.status );
        System.assertEquals(null, res.customer[0].loyalty.customerType );
        Test.stopTest();
    }

    @isTest
    public static void loyaltyDetailsLookup_HttpError_Test(){
        LoyaltyAccountIntegration.Input input = new LoyaltyAccountIntegration.Input();
        input.brand = 'VSS';
        input.loyaltyId.id = '21779375655';
        input.direct = false;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure());
        String out = LoyaltyAccountIntegration.loyaltyDetailsLookup(JSON.serialize(input));
        LoyaltyAccountIntegration.GetCustomerLoyalty res =  ( LoyaltyAccountIntegration.GetCustomerLoyalty) JSON.deserialize(out,  LoyaltyAccountIntegration.GetCustomerLoyalty.class);
        System.assertEquals(400, res.response.statusCode);
        Test.stopTest();    
    }

    @isTest
    public static void loyaltyDetailsLookup_EmptyResponse_Test(){
        LoyaltyAccountIntegration.Input input = new LoyaltyAccountIntegration.Input();
        input.brand = 'VSS';
        input.loyaltyId.id = '21779375655';
        input.direct = false;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorEmptyResponse());
        String out = LoyaltyAccountIntegration.loyaltyDetailsLookup(JSON.serialize(input));
        LoyaltyAccountIntegration.GetCustomerLoyalty res = (LoyaltyAccountIntegration.GetCustomerLoyalty) JSON.deserialize(out, LoyaltyAccountIntegration.GetCustomerLoyalty.class);
        System.assertEquals('[]', JSON.serialize(res.customer) );
        Test.stopTest();    
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        List<LoyaltyAccountIntegration.GetAccountResponseWrapper> response =  new List<LoyaltyAccountIntegration.GetAccountResponseWrapper>();

        MockHttpResponseGenerator(){}

        MockHttpResponseGenerator( LoyaltyAccountIntegration.GetAccountResponseWrapper obj){
            response.add(obj);
        }

        public HTTPResponse respond(HTTPRequest req) {
            // System.assertEquals('https://cgridapitest.victoriassecret.com/customer/v4', req.getEndpoint());      
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(response));
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        List<LoyaltyAccountIntegration.GetAccountResponseWrapper> response =  new List<LoyaltyAccountIntegration.GetAccountResponseWrapper>();
        MockHttpResponseGeneratorFailure(){}

        MockHttpResponseGeneratorFailure( LoyaltyAccountIntegration.GetAccountResponseWrapper obj){
            response.add(obj);
        }
        public HTTPResponse respond(HTTPRequest req) {
            // System.assertEquals('https://cgridapitest.victoriassecret.com/customer/v4', req.getEndpoint());           
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(response));
            res.setStatusCode(400);
            return res;
        }
    }

    private class MockHttpResponseGeneratorEmptyResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // System.assertEquals('https://cgridapitest.victoriassecret.com/customer/v4', req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static LoyaltyAccountIntegration.GetAccountResponseWrapper responsePayload(){
        LoyaltyAccountIntegration.GetAccountResponseWrapper g = new LoyaltyAccountIntegration.GetAccountResponseWrapper();
        g.id = 'b64140e5-1fba-4c32-abba-bfb3ad0f72df';
        g.rid = 'caa37e4a-63af-4610-8be3-9e51af74d3e2';
        g.brand = 'VSS' ;
        g.email  = 'MSTESTER1AAA1111@VSS-US.COM';
        g.phone = '9803207694';
        g.firstName = 'SUMIT';
        g.lastName = 'SAHA' ;
        g.direct  = false;
        g.phoneType = 'Mobile';
        g.address.streetAddress1 = '2300 WINDY RIDGE PKWY SE';
        g.address.city = 'ATLANTA';
        g.address.postalCode = '30339';
        g.address.state = 'GA';
        g.address.country = 'US';  

        g.shipAddress.streetAddress1 = '1';
        g.shipAddress.city = 'GAHANNA';
        g.shipAddress.postalCode = '43230';
        g.shipAddress.state = 'OH';
        g.shipAddress.country = 'US'; 

        g.loyalty.id = '21779375655';
        // g.loyalty.type = null;
        g.loyalty.adsID = '12345623435';
        g.loyalty.status = 'A';
        g.loyalty.statusReason = null;
        g.loyalty.tierCode = 'VST3';
        g.loyalty.customerType = 'I';

        g.lastUpdateTime = '2022-09-22T21:25:52.254373';

        return g;
    }

    public static String expected(){
        String expected = '[{"shipAddress":{"streetAddress3":null,"streetAddress2":null,"streetAddress1":"1","state":"OH","postalCode":"43230","pobox":null,"country":"US","city":"GAHANNA"},"rid":"caa37e4a-63af-4610-8be3-9e51af74d3e2","phoneType":"Mobile","phone":"9803207694","loyalty":{"type":null,"tierCode":"VIP","statusReason":null,"status":"Active","id":"21779375655","customerType":"Individual - Pilot","adsID":"12345623435"},"lastUpdateTime":"2022-09-22T21:25:52.254373","lastName":"SAHA","id":"b64140e5-1fba-4c32-abba-bfb3ad0f72df","firstName":"SUMIT","email":"MSTESTER1AAA1111@VSS-US.COM","direct":false,"brand":"VSS","birthDate":null,"address":{"streetAddress3":null,"streetAddress2":null,"streetAddress1":"2300 WINDY RIDGE PKWY SE","state":"GA","postalCode":"30339","pobox":null,"country":"US","city":"ATLANTA"}}]';
        List<LoyaltyAccountIntegration.GetAccountResponseWrapper> e = (List<LoyaltyAccountIntegration.GetAccountResponseWrapper>) JSON.deserialize(expected, List<LoyaltyAccountIntegration.GetAccountResponseWrapper>.class);
        return JSON.serialize(e[0]);
    }
}