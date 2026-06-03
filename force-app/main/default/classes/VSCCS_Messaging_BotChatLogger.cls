global class VSCCS_Messaging_BotChatLogger {
  @InvocableMethod(label='VS - Messaging Bot Chat Log')
  global static void logChat(List<ChatLoggerRequest> chatLogRequests) {
    List<Messaging_Bot_Chat_Log__c> mChatlogs = new List<Messaging_Bot_Chat_Log__c>();
    Map<Id, Messaging_Insight__c> insightsToUpdate = new Map<Id, Messaging_Insight__c>();
    Map<Id, MessagingSession> sessionsToUpdate = new Map<Id, MessagingSession>();

    // ChatLoggerRequest will have only one record one each dialog execution
    ChatLoggerRequest request = (chatLogRequests != null &&
      !chatLogRequests.isEmpty())
      ? chatLogRequests[0]
      : null;

    // Track whether this dialog is a "Business End"
    Boolean isBusinessDialogReached = false;

    // Check Dialog Setting metadata for this dialog
    Dialog_Setting__mdt dialogSetting;
    if (request != null && String.isNotBlank(request.currentDialogName)) {
      List<Dialog_Setting__mdt> dialogSettings = [
        SELECT
          Metric__c,
          Type__c,
          Escalation_Outcome__c,
          Contact_Code_Type__c,
          Contact_Code_Sub_Type__c,
          Contact_Code_Description__c,
          Escalation_Reason__c,
          Topic_Name__c
        FROM Dialog_Setting__mdt
        WHERE Dialog_Api_Name__c = :request.currentDialogName
      ];
      if (!dialogSettings.isEmpty()) {
        dialogSetting = dialogSettings[0];
        isBusinessDialogReached = (dialogSetting.Metric__c == 'Business End' &&
        dialogSetting.Type__c == 'Business');
      }
    }

    //Process the request
    if (request != null) {
      Id botSessionId = getFirstMessagingInsight(request.routableId);
      Messaging_Bot_Chat_Log__c mChatLog = new Messaging_Bot_Chat_Log__c(
        Messaging_Insight__c = botSessionId,
        Current_Confidence_For_Utterance__c = request.currentConfidenceForUtterance !=
          null
          ? request.currentConfidenceForUtterance
          : 0,
        Current_Dialog_Id__c = String.isNotBlank(request.currentDialogId)
          ? request.currentDialogId
          : '',
        Current_Dialog_Name__c = String.isNotBlank(request.currentDialogName)
          ? request.currentDialogName
          : '',
        Current_Threshold_High__c = request.currentThresholdHigh != null
          ? request.currentThresholdHigh
          : 0,
        Current_Utterance__c = String.isNotBlank(request.currentUtterance)
          ? request.currentUtterance
          : '',
        Live_Agent_Session_Id__c = String.isNotBlank(request.liveAgentSessionId)
          ? request.liveAgentSessionId
          : '',
        Business_Metric_Type__c = dialogSetting != null
          ? dialogSetting.Metric__c
          : null,
        Escalation_Result__c = dialogSetting != null
          ? dialogSetting.Escalation_Outcome__c
          : null,
        Data_Field_1__c = dialogSetting != null
          ? dialogSetting.Contact_Code_Type__c
          : null,
        Data_Field_2__c = dialogSetting != null
          ? dialogSetting.Contact_Code_Sub_Type__c
          : null,
        Data_Field_4__c = dialogSetting != null
          ? dialogSetting.Contact_Code_Description__c
          : null,
        Escalation_Reason__c = dialogSetting != null
          ? dialogSetting.Escalation_Reason__c
          : null,
        Topic_Name__c = dialogSetting != null
          ? dialogSetting.Topic_Name__c
          : null
      );
      mChatlogs.add(mChatLog);
      if (
        botSessionId != null &&
        (request.currentDialogName == 'bot_transfer_notAvailable' ||
        request.currentDialogName == 'No_Agent_Available')
      ) {
        Messaging_Insight__c escalationUpdate = insightsToUpdate.containsKey(
            botSessionId
          )
          ? insightsToUpdate.get(botSessionId)
          : new Messaging_Insight__c(Id = botSessionId);
        escalationUpdate.Session_Escalation__c = 'Turned Away';
        insightsToUpdate.put(botSessionId, escalationUpdate);
      }
      // Track business dialog reached
      if (botSessionId != null && isBusinessDialogReached) {
        Messaging_Insight__c businessUpdate = insightsToUpdate.containsKey(
            botSessionId
          )
          ? insightsToUpdate.get(botSessionId)
          : new Messaging_Insight__c(Id = botSessionId);
        businessUpdate.Business_Dialog_Reached__c = true;
        insightsToUpdate.put(botSessionId, businessUpdate);
      }
      //Track self service dialog reached
      if (request.currentDialogName == 'bot_followup_start') {
        Messaging_Insight__c selfServiceUpdate = insightsToUpdate.containsKey(
            botSessionId
          )
          ? insightsToUpdate.get(botSessionId)
          : new Messaging_Insight__c(Id = botSessionId);
        selfServiceUpdate.Self_Served_Dialog_Reached__c = true;
        insightsToUpdate.put(botSessionId, selfServiceUpdate);
      }
    }

    // Insert chat logs
    if (!mChatlogs.isEmpty()) {
      try {
        insert mChatlogs;
      } catch (DmlException e) {
        Logger.error('Error inserting chat logs: ' + e.getMessage(), e);
        Logger.saveLog();
      }
    } else {
      Logger.warn('No valid chat log entries to insert.');
    }

    // Update insight records
    if (!insightsToUpdate.isEmpty()) {
      try {
        update insightsToUpdate.values();
      } catch (DmlException e) {
        Logger.error(
          'Error updating Messaging_Insight__c records: ' + e.getMessage(),
          e
        );
      }
      Logger.saveLog();
    }
    //Update MessagingSesssion records
    if (!sessionsToUpdate.isEmpty()) {
      try {
        update sessionsToUpdate.values();
      } catch (DmlException e) {
        Logger.error(
          'Error updating parent MessagingSession records: ' + e.getMessage(),
          e
        );
        Logger.saveLog();
      }
    }
  }

  public static String getFirstMessagingInsight(String parentRecordId) {
    try {
      List<Messaging_Insight__c> botMSessions = [
        SELECT Id
        FROM Messaging_Insight__c
        WHERE Messaging_Session__c = :parentRecordId
        ORDER BY CreatedDate ASC
        LIMIT 1
      ];
      return botMSessions.isEmpty() ? null : botMSessions[0].Id;
    } catch (QueryException e) {
      return null;
    }
  }

  global class ChatLoggerRequest {
    @InvocableVariable(required=false)
    global Decimal currentConfidenceForUtterance;
    @InvocableVariable(required=false)
    global String currentDialogId;
    @InvocableVariable(required=false)
    global String currentDialogName;
    @InvocableVariable(required=false)
    global Decimal currentThresholdHigh;
    @InvocableVariable(required=false)
    global String currentUtterance;
    @InvocableVariable(required=false)
    global String liveAgentSessionId;
    @InvocableVariable(required=false)
    global Id routableId;
  }
}