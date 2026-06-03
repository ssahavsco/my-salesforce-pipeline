/*****************************************************************************************************@@
Class Name     :  LiveChatTranscriptTimerControllerTest
Purpose        :  helper class used to get the case field set for the VOC coding component placed on Case layout.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Sumit                02/10/2023           Original Version  			DP-50419

@Testsuite:  {LiveChatTranscriptTimerController_Test}                                       
*********************************************************************************************************/


@IStest
public class LiveChatTranscriptTimerControllerTest {

    @isTest
    public static void getCaseInfoTest(){

        VS_Chat_Settings__c settings = new VS_Chat_Settings__c();
        settings.Name  = 'VSChat';
        settings.Chat_Wrap_Up_Alert__c = true;
        settings.Chat_Wrap_Up_Alert_Message__c = 'Alert: Your chat with CustomerName has been in wrap up for more than 1 minute. Please reach out to a leader if you need support.';
        settings.Chat_Wrap_Up_Alert_Seconds__c = 60;
        insert settings;

        Contact c = new Contact();
        c.LastName = 'Test Last';
        c.FirstName = 'Test First';
        c.OwnerId  = UserInfo.getUserId();
        insert c;

        Case cs = new Case();
        cs.RecordTypeId = '0123h000000dIwCAAU';
        cs.Origin = 'chat'; 
        cs.Type = 'Account Update / Email Frequency';
        cs.Sub_Type__c = 'Account Info Update';
        cs.Status = 'New';
        cs.VOC_Comments__c = 'Test';
        cs.ContactId = c.id;
        cs.OwnerId =  UserInfo.getUserId();
        insert cs;

        LiveChatVisitor livechatvisitor = new LiveChatVisitor();
        insert livechatvisitor;

        LiveChatTranscript lt = new LiveChatTranscript();
        lt.body = 'tes';
        lt.LiveChatVisitorId = livechatvisitor.id;
        lt.caseId = cs.Id;
        lt.Custom_Chat_End_Time__c = System.now();
        insert lt;

        LiveChatTranscriptTimerController.getCaseInfo( (String) lt.id);

    }
}