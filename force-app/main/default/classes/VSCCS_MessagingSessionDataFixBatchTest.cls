@isTest
private class VSCCS_MessagingSessionDataFixBatchTest {
  @testSetup
  static void setupTestData() {
    User thisUser = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    System.runAs(thisUser) {
      // Create MessagingChannel
      MessagingChannel objMsgChannel = new MessagingChannel();
      objMsgChannel.MasterLabel = 'TestChannel';
      objMsgChannel.DeveloperName = 'TestChannel';
      objMsgChannel.IsActive = true;
      objMsgChannel.MessageType = 'Text';
      objMsgChannel.MessagingPlatformKey = 'TestChannel';
      insert objMsgChannel;

      // Create MessagingEndUser
      MessagingEndUser objMsgUser = new MessagingEndUser();
      objMsgUser.Name = 'Messaging User';
      objMsgUser.MessagingChannelId = objMsgChannel.Id;
      objMsgUser.MessageType = 'EmbeddedMessaging';
      objMsgUser.MessagingPlatformKey = 'TestChannel';
      insert objMsgUser;

      // Create LiveChatVisitor
      LiveChatVisitor visitor = new LiveChatVisitor();
      insert visitor;

      // Create LiveChatTranscript linked to visitor
      LiveChatTranscript lct = new LiveChatTranscript(
        Status = 'Completed',
        LiveChatVisitorId = visitor.Id,
        CreatedDate = System.now().addDays(-1)
      );
      insert lct;
      Test.startTest();
      // Create LiveChatTranscriptEvents
      List<LiveChatTranscriptEvent> events = new List<LiveChatTranscriptEvent>{
        new LiveChatTranscriptEvent(
          LiveChatTranscriptId = lct.Id,
          Type = 'Transfer',
          Time = System.now().addMinutes(-10)
        ),
        new LiveChatTranscriptEvent(
          LiveChatTranscriptId = lct.Id,
          Type = 'TransferredToButton',
          Time = System.now().addMinutes(-5)
        )
      };
      insert events;

      // Create related Bot Session with escalation = Successful
      ebotdata__Bot_Session__c botSession = new ebotdata__Bot_Session__c(
        ebotdata__Live_Chat_Transcript__c = lct.Id,
        ebotdata__Einstein_Bot_Escalation__c = 'Successful'
      );
      insert botSession;

      // Create MessagingSession linked to the LCT
      MessagingSession ms = new MessagingSession(
        Chat_Transcript__c = lct.Id,
        Status = 'Ended',
        MessagingChannelId = objMsgChannel.Id,
        MessagingEndUserId = objMsgUser.Id
      );
      insert ms;

      // Create MessagingInsight for the session
      Messaging_Insight__c insight = new Messaging_Insight__c(
        Messaging_Session__c = ms.Id
      );
      insert insight;
      Test.stopTest();
    }

  }

  @isTest
  static void testBatchExecution() {
    // Define date range to include our test records
    Datetime startDate = System.now().addDays(-2);
    Datetime endDate = System.now().addDays(1);

    // Run the batch
    VSCCS_MessagingSessionDataFixBatch batch = new VSCCS_MessagingSessionDataFixBatch(
      startDate,
      endDate
    );
    Test.startTest();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify MessagingSession updates
    MessagingSession updatedMs = [
      SELECT AcceptTime, Session_Escalation_Time__c
      FROM MessagingSession
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      updatedMs.AcceptTime,
      'AcceptTime should be set'
    );
    System.assertNotEquals(
      null,
      updatedMs.Session_Escalation_Time__c,
      'Session_Escalation_Time__c should be set'
    );

    // Verify MessagingInsight Session_Escalation__c
    Messaging_Insight__c updatedInsight = [
      SELECT Session_Escalation__c
      FROM Messaging_Insight__c
      LIMIT 1
    ];
    System.assertEquals(
      'Success',
      updatedInsight.Session_Escalation__c,
      'Session_Escalation__c should be Success'
    );
  }
}