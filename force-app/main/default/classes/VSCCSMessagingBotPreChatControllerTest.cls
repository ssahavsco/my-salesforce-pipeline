@isTest
public class VSCCSMessagingBotPreChatControllerTest {

    @isTest
    public static void testGetChatLables(){
        VSCCSMessagingBotPreChatController.ChatLabel chatLabels = VSCCSMessagingBotPreChatController.getChatLabels('en_US');
    }
}