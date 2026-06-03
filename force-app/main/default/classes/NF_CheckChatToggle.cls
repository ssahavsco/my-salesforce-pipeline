public with sharing class NF_CheckChatToggle {

    public class Input{
        @InvocableVariable(Required=true)
        public String chatKey = '';

    }

    public class Output{
        @InvocableVariable
        public Boolean isChatTransferOn = true;

        @InvocableVariable
        public Boolean isCaseCreationOn = true;
    }

    @InvocableMethod(Label='Neuraflash - Get Chat Case Toggle')
    public static List<Output> getChatToggle(List<Input> inputs){
        List<Output> result = new List<Output>();
        Output out = new Output();

        String chatKey = inputs[0].chatKey;

        Einstein_Bot_Dialog_Configuration__mdt botConfig = NF_Util.getEinsteinBotDialogConfiguration();

        if(botConfig != null){
            out.isChatTransferOn = botConfig.Live_Chat_Available__c;
            out.isCaseCreationOn = botConfig.Create_Offline_Case__c;
        }
        else{
            System.debug(LoggingLevel.DEBUG,'NF_CheckChatToggle >> getUserInfo failed to retrieve Bot Dialog config');
        }

        result.add(out);
        return result;
    }
}