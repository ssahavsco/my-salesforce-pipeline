@isTest
public class NF_UpdateCaseClassTest{
    @isTest
    static void updateAgentHandleTimeTest(){
        LiveChatTranscript t1 = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        } catch (Exception e){

        }
        t1.LiveChatVisitorId = lcv.Id;
        t1.ChatKey = 'somechatkey';
        insert t1;

        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(RecordTypeId = recordTypeIdPA, FirstName = 'Test', LastName = 'Account');
        insert testAccount;

        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE sObjectType = 'Case'
                              LIMIT 1];
        Case testCase = new Case(RecordTypeId = recType.Id, AccountId = testAccount.Id);

        insert testCase;
        // Create common test contact
        Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = t1.Id;
        session.ebotdata__Case__c=testCase.Id;
        insert session;
    }
    
    @isTest
    static void updateChatCreatedDateTest(){
        LiveChatTranscript t1 = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(RecordTypeId = recordTypeIdPA, FirstName = 'Test', LastName = 'Account');
        insert testAccount;

        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE sObjectType = 'Case'
                              LIMIT 1];
        Case testCase = new Case(RecordTypeId = recType.Id, AccountId = testAccount.Id);

        insert testCase;
        try{
            insert lcv;
        } catch (Exception e){

        }
        t1.LiveChatVisitorId = lcv.Id;
        t1.ChatKey = 'somechatkey';
        t1.CaseId = testCase.Id;
        insert t1;


        // Create common test contact
        Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;

        
    }
     @isTest
    static void testUpdateContactAndAccount() {
        // Create test data
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'Account',RecordTypeId = recordTypeIdPA);
        insert acc;
       RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE sObjectType = 'Case'
                              LIMIT 1];
        Case testCase = new Case(RecordTypeId = recType.Id, AccountId = acc.Id);
		insert testCase;
          Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        } catch (Exception e){

        }
        LiveChatTranscript chatTranscript = new LiveChatTranscript(
            
            CaseId = testCase.Id,
            AccountId = acc.Id,
            ContactId = con.Id,
            LiveChatVisitorId = lcv.Id,
            CreatedDate = DateTime.now(),
            Subject__c = 'Test Chat'
        );
        insert chatTranscript;

        // Convert test data to JSON string
        String chatString = JSON.serialize(new List<LiveChatTranscript>{chatTranscript});

        // Call the method
        Test.startTest();
        NF_UpdateCaseClass.updateContactAndAccount(chatString);
        Test.stopTest();

        // Verify the changes
        Case updatedCase = [SELECT Id, ContactId, AccountId, Chat_Created_Date__c, Subject FROM Case WHERE Id = :testCase.Id];
       // System.assertEquals(con.Id, updatedCase.ContactId, 'ContactId should have been updated');
        System.assertEquals(acc.Id, updatedCase.AccountId, 'AccountId should have been updated');
        System.assertEquals(chatTranscript.CreatedDate.date(), updatedCase.Chat_Created_Date__c, 'Chat created date should have been updated');
        System.assertEquals(chatTranscript.Subject__c, updatedCase.Subject, 'Case subject should have been updated');
    }
}