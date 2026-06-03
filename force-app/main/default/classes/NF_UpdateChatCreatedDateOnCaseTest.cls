@isTest
public class NF_UpdateChatCreatedDateOnCaseTest{
    @TestSetup
    static void makeData(){
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(RecordTypeId = recordTypeIdPA, FirstName = 'Test', LastName = 'Account');
        insert testAccount;

        RecordType recType = [SELECT Id
                              FROM RecordType
                              WHERE sObjectType = 'Case'
                              LIMIT 1];
        Case testCase = new Case(RecordTypeId = recType.Id, AccountId = testAccount.Id, Offer_Code__c = 'ABCD');
        insert testCase;
		System.debug('case---'+testCase);
        LiveChatTranscript t1 = new LiveChatTranscript();
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        } catch (Exception e){

        }
        t1.LiveChatVisitorId = lcv.Id;
        t1.ChatKey = 'somechatkey';
        t1.CaseId = testCase.Id;
        insert t1;
		System.debug('t1Size'+t1.Case.Offer_Code__c);
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = t1.Id;
        session.ebotdata__Case__c = testCase.Id;
        //insert session;
    }

    @isTest static void testBatch(){
        List<LiveChatTranscript> chatList = [SELECT Id,CaseId,Case.Chat_Created_Date__c from LiveChatTranscript];
        System.debug('chatList'+chatList.size());
        Database.executeBatch(new NF_UpdateChatCreatedDateOnCase());
    }

}