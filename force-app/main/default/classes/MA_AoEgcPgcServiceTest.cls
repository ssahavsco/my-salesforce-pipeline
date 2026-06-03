/** Created by Sumit Saha
 *  Created Date: Jan 4 , 2024
 */

@isTest
 public with sharing class MA_AoEgcPgcServiceTest {
   @isTest
    public static void sendEcgPcgReqTest_1(){
        Mass_Appeasement__c ma = new Mass_Appeasement__c();
        ma.BatchID__c = '5465465465465';
        ma.GIFT_CARD_AMOUNT__C = 100.00;
        ma.Price_Override_Reason__c = 'CD_POR';
        ma.GIFT_CARD_TYPE__C = 'EGC';
        ma.MESSAGE_ID__C = '9066907535023948';
        ma.ASSOCIATE_ID__C = 'ssaha';
        ma.RECIPIENT_ADDRESS1__C = 'test';
        ma.RECIPIENT_ADDRESS2__C = 'test';
        ma.RECIPIENT_CITY__C = 'test';
        ma.RECIPIENT_COUNTRY__C = 'test';
        ma.RECIPIENT_EMAIL__C = 'ssaha@lb.com';
        ma.RECIPIENT_FIRST_NAME__C = 'Sumit';
        ma.RECIPIENT_LAST_NAME__C = 'Saha';
        ma.RECIPIENT_PHONE__C= '741-852-8523';
        ma.RECIPIENT_STATE__C = 'Ohio' ;
        ma.RECIPIENT_ZIP_POSTAL_CODE__C = '43230';
        insert ma;

        String orderNumber = [SELECT Name from Mass_Appeasement__c where Id =: ma.id].Name;

        String obj = '{"messageID":"5646465465465465"}' ;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        MA_AoEgcPgcService.sendEcgPcgReq(orderNumber);
        Test.stopTest();
    }

   @isTest
    public static void sendEcgPcgReqTest_2(){
        Mass_Appeasement__c ma = new Mass_Appeasement__c();
        ma.BatchID__c = '5465465465465';
        ma.GIFT_CARD_AMOUNT__C = 100.00;
        ma.Price_Override_Reason__c = 'CD_POR';
        ma.GIFT_CARD_TYPE__C = 'Physical Gift Card';
        ma.MESSAGE_ID__C = '9066907535023948';
        ma.ASSOCIATE_ID__C = 'ssaha';
        ma.RECIPIENT_ADDRESS1__C = 'test';
        ma.RECIPIENT_ADDRESS2__C = 'test';
        ma.RECIPIENT_CITY__C = 'test';
        ma.RECIPIENT_COUNTRY__C = 'test';
        ma.RECIPIENT_EMAIL__C = 'ssaha@lb.com';
        ma.RECIPIENT_FIRST_NAME__C = 'Sumit';
        ma.RECIPIENT_LAST_NAME__C = 'Saha';
        ma.RECIPIENT_PHONE__C= '741-852-8523';
        ma.RECIPIENT_STATE__C = 'Ohio' ;
        ma.RECIPIENT_ZIP_POSTAL_CODE__C = '43230';
        insert ma;

        String orderNumber = [SELECT Name from Mass_Appeasement__c where Id =: ma.id].Name;

        String obj = '{"messageID":"5646465465465465"}' ;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj));
        MA_AoEgcPgcService.sendEcgPcgReq(orderNumber);
        Test.stopTest();
    }
   @isTest
    public static void sendEcgPcgReqTest_3(){
        Mass_Appeasement__c ma = new Mass_Appeasement__c();
        ma.BatchID__c = '5465465465465';
        ma.GIFT_CARD_AMOUNT__C = 100.00;
        ma.Price_Override_Reason__c = 'CD_POR';
        ma.GIFT_CARD_TYPE__C = 'Physical Gift Card';
        ma.MESSAGE_ID__C = '9066907535023948';
        ma.ASSOCIATE_ID__C = 'ssaha';
        ma.RECIPIENT_ADDRESS1__C = 'test';
        ma.RECIPIENT_ADDRESS2__C = 'test';
        ma.RECIPIENT_CITY__C = 'test';
        ma.RECIPIENT_COUNTRY__C = 'test';
        ma.RECIPIENT_EMAIL__C = 'ssaha@lb.com';
        ma.RECIPIENT_FIRST_NAME__C = 'Sumit';
        ma.RECIPIENT_LAST_NAME__C = 'Saha';
        ma.RECIPIENT_PHONE__C= '741-852-8523';
        ma.RECIPIENT_STATE__C = 'Ohio' ;
        ma.RECIPIENT_ZIP_POSTAL_CODE__C = '43230';
        insert ma;

        String orderNumber = [SELECT Name from Mass_Appeasement__c where Id =: ma.id].Name;

        String obj = '{"messageID":"5646465465465465"}' ;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFail(obj));
        MA_AoEgcPgcService.sendEcgPcgReq(orderNumber);
        Test.stopTest();
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        String response ;
        MockHttpResponseGenerator(String query){
           response = query;
       }
       public HTTPResponse respond(HTTPRequest req) {
           HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           res.setBody(response);
           res.setStatusCode(200);
           return res;
       }
   }
    private class MockHttpResponseGeneratorFail implements HttpCalloutMock {
        String response ;
        MockHttpResponseGeneratorFail(String query){
           response = query;
       }
       public HTTPResponse respond(HTTPRequest req) {
           HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           res.setBody(response);
           res.setStatusCode(401);
           return res;
       }
   }
}