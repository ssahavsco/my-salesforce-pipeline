@isTest
public with sharing class LoyaltyTransactionSearchTest {

    @IsTest
    static void getOrderTransactionSearch_DIGITAL_Test(){
        LoyaltyTransactionSearch.Input input = new LoyaltyTransactionSearch.Input();
        input.transactionNumber = 'C300045858';
        String payload = '{"OrderId" : "C300045858", "OrderTotal":"102.50", "LoyaltyNumber":"56389854381", "CapturedDate":"2022-09-07T07:16:37.785", "Extended" : { "LoyaltyID": "75184917404" }, "Payment":[{"PaymentMethod":[{"CardType":{"CardTypeId":"Visa"},"PaymentType":{"PaymentTypeId":"Credit_Card"}}]}]}';

        Test.startTest();
        Test.setMock(  HttpCalloutMock.class, new MockHttpResponseGenerator(payload) );
        string result = LoyaltyTransactionSearch.getOrderTransactionSearch(JSON.serialize(input));
        LoyaltyTransactionSearch.SearchResult src = (LoyaltyTransactionSearch.SearchResult) JSON.deserialize(result, LoyaltyTransactionSearch.SearchResult.class);
        System.assertEquals(200, src.response.statusCode);
        Test.stopTest();
    }

    @IsTest
    static void getOrderTransactionSearch_STORE_Test(){
        LoyaltyTransactionSearch.Input input = new LoyaltyTransactionSearch.Input();
        input.transactionNumber = '51043001161108162022';
        String payload = '{"OrderId" : "51043001161108162022", "OrderTotal":"102.50", "LoyaltyNumber":"56389854381", "CapturedDate":"2022-09-07T07:16:37.785", "Extended" : { "LoyaltyID": "75184917404" }, "Payment":[{"PaymentMethod":[{"CardType":{"CardTypeId":"Visa"},"PaymentType":{"PaymentTypeId":"Credit_Card"}}]}]}';

        Test.startTest();
        Test.setMock(  HttpCalloutMock.class, new MockHttpResponseGenerator(payload) );
        String result =  LoyaltyTransactionSearch.getOrderTransactionSearch(JSON.serialize(input));
        LoyaltyTransactionSearch.SearchResult src = (LoyaltyTransactionSearch.SearchResult) JSON.deserialize(result, LoyaltyTransactionSearch.SearchResult.class);
        System.assertEquals(200, src.response.statusCode);
        Test.stopTest();
    }

    @IsTest
    static void getOrderTransactionSearch_No_LoyaltyId_Associated_Test(){
        LoyaltyTransactionSearch.Input input = new LoyaltyTransactionSearch.Input();
        input.transactionNumber = '51043001161108162022';
        String payload = '{"OrderId" : "51043001161108162022", "OrderTotal":"102.50", "LoyaltyNumber": null, "CapturedDate":"2022-09-07T07:16:37.785", "Extended" : { "LoyaltyID": null }, "Payment":[{"PaymentMethod":[{"CardType":{"CardTypeId":"Visa"},"PaymentType":{"PaymentTypeId":"Credit_Card"}}]}]}';

        Test.startTest();
        Test.setMock(  HttpCalloutMock.class, new MockHttpResponseGenerator(payload) );
        String result = LoyaltyTransactionSearch.getOrderTransactionSearch(JSON.serialize(input));
        LoyaltyTransactionSearch.SearchResult src = (LoyaltyTransactionSearch.SearchResult) JSON.deserialize(result, LoyaltyTransactionSearch.SearchResult.class);
        System.assertEquals(200, src.response.statusCode);
        Test.stopTest();
    }

    @IsTest
    static void getOrderTransactionSearch_Failure_Test(){
        LoyaltyTransactionSearch.Input input = new LoyaltyTransactionSearch.Input();
        input.transactionNumber = 'xyz';
        String payload = '{"code":"PUR-NOT-FOUND","message":"Transaction not found"}';

        Test.startTest();
        Test.setMock(  HttpCalloutMock.class, new MockHttpResponseGeneratorFailure(payload) );
        String result = LoyaltyTransactionSearch.getOrderTransactionSearch(JSON.serialize(input));
        LoyaltyTransactionSearch.SearchResult src = (LoyaltyTransactionSearch.SearchResult) JSON.deserialize(result, LoyaltyTransactionSearch.SearchResult.class);
        System.assertEquals(404, src.response.statusCode);
        Test.stopTest();
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        String phistResponse;

        MockHttpResponseGenerator(String payload){
            this.phistResponse = payload;
        }

        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().contains ('/purchasehistory/v3/VS/order') ) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody(phistResponse);
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('/customer')) { 
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('[{"id":"b64140e5-1fba-4c32-abba-bfb3ad0f72df","rid":"caa37e4a-63af-4610-8be3-9e51af74d3e2","brand":"VSS","email":"MSTESTER1AAA1111@VSS-US.COM","phone":"9803207694","firstName":"SUMIT","lastName":"SAHA","direct":false,"phoneType":"Mobile","address":{"streetAddress1":"2300 WINDY RIDGE PKWY SE","city":"ATLANTA","state":"GA","postalCode":"30339","country":"US"},"shipAddress":{"streetAddress1":"1","city":"GAHANNA","state":"OH","postalCode":"43230","country":"US"},"loyalty":{"id":"21779375655","adsID":"12345623435","tierCode":"VST3","status":"A","statusReason":"","customerType":"I"},"lastUpdateTime":"2022-09-22T21:25:52.254373"}]');
                res.setStatusCode(200);
                return res;
            } else {
                return null;
            }
        }
    }

    private class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        String phistResponse;

        MockHttpResponseGeneratorFailure(String payload){
            this.phistResponse = payload;
        }

        public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody(phistResponse);
                res.setStatusCode(404);
                return res;
        }
    }
}