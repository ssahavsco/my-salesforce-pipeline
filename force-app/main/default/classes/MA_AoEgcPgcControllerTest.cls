/** Created by Sumit Saha
 *  Created Date: Jan 4 , 2024
 */

@isTest
public with sharing class MA_AoEgcPgcControllerTest {
    @isTest
    public static void submitOrderBatchTest(){
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

        Test.startTest();
        String jobId = MA_AoEgcPgcController.submitOrderBatch('5465465465465');
        Test.stopTest();
    }
}