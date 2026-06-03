/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Description : This Batch Class will transfer data from LiveChatTranscript objects to MessagingSession Objects
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Sharath Vadla  <svadla@victoria.com>
 * @version        1.0
 * @created        03/12/2025
 * @modified       03/28/2025
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * Modifications Log
 * Ver   Story#       Date         Author              Modification
 * 1.0   CCS-913      03/12/2025   Sharath Vadla       Initial Version.
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
global class VSCCS_LCT_TransferTo_MS_Batch implements Database.Batchable<sObject>, Database.Stateful {
  private DateTime startDate;
  private DateTime endDate;

  // Mapping of Old LiveChatTranscript Ids to New MessagingSession Ids
  private Map<Id, Id> sessionMap = new Map<Id, Id>();

  // Mapping of Old BotSession Ids to New MessagingBotSession Ids
  private Map<Id, Id> botSessionMap = new Map<Id, Id>();

  // Messaging Channel ID Cached
  private Id messagingChannelId;

  // Constructor to Accept Date Parameters
  global VSCCS_LCT_TransferTo_MS_Batch(DateTime startDate, DateTime endDate) {
    this.startDate = startDate;
    this.endDate = endDate;
    this.messagingChannelId = getMessagingChannelId();
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('Batch Started');

    return Database.getQueryLocator(
      [
        SELECT
          Id,
          ContactId,
          AccountId,
          CaseId,
          OwnerId,
          StartTime,
          EndTime,
          CreatedDate,
          CreatedById,
          LastModifiedDate,
          LastModifiedById,
          ChatKey,
          Customer_Email__c,
          Email__c,
          Case_Lookup__c,
          Status,
          IpAddress,
          Location,
          BrowserLanguage,
          Contact.Name,
          EndedBy,
          AverageResponseTimeOperator,
          AverageResponseTimeVisitor,
          OperatorMessageCount,
          VisitorMessageCount,
          MaxResponseTimeOperator,
          MaxResponseTimeVisitor,
          IsUserAuthenticated__c,
          Actual_Tab_Close_Time__c,
          Custom_Chat_End_Time__c,
          Language_Code__c,
          FirstName__c,
          LastName__c,
          Page_Name__c,
          Page_URL__c,
          Button_Type__c,
          LiveChatButton.DeveloperName,
          Platform,
          Browser,
          Messaging_Session_ID__c
        FROM LiveChatTranscript
        WHERE
          CreatedDate >= :startDate
          AND CreatedDate <= :endDate
          AND Messaging_Session_ID__c = NULL
      ]
    );
  }

  global void execute(
    Database.BatchableContext BC,
    List<LiveChatTranscript> liveChatList
  ) {
    if (liveChatList.isEmpty()) {
      System.debug('No LiveChatTranscript records found for processing.');
      return;
    }

    System.debug('Processing LiveChatTranscript Records');

    Set<Id> liveChatIds = new Set<Id>();
    for (LiveChatTranscript lct : liveChatList) {
      liveChatIds.add(lct.Id);
    }

    try {
      // Query related Bot Sessions
      Map<Id, ebotdata__Bot_Session__c> botSessionsMap = new Map<Id, ebotdata__Bot_Session__c>();
      for (ebotdata__Bot_Session__c bs : [
        SELECT
          Id,
          ebotdata__Chat_Button_Name__c,
          ebotdata__Live_Chat_Transcript__c,
          ebotdata__BotName__c,
          CreatedDate,
          LastModifiedDate,
          CreatedById,
          OwnerId,
          LastModifiedById,
          Loyalty_Id__c,
          Order_Number__c,
          Loyalty_Status__c,
          ebotdata__Chat_Button_Id__c,
          Customer_Full_Name__c,
          ebotdata__Successful_Resolution__c,
          ebotdata__Escalation_Reason__c,
          ebotdata__Chat_Channel__c,
          Chat_Satisfaction__c,
          Overall_Experience__c,
          Would_Recommend_VS__c,
          ebotdata__Einstein_Bot_Duration__c,
          ebotdata__Visitor_Contact__c,
          ebotdata__Case__c,
          CarouselContent__c,
          PostChat_Comments__c,
          ebotdata__Business_Dialog_Reached__c,
          ebotdata__Einstein_Bot_Escalation_Successful__c,
          ebotdata__Escalation_By_Design__c,
          Is_User_HTO_Subscribed__c,
          IsUserAuthenticated__c,
          ebotdata__Self_Served_Dialog_Reached__c,
          ebotdata__Escalation_End_Reached__c,
          Customer_Type__c
        FROM ebotdata__Bot_Session__c
        WHERE ebotdata__Live_Chat_Transcript__c IN :liveChatIds
      ]) {
        botSessionsMap.put(bs.Id, bs);
      }

      // Query related Bot Chat Logs
      Map<Id, List<ebotdata__Bot_Chat_Log__c>> botChatLogMap = new Map<Id, List<ebotdata__Bot_Chat_Log__c>>();
      for (ebotdata__Bot_Chat_Log__c bcl : [
        SELECT
          Id,
          CreatedDate,
          LastModifiedDate,
          CreatedById,
          LastModifiedById,
          ebotdata__Current_Dialog_Id__c,
          ebotdata__Current_Dialog_Name__c,
          ebotdata__Bot_Session__c,
          ebotdata__Business_Metric_Type__c,
          ebotdata__Chat_Button_Name__c,
          ebotdata__Current_Confidence_For_Utterance__c,
          ebotdata__Current_Threshold_High__c,
          ebotdata__Current_Utterance__c,
          ebotdata__Data_Field_1__c,
          ebotdata__Data_Field_2__c,
          ebotdata__Data_Field_3__c,
          ebotdata__Data_Field_4__c,
          ebotdata__Data_Field_5__c,
          ebotdata__Escalation_Reason__c,
          ebotdata__Escalation_Result__c,
          ebotdata__Intent_Name__c,
          ebotdata__Intent_Type__c,
          ebotdata__Live_Agent_Session_Id__c,
          ebotdata__Successful_Resolution__c,
          ebotdata__Topic_Name__c
        FROM ebotdata__Bot_Chat_Log__c
        WHERE ebotdata__Bot_Session__c IN :botSessionsMap.keySet()
      ]) {
        if (!botChatLogMap.containsKey(bcl.ebotdata__Bot_Session__c)) {
          botChatLogMap.put(
            bcl.ebotdata__Bot_Session__c,
            new List<ebotdata__Bot_Chat_Log__c>()
          );
        }
        botChatLogMap.get(bcl.ebotdata__Bot_Session__c).add(bcl);
      }

      // Bulk Create Messaging End Users
      // Create a new Messaging End User for every transcript
      List<MessagingEndUser> newEndUsers = new List<MessagingEndUser>();
      for (LiveChatTranscript lct : liveChatList) {
        if (
          String.isNotBlank(lct.AccountId) && String.isNotBlank(lct.ContactId)
        ) {
          MessagingEndUser meu = new MessagingEndUser();
          meu.Name = lct.Contact.Name;
          meu.MessagingChannelId = messagingChannelId;
          meu.AccountId = lct.AccountId;
          meu.ContactId = lct.ContactId;
          meu.OwnerId = lct.OwnerId != null ? lct.OwnerId : '';
          meu.MessageType = 'EmbeddedMessaging';
          meu.MessagingPlatformKey = UUID.randomUUID().toString();
          newEndUsers.add(meu);
        } else {
          MessagingEndUser meu = new MessagingEndUser();
          meu.OwnerId = lct.OwnerId != null ? lct.OwnerId : '';
          meu.Name = 'Guest';
          meu.MessagingChannelId = messagingChannelId;
          meu.MessageType = 'EmbeddedMessaging';
          meu.MessagingPlatformKey = UUID.randomUUID().toString();
          newEndUsers.add(meu);
        }
      }
      insert newEndUsers;
      Logger.info('Inserted MessagingEndUsers');
      // Bulk Create Messaging Sessions
      List<MessagingSession> messagingSessions = new List<MessagingSession>();
      for (Integer i = 0; i < liveChatList.size(); i++) {
        LiveChatTranscript lct = liveChatList[i];
        MessagingEndUser meu = newEndUsers[i];
        MessagingSession ms = new MessagingSession();
        ms.Chat_Transcript__c = lct.Id;
        ms.Account__c = lct.AccountId;
        ms.Contact_Remove__c = lct.ContactId;
        ms.caseId = lct.CaseId;
        if (
          lct.OwnerId != null && String.valueOf(lct.OwnerId).startsWith('00G')
        ) {
          ms.OwnerId = '0053h000000zr5TAAQ';
        } else {
          ms.OwnerId = lct.OwnerId;
        }
        ms.Case_Lookup__c = lct.caseId;
        ms.StartTime = lct.StartTime;
        ms.EndTime = lct.EndTime;
        ms.CreatedDate = lct.CreatedDate;
        ms.LastModifiedDate = lct.LastModifiedDate;
        ms.CreatedById = lct.CreatedById;
        ms.LastModifiedById = lct.LastModifiedById;
        ms.SessionKey = lct.ChatKey;
        ms.Email__c = lct.Customer_Email__c;
        ms.CaseId = lct.CaseId;
        ms.Case_Lookup__c = lct.Case_Lookup__c;
        ms.Status = 'Ended';
        ms.MessagingEndUserId = meu.Id;
        ms.MessagingChannelId = messagingChannelId;
        ms.Visitor_IP_Address__c = lct.IpAddress;
        ms.Location__c = lct.Location;
        ms.Browser_Language__c = lct.BrowserLanguage;
        ms.Agent_Message_Count__c = lct.OperatorMessageCount;
        ms.Visitor_Message_Count__c = lct.VisitorMessageCount;
        ms.Visitor_Average_Response_Time__c = lct.AverageResponseTimeVisitor;
        ms.Agent_Average_Response_Time__c = lct.AverageResponseTimeOperator;
        ms.Agent_Maximum_Response_Time__c = lct.MaxResponseTimeOperator;
        ms.Customer_Maximum_Response_Time__c = lct.MaxResponseTimeVisitor;
        //ms.Is_Case_Reused__c = lct.Is_Case_Reused__c;
        ms.IsUserAuthenticated__c = lct.IsUserAuthenticated__c;
        ms.Actual_Tab_Close_Time__c = lct.Actual_Tab_Close_Time__c;
        ms.Custom_Chat_End_Time__c = lct.Custom_Chat_End_Time__c;
        ms.Language_Code__c = lct.Language_Code__c;
        ms.FirstName__c = lct.FirstName__c;
        ms.LastName__c = lct.LastName__c;
        ms.Page_Name__c = lct.Page_Name__c;
        ms.Page_URL__c = lct.Page_URL__c;
        ms.Button_Type__c = lct.Button_Type__c;
        ms.Chat_Button_LCT__c = lct.LiveChatButton.DeveloperName;
        ms.Platform__c = lct.Platform;
        ms.Browser__c = lct.Browser;
        messagingSessions.add(ms);
      }
      insert messagingSessions;
      // Store Mapping for Relationship Maintenance
      for (Integer i = 0; i < liveChatList.size(); i++) {
        sessionMap.put(liveChatList[i].Id, messagingSessions[i].Id);
      }
      // Update LiveChatTranscript records with the MessagingSession ID
      List<LiveChatTranscript> updatedTranscripts = new List<LiveChatTranscript>();
      for (LiveChatTranscript transcript : liveChatList) {
        if (sessionMap.containsKey(transcript.Id)) {
          transcript.Messaging_Session_ID__c = sessionMap.get(transcript.Id);
          updatedTranscripts.add(transcript);
        }
      }

      if (!updatedTranscripts.isEmpty()) {
        update updatedTranscripts;
      }

      // Bulk Create Messaging Insights
      List<Messaging_Insight__c> botSessionList = new List<Messaging_Insight__c>();
      for (ebotdata__Bot_Session__c oldBotSession : botSessionsMap.values()) {
        if (
          sessionMap.containsKey(
            oldBotSession.ebotdata__Live_Chat_Transcript__c
          )
        ) {
          Messaging_Insight__c newBotSession = new Messaging_Insight__c();
          newBotSession.Messaging_Session__c = sessionMap.get(
            oldBotSession.ebotdata__Live_Chat_Transcript__c
          );
          newBotSession.CreatedDate = oldBotSession.CreatedDate;
          newBotSession.LastModifiedDate = oldBotSession.LastModifiedDate;
          newBotSession.CreatedById = oldBotSession.CreatedById;
          newBotSession.OwnerId = oldBotSession.OwnerId;
          newBotSession.LastModifiedById = oldBotSession.LastModifiedById;
          newBotSession.BotName__c = oldBotSession.ebotdata__BotName__c;
          newBotSession.Loyalty_Id__c = oldBotSession.Loyalty_Id__c;
          newBotSession.Loyalty_Status__c = oldBotSession.Loyalty_Status__c;
          newBotSession.Customer_Full_Name__c = oldBotSession.Customer_Full_Name__c;
          newBotSession.Order_Number__c = oldBotSession.Order_Number__c;
          newBotSession.Successful_Resolution__c = oldBotSession.ebotdata__Successful_Resolution__c;
          newBotSession.Escalation_Reason__c = oldBotSession.ebotdata__Escalation_Reason__c;
          newBotSession.Chat_Satisfaction__c = oldBotSession.Chat_Satisfaction__c;
          newBotSession.Overall_Experience__c = oldBotSession.Overall_Experience__c;
          newBotSession.Would_Recommend_VS__c = oldBotSession.Would_Recommend_VS__c;
          newBotSession.Visitor_Contact__c = oldBotSession.ebotdata__Visitor_Contact__c;
          newBotSession.Case__c = oldBotSession.ebotdata__Case__c;
          newBotSession.CarouselContent__c = oldBotSession.CarouselContent__c;
          newBotSession.PostChat_Comments__c = oldBotSession.PostChat_Comments__c;
          newBotSession.Business_Dialog_Reached__c = oldBotSession.ebotdata__Business_Dialog_Reached__c;
          newBotSession.Einstein_Bot_Escalation_Successful__c = oldBotSession.ebotdata__Einstein_Bot_Escalation_Successful__c;
          newBotSession.Escalation_By_Design__c = oldBotSession.ebotdata__Escalation_By_Design__c;
          newBotSession.Escalation_End_Reached__c = oldBotSession.ebotdata__Escalation_End_Reached__c;
          newBotSession.IsUserAuthenticated__c = oldBotSession.IsUserAuthenticated__c;
          newBotSession.Self_Served_Dialog_Reached__c = oldBotSession.ebotdata__Self_Served_Dialog_Reached__c;
          newBotSession.Customer_Type__c = oldBotSession.Customer_Type__c;
          botSessionList.add(newBotSession);
        }
      }
      insert botSessionList;
      System.debug('Inserted Messaging Insights');

      // Store Mapping for Bot Session Relationship
      List<Id> botSessionKeys = new List<Id>(botSessionsMap.keySet());
      for (Integer i = 0; i < botSessionList.size(); i++) {
        botSessionMap.put(botSessionKeys[i], botSessionList[i].Id);
      }

      // Bulk Create Messaging Bot Chat Logs
      List<Messaging_Bot_Chat_Log__c> botChatLogList = new List<Messaging_Bot_Chat_Log__c>();
      for (List<ebotdata__Bot_Chat_Log__c> chatLogs : botChatLogMap.values()) {
        for (ebotdata__Bot_Chat_Log__c oldChatLog : chatLogs) {
          if (botSessionMap.containsKey(oldChatLog.ebotdata__Bot_Session__c)) {
            Messaging_Bot_Chat_Log__c newChatLog = new Messaging_Bot_Chat_Log__c();
            newChatLog.Messaging_Insight__c = botSessionMap.get(
              oldChatLog.ebotdata__Bot_Session__c
            );
            newChatLog.CreatedDate = oldChatLog.CreatedDate;
            newChatLog.CreatedById = oldChatLog.CreatedById;
            // newChatLog.OwnerId = oldChatLog.OwnerId;
            newChatLog.LastModifiedById = oldChatLog.LastModifiedById;
            newChatLog.Current_Dialog_Id__c = oldChatLog.ebotdata__Current_Dialog_Id__c;
            newChatLog.Current_Dialog_Name__c = oldChatLog.ebotdata__Current_Dialog_Name__c;
            newChatLog.Current_Utterance__c = oldChatLog.ebotdata__Current_Utterance__c;
            newChatLog.Data_Field_1__c = oldChatLog.ebotdata__Data_Field_1__c;
            newChatLog.Data_Field_2__c = oldChatLog.ebotdata__Data_Field_2__c;
            newChatLog.Data_Field_3__c = oldChatLog.ebotdata__Data_Field_3__c;
            newChatLog.Data_Field_4__c = oldChatLog.ebotdata__Data_Field_4__c;
            newChatLog.Intent_Name__c = oldChatLog.ebotdata__Intent_Name__c;
            newChatLog.CreatedDate = oldChatLog.CreatedDate;
            newChatLog.CreatedById = oldChatLog.CreatedById;
            newChatLog.Current_Confidence_For_Utterance__c = oldChatLog.ebotdata__Current_Confidence_For_Utterance__c;
            newChatLog.Current_Threshold_High__c = oldChatLog.ebotdata__Current_Threshold_High__c;
            newChatLog.Escalation_Reason__c = oldChatLog.ebotdata__Escalation_Reason__c;
            newChatLog.Escalation_Result__c = oldChatLog.ebotdata__Escalation_Result__c;
            newChatLog.Business_Metric_Type__c = oldChatLog.ebotdata__Business_Metric_Type__c;
            botChatLogList.add(newChatLog);
          }
        }
      }
      insert botChatLogList;
    } catch (Exception e) {
      Logger.error('Error in Batch Processing', e);
      Logger.saveLog();
    }
  }

  public Id getMessagingChannelId() {
    return [
      SELECT Id
      FROM MessagingChannel
      WHERE DeveloperName = 'MIAW_Customer_Care_Bot'
      LIMIT 1
    ]
    .Id;
  }

  global void finish(Database.BatchableContext BC) {
    System.debug(
      'Batch Process Completed: MessagingSession, MessagingBotSession, MessagingBotChatLog Inserted.'
    );
    Logger.saveLog();
  }
}