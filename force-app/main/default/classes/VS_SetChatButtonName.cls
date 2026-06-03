public with sharing class VS_SetChatButtonName {
    public class Input{
        @InvocableVariable
        public String userEmail;
        @InvocableVariable
        public String orderEmail;
        @InvocableVariable
        public String orderType;
    }
    public class Output{
        @InvocableVariable
        public String chatButtonName;
    }
    @InvocableMethod(label='VS - Set Chat Button Name')
    public static List<Output> setChatButtonName(List<Input> input){
        List<Output> outputList = new List<Output>();
        Output out = new Output();
        String userEmail = Label.TechTeamEmail;
        if(userEmail.equalsIgnoreCase(input[0].userEmail) || userEmail.equalsIgnoreCase(input[0].orderEmail)){
            out.chatButtonName = 'Customer_Care_Tech_Team';
        } else if(input[0].orderType == 'Global-e'){
            out.chatButtonName = 'Special_Handling_Chat_INTL';
        } else {
            out.chatButtonName = 'Customer_Care_Bot_Availability';
        }
        outputList.add(out);
        return outputList;
    }
}