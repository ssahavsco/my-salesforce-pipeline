@isTest
public with sharing class NF_PostChatSurveyControllerTest {

    @TestSetup
    public static void initTestData() {
        ebotdata__Bot_Session__c testSession = new ebotdata__Bot_Session__c();

        testSession.ebotdata__Live_Agent_Session_Id__c = 'test123';

        insert testSession;
    }

    @IsTest
    public static void testConstructor() {
        NF_PostChatSurveyController chatSurvey = new NF_PostChatSurveyController();
        chatSurvey.languageCode = 'zh_CN';
        chatSurvey.getItemsList();
        NF_PostChatSurveyController testController = new NF_PostChatSurveyController();
        System.assertNotEquals(null, testController, 'should have value');
    }

    @IsTest
    public static void testSaveFormResponses_emptyInput() {
        NF_PostChatSurveyController testController = new NF_PostChatSurveyController('test123');
        testController.saveResponsesToBotSession();
        System.assertNotEquals(null, testController, 'should have value');
    }

    @IsTest
    public static void testSaveFormResponses_fullInput() {
        NF_PostChatSurveyController testController = new NF_PostChatSurveyController('test123');

        testController.wouldChatAgain = 1;
        testController.overallExperience = 4;
        testController.questionSatisfaction = 2;
        testController.additionalComments = 'This is a test';

        LiveChatTranscript lct = NF_UtilTest.insertLiveChatTranscript('abc', null, null);
        testController.chatKey = lct.ChatKey;

        testController.saveResponsesToBotSession();
        System.assertNotEquals(null, testController, 'should have value');
    }

    @IsTest
    public static void getChatTypeBot(){
        LiveChatTranscript lct = NF_UtilTest.insertLiveChatTranscript('abc', null, null);
        String chatType = NF_PostChatSurveyController.getChatType(lct);

        //default will be 'Bot'
        System.assertEquals('Bot', chatType);
    }

    @IsTest
    public static void getChatTypeChat(){
        LiveChatTranscript lct = NF_UtilTest.insertLiveChatTranscript('abc', null, null);

        String chatType = 'Bot';


        //a button with the DevelpoerName 'Customer_Care_Associates' must exist
        LiveChatButton[] buttons = [SELECT Id FROM LiveChatButton WHERE DeveloperName = 'Customer_Care_Associates' LIMIT 1];
        if(buttons.size() > 0){
            lct.LiveChatButtonId = buttons[0].Id;
            update lct;

            chatType = 'Associate';
        }

        String getChatType = NF_PostChatSurveyController.getChatType(lct);

        System.assertEquals(chatType, getChatType);
    }
}