@IsTest
public class VSCCS_Messaging_BotChatLoggerTest {
  @TestSetup
  static void setupTestData() {
    // Create a test user
    /*User testUser = createTestUser();

    // Perform setup object DML inside System.runAs
    MessagingChannel channel;
    MessagingEndUser endUser;
    LiveChatTranscript liveChatTranscript;
    System.runAs(testUser) {
      // Create test data for MessagingChannel
      channel = new MessagingChannel();
      channel.DeveloperName = 'TestChannel';
      channel.MasterLabel = 'Test Channel';
      channel.MessageType = 'EmbeddedMessaging';
      channel.MessagingPlatformKey = 'TestPlatformKey';
      insert channel;

      // Create test data for MessagingEndUser
      endUser = new MessagingEndUser();
      endUser.Name = 'Test End User';
      endUser.MessageType = 'EmbeddedMessaging';
      endUser.MessagingChannelId = channel.Id;
      endUser.MessagingPlatformKey = 'TestEndUserKey';
      insert endUser;
    }
    // Create LiveChatVisitor
    LiveChatVisitor visitor = new LiveChatVisitor();
    insert visitor;
    // Create test data for LiveChatTranscript
    liveChatTranscript = new LiveChatTranscript();
    liveChatTranscript.OwnerId = testUser.Id;
    liveChatTranscript.LiveChatVisitorId = visitor.Id;
    liveChatTranscript.Status = 'Completed';
    insert liveChatTranscript;
    // Create test data for MessagingSession
    MessagingSession session = new MessagingSession();
    session.MessagingChannelId = channel.Id;
    session.MessagingEndUserId = endUser.Id;
    session.ConversationId = '0dwVD000006rESnYAM';
    session.Status = 'New';
    insert session;
	*/
    // Create test data for Messaging_Insight__c
    Messaging_Insight__c insight = new Messaging_Insight__c();
    insight.Messaging_Session__c = VS_UtilTest.createMessagingSession();
    insight.CarouselContent__c = 'Test Payload';
    insert insight;
    // Ensure the Dialog_Setting__mdt record exists in the org
    Dialog_Setting__mdt dialogSetting = [
      SELECT
        DeveloperName,
        Dialog_Api_Name__c,
        Metric__c,
        Escalation_Outcome__c,
        Contact_Code_Type__c,
        Contact_Code_Sub_Type__c,
        Contact_Code_Description__c,
        Escalation_Reason__c,
        Topic_Name__c
      FROM Dialog_Setting__mdt
      WHERE Dialog_Api_Name__c = 'bus_feedback_store'
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      dialogSetting,
      'Dialog_Setting__mdt record should exist for bus_feedback_store.'
    );
  }

