/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for Auto-Close case
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sharath Vadla  <svadla@.victoria.com>
* @version        1.0
* @created        05/06/2023
* @modified       05/09/2023
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘*/
@isTest
private class VS_UpdateCaseFromLCTPageTest {
    @isTest
    static void testUpdateCase() {
        // Create a Person Account record
        Account personAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'John',
            LastName = 'Doe'
        );
        insert personAccount;

        // Create a Case record associated with the Person Account
        Case caseRecord = new Case(
            AccountId = personAccount.Id,
            RecordTypeId = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().getRecordTypeInfosByName().get( 'Chat Case' ).getRecordTypeId(),
            Subject = 'Test Case',
            Status = 'Open',
            Origin = 'Chat',
            Auto_Closed__c = false
        );
        insert caseRecord;
        
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select CaseId From MessagingSession Where Id =: routableId];
		msgSession.CaseId = caseRecord.Id;
        Update msgSession;
        // Call the updateCase method
        Test.startTest();
        try
        {
        VS_UpdateCaseFromLCTPage.updateCase(routableId);
        }catch(Exception E){

        }
        Test.stopTest();

        // Verify that the Case was updated correctly
        String CaseId = [SELECT Id FROM Case WHERE Subject =: 'Test Case' LIMIT 1][0].Id;
        
        caseRecord = [SELECT Id, Status, Type, Sub_Type__c, Auto_Closed__c FROM Case WHERE Id = :CaseId];
        system.debug('Case Record; ' + CaseRecord);
        System.assertEquals('Closed', caseRecord.Status);
        System.assertEquals('Auto-Closed Case', caseRecord.Type);
        System.assertEquals('Auto-Closed Case', caseRecord.Sub_Type__c);
        System.assertEquals(true, caseRecord.Auto_Closed__c);
    }
    @isTest
     static void testExceptionUpdateCase() {
        // Create a Person Account record
        Account personAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'John',
            LastName = 'Doe'
        );
        insert personAccount;

        // Create a Case record associated with the Person Account
        Case caseRecord = new Case(
            AccountId = personAccount.Id,
           // RecordTypeId = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().getRecordTypeInfosByName().get( 'Chat Case' ).getRecordTypeId(),
            Subject = 'Test Case',
            Status = 'Open',
            Origin = 'Chat',
            Auto_Closed__c = false
        );
        insert caseRecord;
        
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select CaseId From MessagingSession Where Id =: routableId];
		msgSession.CaseId = caseRecord.Id;
        Update msgSession;

        // Call the updateCase method
        Test.startTest();
        try
        {
        VS_UpdateCaseFromLCTPage.updateCase(routableId);
        }catch(Exception E){
        System.assertEquals(true, E.getMessage().contains('exception'));
		system.debug('Exception message' +E.getMessage());
        }
        Test.stopTest();       
    }
}