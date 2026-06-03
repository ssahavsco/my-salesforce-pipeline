@IsTest
public with sharing class NF_AccountTriggerHandlerTest {

    static testMethod void AccountPhoneUpdate_Insert(){
        Account c = new Account(FirstName='First', LastName='Last', PersonEmail='test@test.com', Phone='222-222-2222');
        test.startTest();
        insert c;
        test.stopTest();
    }

    static testMethod void AccountPhoneUpdate_Update(){
        Account c = new Account(FirstName='First', LastName='Last', PersonEmail='test@test.com', Phone='222-222-2222');
        insert c;
        test.startTest();
        c.Phone = '222-222-2222';
        c.Phone_Search_Reset__c = true;
        update c;
        test.stopTest();
    }

}