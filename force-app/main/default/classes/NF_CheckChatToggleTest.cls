/**
 * Created by adamundus on 9/14/20.
 */

@IsTest
private class NF_CheckChatToggleTest {
    static String chatkey = 'abc';
    @IsTest
    static void testBehavior() {
        List<NF_CheckChatToggle.Input> inputs = new List<NF_CheckChatToggle.Input>();
        NF_CheckChatToggle.Input inp = new NF_CheckChatToggle.Input();
        inp.chatKey = chatkey;
        inputs.add(inp);
        Einstein_Bot_Dialog_Configuration__mdt config = NF_Util.getEinsteinBotDialogConfiguration();

        Test.startTest();
        List<NF_CheckChatToggle.Output> out = NF_CheckChatToggle.getChatToggle(inputs);
        Test.stopTest();

        Einstein_Bot_Dialog_Configuration__mdt botConfig = NF_Util.getEinsteinBotDialogConfiguration();

        if (botConfig != null) {
            System.assertEquals(botConfig.Create_Offline_Case__c, out[0].isCaseCreationOn);
            System.assertEquals(botConfig.Live_Chat_Available__c, out[0].isChatTransferOn);
        }
        else{
            System.assertEquals(true, out[0].isCaseCreationOn);
            System.assertEquals(true, out[0].isChatTransferOn);
        }
    }
}