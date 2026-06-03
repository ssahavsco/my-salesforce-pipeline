@isTest
private class VSCCS_LCT_TransferTo_MS_Batch_Test {
  @testSetup
  static void setupTestData() {
    // Create Test LiveChatTranscript
    List<LiveChatTranscript> transcripts = new List<LiveChatTranscript>();
    for (Integer i = 0; i < 5; i++) {
      LiveChatVisitor livechatvisitor = new LiveChatVisitor();
      insert livechatvisitor;
      LiveChatTranscript lct = new LiveChatTranscript(
        ContactId = null,
        AccountId = null,
        CaseId = null,
        LiveChatVisitorId = livechatvisitor.id,
        OwnerId = UserInfo.getUserId(),
        StartTime = System.now().addDays(-1),
        EndTime = System.now(),
        CreatedDate = System.now().addDays(-1),
        ChatKey = 'ChatKey' + i,
        Status = 'Completed'
      );
      transcripts.add(lct);
    }
    insert transcripts;

    // Create Bot Sessions
    List<ebotdata__Bot_Session__c> botSessions = new List<ebotdata__Bot_Session__c>();
    for (LiveChatTranscript lct : transcripts) {
      ebotdata__Bot_Session__c bs = new ebotdata__Bot_Session__c(
        ebotdata__Live_Chat_Transcript__c = lct.Id,
        ebotdata__BotName__c = 'TestBot'
      );
      botSessions.add(bs);
    }
    insert botSessions;

    // Create Bot Chat Logs
    List<ebotdata__Bot_Chat_Log__c> chatLogs = new List<ebotdata__Bot_Chat_Log__c>();
    for (ebotdata__Bot_Session__c bs : botSessions) {
      ebotdata__Bot_Chat_Log__c log = new ebotdata__Bot_Chat_Log__c(
        ebotdata__Bot_Session__c = bs.Id,
        ebotdata__Current_Dialog_Id__c = 'Dialog1'
      );
      chatLogs.add(log);
    }
    insert chatLogs;
  }

  @isTest
  static void testBatchExecution() {
    Test.startTest();
    DateTime startDate = System.now().addDays(-2);
    DateTime endDate = System.now();
    VSCCS_LCT_TransferTo_MS_Batch batch = new VSCCS_LCT_TransferTo_MS_Batch(
      startDate,
      endDate
    );
    Database.executeBatch(batch, 5);
    Test.stopTest();

    // Verify MessagingEndUsers
    List<MessagingEndUser> endUsers = [SELECT Id FROM MessagingEndUser];
    System.assert(endUsers.size() > 0, 'MessagingEndUsers should be created');

    // Verify MessagingSessions
    List<MessagingSession> sessions = [SELECT Id FROM MessagingSession];
    System.assert(sessions.size() > 0, 'MessagingSessions should be created');

    // Verify Messaging Bot Sessions
    // List<Messaging_Bot_Session__c> botSessions = [
    //   SELECT Id
    //   FROM Messaging_Bot_Session__c
    // ];
    // System.assert(
    //   botSessions.size() > 0,
    //   'Messaging Bot Sessions should be created'
    // );

    // Verify Messaging Bot Chat Logs
    // List<Messaging_Bot_Chat_Log__c> botChatLogs = [
    //   SELECT Id
    //   FROM Messaging_Bot_Chat_Log__c
    // ];
    // System.assert(
    //   botChatLogs.size() > 0,
    //   'Messaging Bot Chat Logs should be created'
    // );
  }
}