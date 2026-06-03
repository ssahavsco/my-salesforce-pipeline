@IsTest
public class VS_UtilTest {

  public static String createMessagingSession() {
    String channelId = createMessagingChannel();
    MessagingEndUser endUser = new MessagingEndUser();
    endUser.Name = 'Test End User'; // Required field
    endUser.MessageType = 'EmbeddedMessaging'; // Required field
    endUser.MessagingChannelId = channelId; // Required field
    endUser.MessagingPlatformKey = 'Test User'; // Required field
    insert endUser;

    MessagingSession session = new MessagingSession();
    session.MessagingChannelId = channelId;
    session.MessagingEndUserId = endUser.Id;
    session.Status = 'Ended';
    session.AgentType = 'Agent';
    insert session;

    return session.Id;
  }
    
  public static String createMessagingChannel() {
    User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();
    MessagingChannel channel;
    System.runAs(platformIntegrationUser) {
      channel = new MessagingChannel();
      channel.DeveloperName = 'Test_Channel';
      channel.MasterLabel = 'Test Channel';
      channel.MessageType = 'EmbeddedMessaging';
      channel.MessagingPlatformKey = 'Test Channel';
      insert channel;
    }
    return channel.Id;
  }
}