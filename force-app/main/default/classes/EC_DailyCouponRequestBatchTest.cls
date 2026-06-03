// Test class for EC_DailyCouponRequestBatch and EC_DailyCouponRequestBatch
@isTest
public with sharing class EC_DailyCouponRequestBatchTest {
    
    static testmethod void testCouponRequestBatchClass() {
		RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Test.startTest();
        Account acc = new Account();
        acc.RecordTypeId = personAccountRecordType.Id;
        acc.lastName = 'Test Name';
        insert acc;

        Contact con = new Contact();
        con.lastName = 'Test';
        con.FirstName = 'FirnatName Test';
        insert con;

        Case cse = new Case();
        cse.ContactId = con.Id;
        cse.AccountId= acc.Id;
        insert cse;
        
        Case_Resolution__c resolution = new Case_Resolution__c();
        resolution.Case_Resolution_Type__c = 'Coupon Request - Email';
        resolution.Approval_Date_Time__c = System.now().addDays(2);
        resolution.Related_Case__c = cse.Id;
        insert resolution;

        EC_DailyCouponRequestBatch batch = new EC_DailyCouponRequestBatch(); 
        Database.executeBatch(batch, 2000);
        Case_Resolution__c afterBatchProcessedRecord = [SELECT Id,Processed_Date_Time__c FROM Case_Resolution__c WHERE ID =: resolution.Id];
        System.assertEquals(false, afterBatchProcessedRecord.Processed_Date_Time__c != null);  
        //String jobId = System.schedule('testBasicScheduledApex', '0 30 2 ? * TUE *',new EC_DailyCouponRequestSchedule());
        Test.stopTest();
    }
}