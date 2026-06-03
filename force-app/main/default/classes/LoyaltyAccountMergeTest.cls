/** Created by Sumit Saha
 *  This is test class to validate LoyaltyAccountMerge
 *  Date: 07-July-2023
 */

@isTest
public with sharing class LoyaltyAccountMergeTest {
    @isTest
    public static void mergeLoyaltyAccountTest_1(){
        LoyaltyAccountMerge.Input input = new LoyaltyAccountMerge.Input();
        input.targetEmailId = 'Test@VSCO.com';
        input.targetLoyaltyId = '1452365789';
        input.customerArchive = true;

        LoyaltyAccountMerge.Output obj = responsePayload_1();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        String out = LoyaltyAccountMerge.mergeLoyaltyAccount(JSON.serialize(input));
        LoyaltyAccountMerge.Output res = (LoyaltyAccountMerge.Output) JSON.deserialize(out, LoyaltyAccountMerge.Output.class);
        System.assertEquals('true', res.success );
        Test.stopTest();

    }

    @isTest
    public static void mergeLoyaltyAccountTest_2(){
        LoyaltyAccountMerge.Input input = new LoyaltyAccountMerge.Input();
        input.targetEmailId = 'Test@VSCO.com';
        input.targetLoyaltyId = '1452365789';
        input.customerArchive = true;

        LoyaltyAccountMerge.Output obj = responsePayload_2();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure(obj));
        String out = LoyaltyAccountMerge.mergeLoyaltyAccount(JSON.serialize(input));
        LoyaltyAccountMerge.Output res = (LoyaltyAccountMerge.Output) JSON.deserialize(out, LoyaltyAccountMerge.Output.class);
        System.assertEquals('false', res.success );
        Test.stopTest();
    }

    public static LoyaltyAccountMerge.Output responsePayload_1(){
        LoyaltyAccountMerge.Output output = new LoyaltyAccountMerge.Output();
        output.success = 'true';
        output.error.code = null;
        output.error.message = null;
        return output;
    }
    public static LoyaltyAccountMerge.Output responsePayload_2(){
        LoyaltyAccountMerge.Output output = new LoyaltyAccountMerge.Output();
        output.success = 'false';
        output.error.code = '400';
        output.error.message = 'no customer found in CGrid for the following email in the request';
        return output;
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        LoyaltyAccountMerge.Output response = new LoyaltyAccountMerge.Output();
        MockHttpResponseGenerator(LoyaltyAccountMerge.Output obj){
            response = obj;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(response));
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        LoyaltyAccountMerge.Output response = new LoyaltyAccountMerge.Output();
        MockHttpResponseGeneratorFailure(LoyaltyAccountMerge.Output obj){
            response = obj;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(response));
            res.setStatusCode(400);
            return res;
        }
    }
}