  // Helper method to create a test user
  private static User createTestUser() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];

    String uniqueUsername =
      'testuser+' +
      DateTime.now().getTime() +
      '@example.com';

    User testUser = new User(
      Alias = 'testuser',
      Email = 'testuser@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profile.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = uniqueUsername
    );
    insert testUser;
    return testUser;
  }

  @IsTest
  static void testLogChat_DynamicFieldMapping() {
    // Query the test MessagingSession and Messaging_Insight__c
    MessagingSession session = [SELECT Id FROM MessagingSession LIMIT 1];
    Messaging_Insight__c insight = [
      SELECT Id
      FROM Messaging_Insight__c
      WHERE Messaging_Session__c = :session.Id
      LIMIT 1
    ];

    // Prepare the ChatLoggerRequest
    VSCCS_Messaging_BotChatLogger.ChatLoggerRequest request = new VSCCS_Messaging_BotChatLogger.ChatLoggerRequest();
    request.currentDialogName = 'bus_feedback_store';
    request.currentConfidenceForUtterance = 0.95;
    request.currentDialogId = 'Dialog123';
    request.currentThresholdHigh = 0.9;
    request.currentUtterance = 'Test utterance';
    request.liveAgentSessionId = 'LiveAgent123';
    request.routableId = session.Id;

    // Call the logChat method
    Test.startTest();
    VSCCS_Messaging_BotChatLogger.logChat(
      new List<VSCCS_Messaging_BotChatLogger.ChatLoggerRequest>{ request }
    );
    Test.stopTest();

    // Verify the Messaging_Bot_Chat_Log__c record
    Messaging_Bot_Chat_Log__c[] chatLog = [
      SELECT
        Business_Metric_Type__c,
        Escalation_Result__c,
        Data_Field_1__c,
        Data_Field_2__c,
        Data_Field_4__c,
        Escalation_Reason__c,
        Topic_Name__c,
        Current_Confidence_For_Utterance__c,
        Current_Dialog_Id__c,
        Current_Dialog_Name__c,
        Current_Threshold_High__c,
        Current_Utterance__c,
        Live_Agent_Session_Id__c
      FROM Messaging_Bot_Chat_Log__c
      WHERE Messaging_Insight__c = :insight.Id
      LIMIT 1
    ];
    /*System.assertNotEquals(
      null,
      chatLog[0],
      'Messaging_Bot_Chat_Log__c record should exist.'
    );
    System.assertEquals(
      'Business End',
      chatLog[0].Business_Metric_Type__c,
      'Business_Metric_Type__c should match'
    );
    System.assertEquals(
      null,
      chatLog[0].Escalation_Result__c,
      'Escalation_Result__c should match'
    );
    System.assertEquals(
      'Miscellaneous',
      chatLog[0].Data_Field_1__c,
      'Data_Field_1__c should match'
    );
    System.assertEquals(
      'Company Information',
      chatLog.Data_Field_2__c,
      'Data_Field_2__c should match'
    );
    System.assertEquals(
      'VS STORE FEEDBACK:',
      chatLog.Data_Field_4__c,
      'Data_Field_4__c should match'
    );
    System.assertEquals(
      'By Design',
      chatLog.Escalation_Reason__c,
      'Escalation_Reason__c should match'
    );
    System.assertEquals(
      'Miscellaneous',
      chatLog.Topic_Name__c,
      'Topic_Name__c should match'
    );
    System.assertEquals(
      0.95,
      chatLog.Current_Confidence_For_Utterance__c,
      'Current_Confidence_For_Utterance__c should match'
    );
    System.assertEquals(
      'Dialog123',
      chatLog.Current_Dialog_Id__c,
      'Current_Dialog_Id__c should match'
    );
    System.assertEquals(
      'bus_feedback_store',
      chatLog.Current_Dialog_Name__c,
      'Current_Dialog_Name__c should match'
    );
    System.assertEquals(
      0.9,
      chatLog.Current_Threshold_High__c,
      'Current_Threshold_High__c should match'
    );
    System.assertEquals(
      'Test utterance',
      chatLog.Current_Utterance__c,
      'Current_Utterance__c should match'
    );
    System.assertEquals(
      'LiveAgent123',
      chatLog.Live_Agent_Session_Id__c,
      'Live_Agent_Session_Id__c should match'
    );*/
  }

  @IsTest
  static void testLogChat_EscalationTimeUpdate() {
    Messaging_Insight__c testBotSession = [
      SELECT Id, Messaging_Session__c
      FROM Messaging_Insight__c
      LIMIT 1
    ];

    List<VSCCS_Messaging_BotChatLogger.ChatLoggerRequest> chatLogRequests = new List<VSCCS_Messaging_BotChatLogger.ChatLoggerRequest>();

    VSCCS_Messaging_BotChatLogger.ChatLoggerRequest request = new VSCCS_Messaging_BotChatLogger.ChatLoggerRequest();
    request.routableId = testBotSession.Messaging_Session__c;
    request.currentDialogId = '54321';
    request.currentDialogName = 'bot_transfer_notAvailable'; // triggers escalation
    request.currentConfidenceForUtterance = 0.75;

    chatLogRequests.add(request);

    Test.startTest();
    VSCCS_Messaging_BotChatLogger.logChat(chatLogRequests);
    Test.stopTest();

    // Verify that the parent MessagingSession was updated
    MessagingSession updatedSession = [
      SELECT Id, Session_Escalation_Time__c
      FROM MessagingSession
      WHERE Id = :testBotSession.Messaging_Session__c
    ];

    /*System.assertNotEquals(
      null,
      updatedSession.Session_Escalation_Time__c,
      'Escalation Time should be updated on the parent MessagingSession.'
    );*/
  }

  @IsTest
  static void testLogChat_NoRequests() {
    List<VSCCS_Messaging_BotChatLogger.ChatLoggerRequest> emptyRequests = new List<VSCCS_Messaging_BotChatLogger.ChatLoggerRequest>();

    Test.startTest();
    VSCCS_Messaging_BotChatLogger.logChat(emptyRequests);
    Test.stopTest();

    List<Messaging_Bot_Chat_Log__c> insertedLogs = [
      SELECT Id
      FROM Messaging_Bot_Chat_Log__c
    ];
    System.assertEquals(
      0,
      insertedLogs.size(),
      'No chat log records should be inserted.'
    );
  }
}