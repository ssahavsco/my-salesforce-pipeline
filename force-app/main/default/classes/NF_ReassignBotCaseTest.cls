/**
 * Created by mcasella on 9/8/20.
 */

@IsTest
public with sharing class NF_ReassignBotCaseTest {

    @IsTest
    static void testEmptyTranscriptList() {
        System.assertEquals(false, NF_ReassignBotCase.reassignCases(null), 'should have value');
    }

    @IsTest
    static void TestEscalateTranscript(){
        NF_ReassignBotCase.testStatusVariable = 'InProgress';
        
        Test.startTest();

        User u2 = null;
        User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();
        try {
            u2 = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                    LastName = 'last2',
                    Email = 'test@test.com',
                    Username = 'test@test.com' + System.currentTimeMillis(),
                    CompanyName = 'TEST',
                    Title = 'title',
                    Alias = 'alias',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US'
            );
            /*Account*/
            Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account objAcc = new Account();
            objAcc.FirstName = 'TEST';
            objAcc.LastName = 'account';
            objAcc.PersonEmail = 'x@y.com';
            objAcc.Type = 'Personal';
            objAcc.RecordTypeId = personAccRecordTypeId;
            insert objAcc;

            insert u2;
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'NF_ReassignBotCaseTest: error inserting users: '+e.getMessage());
            System.debug(LoggingLevel.DEBUG, 'NF_ReassignBotCaseTest: error inserting users: '+e.getLineNumber());
        }

        Case c = new Case();
        c.Origin = 'Chatbot';
        LiveChatTranscript transcript;

        System.runAs(platformIntegrationUser){
            transcript = insertEmptyLiveChatTranscript();

            c.OwnerId = platformIntegrationUser.Id;
            c.RecordTypeId = NF_CreateCase.getRecordType().Id;
            insert c;
        }

        String insertedContactId = [SELECT ID, PersonContactId FROM Account WHERE personEmail = 'x@y.com' ORDER BY CreatedDATE DESC Limit 1].PersonContactId;
        if(transcript != null && u2 != null && u2.Id != null) {
            //transcript.CaseId = c.Id;
            transcript.OwnerId = u2.Id;
            transcript.ContactId = insertedContactId;

            LiveChatButton[] buttons = [SELECT Id, DeveloperName from LiveChatButton WHERE DeveloperName = 'Customer_Care_Bot'];
            if(buttons.size() > 0){
                transcript.LiveChatButton = buttons[0];
            }

            update transcript;
        }
        List<Case> theCase = [SELECT Id, OwnerId FROM Case WHERE contactId =: insertedContactId];
       //System.assert(theCase[0].OwnerId == transcript.OwnerId, 'should have correct id');

        Test.stopTest();
    }


    public static LiveChatTranscript insertEmptyLiveChatTranscript(){
        LiveChatVisitor v = new LiveChatVisitor();
        insert v;
        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.LiveChatVisitorId= v.Id;
        transcript.LiveChatButtonId = NF_Util.getChatButtonId('Customer_Care_Associates');
        insert transcript;
        
        NF_ChatTranscriptTriggerHandler chathandler = new NF_ChatTranscriptTriggerHandler();
        chathandler.isDisabled();
        
        return transcript;
    }
}