public with sharing class VSCCSMessagingBotPreChatController {
  @AuraEnabled
  public static ChatLabel getChatLabels(String languageCode) {
    List<ChatLabel> chatLabels = new List<ChatLabel>();
    try {
      ChatLabel clabel = new ChatLabel();
      clabel.endChat = Label.get('', 'Messaging_End_Chat', languageCode);
      clabel.endChatConfirmation = Label.get(
        '',
        'Messaging_End_Chat_Confirmation',
        languageCode
      );
      clabel.goBack = Label.get('', 'Messaging_Go_Back', languageCode);
      clabel.minimizeChat = Label.get(
        '',
        'Messaging_Minimize_Chat',
        languageCode
      );
      clabel.closeChat = Label.get('', 'Messaging_Close_Chat', languageCode);
      clabel.customerCareBotHeaderMessage = Label.get(
        '',
        'NF_CustomerCareBot_HeaderMessage',
        languageCode
      );
      clabel.customerCareBotMessage = Label.get(
        '',
        'NF_CustomerCareBot_Message',
        languageCode
      );
      clabel.customerCareBotChatButton = Label.get(
        '',
        'NF_CustomerCareBot_ChatButton',
        languageCode
      );
      clabel.vsPrivacyLink = Label.get('', 'NF_VS_PrivacyLink', languageCode);
      clabel.chatPrivacyPolicy = Label.get(
        '',
        'Chat_Privacy_Policy',
        languageCode
      );
      clabel.chatPrivacyPolicyFinal = Label.get(
        '',
        'Chat_Privacy_Policy_Final',
        languageCode
      );
      clabel.chatBlocked = Label.get('', 'VSCCS_Chat_Blocked', languageCode);
      clabel.chatBlockedDescription = Label.get(
        '',
        'VSCCS_Chat_Blocked_Description',
        languageCode
      );
      clabel.okMsg = Label.get('', 'VS_Chat_Terms_Conditions_Ok', languageCode);
      clabel.timeOutMessage = Label.get('', 'TimeOutMessage', languageCode);
      clabel.timeOutMsgDisplaySec = Label.get(
        '',
        'TimeOutMsgDisplaySec',
        languageCode
      );
      clabel.monitorChatEndpoint = Label.get('', 'Monitor_Chat_Endpoint');
      clabel.monitorChatInterval = Integer.valueOf(
        Label.get('', 'Monitor_Chat_Interval')
      );
      clabel.chatNotAvailableTimerMessage = Label.get(
        '',
        'Chat_Not_Available_Timer_Message',
        languageCode
      );
      chatLabels.add(clabel);
      return clabel;
    } catch (Exception e) {
      Logger.error(
        'Error while fetching custom labels in PreChat ' + e.getMessage()
      );
      Logger.SaveLog();
      return null;
    }
  }

  public class ChatLabel {
    @AuraEnabled
    public String endChat;
    @AuraEnabled
    public String endChatConfirmation;
    @AuraEnabled
    public String goBack;
    @AuraEnabled
    public String minimizeChat;
    @AuraEnabled
    public String closeChat;
    @AuraEnabled
    public String customerCareBotHeaderMessage;
    @AuraEnabled
    public String customerCareBotMessage;
    @AuraEnabled
    public String customerCareBotChatButton;
    @AuraEnabled
    public String vsPrivacyLink;
    @AuraEnabled
    public String chatPrivacyPolicy;
    @AuraEnabled
    public String chatPrivacyPolicyFinal;
    @AuraEnabled
    public String chatBlocked;
    @AuraEnabled
    public String chatBlockedDescription;
    @AuraEnabled
    public String okMsg;
    @AuraEnabled
    public String timeOutMessage;
    @AuraEnabled
    public String timeOutMsgDisplaySec;
    @AuraEnabled
    public String monitorChatEndpoint;
    @AuraEnabled
    public Integer monitorChatInterval;
    @AuraEnabled
    public String chatNotAvailableTimerMessage;
  }
}