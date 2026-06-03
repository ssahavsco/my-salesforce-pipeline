/****************************************************************************************************************
* Program Name         : NF_ChatTranscriptDataFixBatchTest
* Description          : Test class for NF_ChatTranscriptDataFixBatch 
* Version              : 1.1
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   _          		DP-51067      1.1       Manishi      23 Dec,2021       Batch Class for live chat transcripts to populate
																			Actual_Tab_Close_Time__c field.
*     
*****************************************************************************************************************/
@isTest
private class NF_ChatTranscriptDataFixBatchTest {

    // positive testing
    @isTest
    static void testPositiveSingleTranscript() {
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Custom_Chat_End_Time__c,Actual_Tab_Close_Time__c From MessagingSession Where Id =: routableId];
        msgSession.Custom_Chat_End_Time__c = System.now().addMinutes(-20);
        Database.update(msgSession);

        List<MessagingSession> msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        System.assertNotEquals(msgSessions[0].Custom_Chat_End_Time__c, null, 'Custom_Chat_End_Time__c is null');
        System.assertEquals(msgSessions[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c is not null');

        Test.startTest();
        NF_ChatTranscriptDataFixBatch dataFixBatch = new NF_ChatTranscriptDataFixBatch(0);
        Database.QueryLocator ql = dataFixBatch.start(null);
        dataFixBatch.execute(null,msgSessions);
        dataFixBatch.Finish(null);
        Test.stopTest();
		
        msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.debug('msgSessions: ' + msgSessions);
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        //System.assertNotEquals(chatTranscripts[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c was not populated');
    }
    
    // negative testing
    @isTest
    static void testNegativeSingleTranscript() {
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Custom_Chat_End_Time__c,Actual_Tab_Close_Time__c From MessagingSession Where Id =: routableId];
        DateTime closingTime = System.now().addMinutes(-20);
        msgSession.Custom_Chat_End_Time__c = closingTime;
        msgSession.Actual_Tab_Close_Time__c = closingTime;
        Database.update(msgSession);

        List<MessagingSession> msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        System.assertNotEquals(msgSessions[0].Custom_Chat_End_Time__c, null, 'Custom_Chat_End_Time__c is null');
        System.assertNotEquals(msgSessions[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c is null');

        Test.startTest();
        NF_ChatTranscriptDataFixBatch dataFixBatch = new NF_ChatTranscriptDataFixBatch();
        Database.QueryLocator ql = dataFixBatch.start(null);
        dataFixBatch.execute(null,msgSessions);
        dataFixBatch.Finish(null);
        Test.stopTest();
		
        msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.debug('msgSessions: ' + msgSessions);
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        //System.assertEquals(msgSessions[0].Actual_Tab_Close_Time__c, closingTime, 'Actual_Tab_Close_Time__c was changed');
    }
    
    // testing other constructors, double parameters
    @isTest
    static void testPositiveSingleTranscriptCon2() {
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Custom_Chat_End_Time__c,Actual_Tab_Close_Time__c From MessagingSession Where Id =: routableId];
        msgSession.Custom_Chat_End_Time__c = System.now().addMinutes(-70);
        Database.update(msgSession);

        List<MessagingSession> msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        System.assertNotEquals(msgSessions[0].Custom_Chat_End_Time__c, null, 'Custom_Chat_End_Time__c is null');
        System.assertEquals(msgSessions[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c is not null');

        String queryString = 'Select Id, Custom_Chat_End_Time__c, Actual_Tab_Close_Time__c, StartTime FROM MessagingSession WHERE Actual_Tab_Close_Time__c = NULL AND StartTime <= :todays AND StartTime >= :twoDaysAgo';
        Integer numberOfHoursBefore = 0;
        Test.startTest();
        NF_ChatTranscriptDataFixBatch dataFixBatch = new NF_ChatTranscriptDataFixBatch(queryString, numberOfHoursBefore);
        Database.QueryLocator ql = dataFixBatch.start(null);
        dataFixBatch.execute(null,msgSessions);
        dataFixBatch.Finish(null);
        Test.stopTest();
		
        msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.debug('msgSessions: ' + msgSessions);
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
       // System.assertNotEquals(msgSessions[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c was not populated');
    }
    
    // testing other constructors, single params.
    @isTest
    static void testPositiveSingleTranscriptCon1() {
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Custom_Chat_End_Time__c,Actual_Tab_Close_Time__c From MessagingSession Where Id =: routableId];
        msgSession.Custom_Chat_End_Time__c = System.now().addMinutes(-200);
        Database.update(msgSession);

        List<MessagingSession> msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        System.assertNotEquals(msgSessions[0].Custom_Chat_End_Time__c, null, 'Custom_Chat_End_Time__c is null');
        System.assertEquals(msgSessions[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c is not null');

        String queryString = 'Select Id, Custom_Chat_End_Time__c, Actual_Tab_Close_Time__c, StartTime FROM LiveChatTranscript WHERE Actual_Tab_Close_Time__c = NULL AND StartTime <= :todays AND StartTime >= :twoDaysAgo';
        Test.startTest();
        NF_ChatTranscriptDataFixBatch dataFixBatch = new NF_ChatTranscriptDataFixBatch(queryString);
        Database.QueryLocator ql = dataFixBatch.start(null);
        dataFixBatch.execute(null,msgSessions);
        dataFixBatch.Finish(null);
        Test.stopTest();
		
        msgSessions = [SELECT Id, Actual_Tab_Close_Time__c, Custom_Chat_End_Time__c From MessagingSession];
        System.debug('msgSessions: ' + msgSessions);
        System.assertEquals(msgSessions.size(), 1, 'More than one transcripts exist');
        //System.assertNotEquals(msgSessions[0].Actual_Tab_Close_Time__c, null, 'Actual_Tab_Close_Time__c was not populated');
    }

}