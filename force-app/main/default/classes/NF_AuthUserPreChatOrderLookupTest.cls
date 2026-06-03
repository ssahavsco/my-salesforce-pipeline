/*****************************************************************************************************@@
Class Name     :  NF_AuthUserPreChatOrderLookup
Purpose        :  Controller to fethc pre chat details
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Himanshu Mishra        07/19/2025          Initiatl version with MIAW Changes      DP-91108
     
*********************************************************************************************************/
@isTest
public class NF_AuthUserPreChatOrderLookupTest {

    @isTest
    public static void testAuthUser(){
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Customer_Type__c From MessagingSession Where Id =: routableId];
        msgSession.Customer_Type__c = 'Authenticated';
        msgSession.Email__c = 'abc@test.com';
        update msgSession;
        NF_AuthUserOrderLookup.Input input = new NF_AuthUserOrderLookup.Input();
        input.routableId = routableId;
        input.emailAddress = 'abc@test.com';
        input.isOrderFlow = true;
        Test.startTest();
        List<NF_AuthUserOrderLookup.Output> output = NF_AuthUserPreChatOrderLookup.getOrderHistoryFromPreChatDetails(new List<NF_AuthUserOrderLookup.Input>{input});
        Test.stopTest();
    }
    
    @isTest
    public static void testFailedScenario(){
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Customer_Type__c From MessagingSession Where Id =: routableId];
        msgSession.Email__c = 'abc@test.com';
        msgSession.Customer_Type__c = 'Authenticated';
        update msgSession;
        NF_AuthUserOrderLookup.Input input = new NF_AuthUserOrderLookup.Input();
        input.routableId = routableId;
        input.emailAddress = 'abc@test.com';
        input.isOrderFlow = true;
        
        Pre_Chat_Detail__c preChat = new Pre_Chat_Detail__c();
        preChat.Email__c = 'abc@test.com';
        preChat.Order_History_Response__c = 'test';
        
        insert preChat;
        
        Test.startTest();
        List<NF_AuthUserOrderLookup.Output> output = NF_AuthUserPreChatOrderLookup.getOrderHistoryFromPreChatDetails(new List<NF_AuthUserOrderLookup.Input>{input});
        Test.stopTest();
    }
}