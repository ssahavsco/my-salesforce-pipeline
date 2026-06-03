@isTest
public class VS_SetChatButtonNameTest {
    @isTest
    public static void techTeamChatButtonMethod(){
        Test.startTest();
        VS_SetChatButtonName.Input input = new VS_SetChatButtonName.Input();
        input.userEmail = Label.TechTeamEmail;
        List<VS_SetChatButtonName.Output> output = VS_SetChatButtonName.setChatButtonName(new List<VS_SetChatButtonName.Input>{input});
        System.assertEquals('Customer_Care_Tech_Team', output[0].chatButtonName);
        Test.stopTest();
    }
    
   @isTest
    public static void intlChatButtonMethod(){
        Test.startTest();
        VS_SetChatButtonName.Input input = new VS_SetChatButtonName.Input();
        input.orderType = 'Global-e';
        List<VS_SetChatButtonName.Output> output = VS_SetChatButtonName.setChatButtonName(new List<VS_SetChatButtonName.Input>{input});
        System.assertEquals('Special_Handling_Chat_INTL', output[0].chatButtonName);
        Test.stopTest();
    } 
    
    @isTest
    public static void defaultChatButtonMethod(){
        Test.startTest();
        VS_SetChatButtonName.Input input = new VS_SetChatButtonName.Input();
        input.orderType = 'Eshop';
        List<VS_SetChatButtonName.Output> output = VS_SetChatButtonName.setChatButtonName(new List<VS_SetChatButtonName.Input>{input});
        System.assertEquals('Customer_Care_Bot_Availability', output[0].chatButtonName);
        Test.stopTest();
    }
}