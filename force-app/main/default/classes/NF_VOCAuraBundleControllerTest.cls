@isTest
public with sharing class NF_VOCAuraBundleControllerTest {
    @TestSetup
    static void makeData(){
        
      String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
      Account testAccount = new Account(
          RecordTypeId = recordTypeIdPA,
          FirstName    = 'Test',
          LastName     = 'Account'
      );
      insert testAccount;

      RecordType recType = [ SELECT Id FROM RecordType WHERE sObjectType = 'Case' LIMIT 1 ];
      Case testCase = new Case(
          RecordTypeId = recType.Id,
          AccountId = testAccount.Id

      );
        
        insert testCase;
         // Create common test contact
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com');
        insert con;
        
        
        String routableId = NF_UtilTest.insertMessagingSessionWithContact(con.Id);
        MessagingSession msgSession = [Select CaseId From MessagingSession Where Id =: routableId];
        msgSession.CaseId = testCase.Id;
        Update msgSession;
    }

    @isTest
    static void testMethod1(){
        String recId = [SELECT Id from MessagingSession LIMIT 1].Id;
        NF_VOCAuraBundleController.getOrderNumber(recId);
    }
    
    @isTest
    static void testMethod2(){
        String recId = [SELECT Id from Case LIMIT 1].Id;
        NF_VOCAuraBundleController.getOrderNumber(recId);
    }
     @isTest
    static void testMethod3(){
        String recId = [SELECT Id from MessagingSession LIMIT 1].Id;
        NF_VOCAuraBundleController.vocAccessable(recId);
    }
}