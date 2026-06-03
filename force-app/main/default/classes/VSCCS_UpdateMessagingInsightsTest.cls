@IsTest
public class VSCCS_UpdateMessagingInsightsTest {
  @TestSetup
  static void setupTestData() {
    // Create a user to use with System.runAs
    User testUser = createTestUser();

    // Perform setup object DML inside System.runAs
    /*MessagingChannel channel;
    MessagingEndUser endUser;
    System.runAs(testUser) {
      // Create test data for MessagingChannel
      channel = new MessagingChannel();
      channel.DeveloperName = 'TestChannel';
      channel.MasterLabel = 'Test Channel';
      channel.MessageType = 'EmbeddedMessaging'; // Example value, replace with valid type
      channel.MessagingPlatformKey = 'TestPlatformKey';
      insert channel;

      // Create test data for MessagingEndUser
      endUser = new MessagingEndUser();
      endUser.Name = 'Test End User';
      endUser.MessageType = 'EmbeddedMessaging'; // Example value, replace with valid type
      endUser.MessagingChannelId = channel.Id;
      endUser.MessagingPlatformKey = 'TestEndUserKey';
      insert endUser;
    }

    // Create test data for MessagingSession
    MessagingSession session = new MessagingSession();
    session.MessagingChannelId = channel.Id;
    session.MessagingEndUserId = endUser.Id;
    session.ConversationId = '0dwVD000006rESnYAM';
    session.Status = 'New'; // Example value, replace with valid status
    insert session;
	*/
    // Create test data for Messaging_Insight__c
    Messaging_Insight__c insight = new Messaging_Insight__c();
    insight.Messaging_Session__c = VS_UtilTest.createMessagingSession();
    insight.CarouselContent__c = 'Test Payload';
    insert insight;
  }

  @IsTest
  static void testSetField() {
    // Query the test Messaging Session and Insight
    MessagingSession testSession = [SELECT Id FROM MessagingSession LIMIT 1];
    Messaging_Insight__c testInsight = [
      SELECT Id, Successful_Resolution__c, Session_Escalation__c
      FROM Messaging_Insight__c
      WHERE Messaging_Session__c = :testSession.Id
      LIMIT 1
    ];

    // Prepare input parameters
    VSCCS_UpdateMessagingInsights.Input input = new VSCCS_UpdateMessagingInsights.Input();
    input.routableId = testSession.Id;
    input.field = 'Successful_Resolution__c';
    input.value = 'Yes';

    // Call the method being tested
    VSCCS_UpdateMessagingInsights.setField(
      new List<VSCCS_UpdateMessagingInsights.Input>{ input }
    );

    // Verify the field was updated
    Messaging_Insight__c updatedInsight = [
      SELECT Successful_Resolution__c
      FROM Messaging_Insight__c
      WHERE Id = :testInsight.Id
    ];
    System.assertEquals(
      'Yes',
      updatedInsight.Successful_Resolution__c,
      'Successful_Resolution__c should be updated to Yes'
    );

    // Test with invalid routableId
    try {
      input.routableId = null;
      VSCCS_UpdateMessagingInsights.setField(
        new List<VSCCS_UpdateMessagingInsights.Input>{ input }
      );
      /*System.assert(
        false,
        'Method should throw an exception for an invalid routableId'
      );*/
    } catch (Exception e) {
      System.assert(
        e.getMessage().contains('InvalidId'),
        'Exception message should indicate invalid routableId'
      );
    }
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
}