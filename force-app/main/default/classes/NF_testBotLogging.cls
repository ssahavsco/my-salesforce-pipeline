@isTest
public without sharing class NF_testBotLogging {
    @testSetup static void createLCT(){
        LiveChatVisitor liveChatVisitorObj = new LiveChatVisitor();
        insert liveChatVisitorObj;
        
        LiveChatTranscript LCT = new LiveChatTranscript();
        LCT.LiveChatVisitorId = liveChatVisitorObj.Id;
        LCT.ChatKey = 'abc';
        
        insert LCT;
    }
    @isTest static void testLogSession(){
        Integer batchSize = 200;
        LiveChatTranscript LCT = [SELECT ChatKey FROM LiveChatTranscript Limit 1];
        String chatKey = LCT.ChatKey;

        //creates a list of LiveChatTranscripts's to simulate batched invocations of logChat from the bot
        LiveChatVisitor liveChatVisitorObj = new LiveChatVisitor();
        insert liveChatVisitorObj;

        list<LiveChatTranscript> lcts = new list<LiveChatTranscript>();

        for(Integer i = 0;i<batchSize;i++){
            String ck = 'abc'+i;
            lcts.add(new LiveChatTranscript(LiveChatVisitorId =liveChatVisitorObj.Id,ChatKey =ck));
        }

        //creates a list of ChatLoggerRequest's to simulate batched invocations of logChat from the bot
        list<ebotdata.BotChatLogSession.ChatLoggerRequest> clrs = new list<ebotdata.BotChatLogSession.ChatLoggerRequest>();

        for(Integer i = 0;i<batchSize;i++){
            ebotdata.BotChatLogSession.ChatLoggerRequest clr= new ebotdata.BotChatLogSession.ChatLoggerRequest();
            clr.liveAgentSessionId = 'abc'+i;
            clrs.add(clr);
        }

        //invoke logChat->create platform event-> trigger on platform event -> create Bot_Chat_Log__c
        Test.startTest();
        insert lcts;
        ebotdata.BotChatLogSession.logChat(clrs);
        Test.stopTest();

        List<ebotData__Bot_Session__c> bcls= [SELECT id FROM ebotData__Bot_Session__c];
        system.assertEquals(batchSize,bcls.size());

    }
    @isTest static void testLogChat(){
        LiveChatTranscript LCT = [SELECT ChatKey FROM LiveChatTranscript Limit 1];
        String chatKey = LCT.ChatKey;
        insert new ebotData__Bot_Session__c(ebotData__Live_Agent_Session_Id__c=chatKey);
        
        //creates a list of ChatLoggerRequest's to simulate batched invocations of logChat from the bot
        list<ebotdata.BotChatLogger.ChatLoggerRequest> clrs = new list<ebotdata.BotChatLogger.ChatLoggerRequest>();
        ebotdata.BotChatLogger.ChatLoggerRequest clr= new ebotdata.BotChatLogger.ChatLoggerRequest();
        clr.liveAgentSessionId = chatKey;
        Integer batchSize = 200;
        for(Integer i = 0;i<batchSize;i++){
            clrs.add(clr);
        }

        //invoke logChat->create platform event-> trigger on platform event -> create Bot_Chat_Log__c
        Test.startTest();
        ebotdata.BotChatLogger.logChat(clrs);
        Test.stopTest();

        List<ebotData__Bot_Chat_Log__c> bcls= [SELECT id FROM ebotData__Bot_Chat_Log__c];
        system.assertEquals(batchSize,bcls.size());

    }
}