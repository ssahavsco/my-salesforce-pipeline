@isTest
public class VSCCS_BotChatLoggerUpdateBatchTest {
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
      // Create MessagingSession linked to the LCT
      MessagingSession ms = new MessagingSession(
        // Chat_Transcript__c = lct.Id,
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
      // Create LiveChatVisitor
      LiveChatVisitor visitor = new LiveChatVisitor();
      insert visitor;

      // Create LiveChatTranscript linked to visitor
      LiveChatTranscript lct = new LiveChatTranscript(
        Status = 'Completed',
        LiveChatVisitorId = visitor.Id,
        CreatedDate = System.now().addDays(-1),
        Messaging_Session_ID__c = ms.Id
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

      Test.stopTest();
    }

  }

  @isTest
  static void testBatchExecution() {
    // Query test data
    Datetime startDate = Datetime.now().addDays(-2);
    Datetime endDate = Datetime.now().addDays(1);

    // Instantiate the batch class
    VSCCS_BotChatLoggerUpdateBatch batch = new VSCCS_BotChatLoggerUpdateBatch(
      startDate,
      endDate
    );

    // Execute the batch
    Test.startTest();
    Database.executeBatch(batch);
    Test.stopTest();
  }
}