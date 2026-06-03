public with sharing class VSCCS_BotChatLoggerUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
  public Datetime startDate;
  public Datetime endDate;
  public VSCCS_BotChatLoggerUpdateBatch(Datetime startDate, Datetime endDate) {
    this.startDate = startDate;
    this.endDate = endDate;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT Id
        FROM MessagingSession
        WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate
      ]
    );
  }
  public void execute(Database.BatchableContext BC, List<SObject> scope) {
    List<Id> sessionIds = new List<Id>();
    for (SObject sObj : scope) {
      sessionIds.add((Id) sObj.Id);
    }
    Map<Id, MessagingSession> sessionMap = new Map<Id, MessagingSession>(
      [
        SELECT Id, Device_Type__c, Bot_Session__c, Chat_Transcript__c
        FROM MessagingSession
        WHERE Id IN :sessionIds
      ]
    );
    // Query ebotdata__Bot_Session__c records using MessagingSession IDs
    Map<Id, ebotdata__Bot_Session__c> botSessionMap = new Map<Id, ebotdata__Bot_Session__c>();
    for (ebotdata__Bot_Session__c botSession : [
      SELECT
        Id,
        ebotdata__Chat_Channel__c,
        ebotdata__Live_Chat_Transcript__r.Messaging_Session_ID__c
      FROM ebotdata__Bot_Session__c
      WHERE
        ebotdata__Live_Chat_Transcript__r.Messaging_Session_ID__c IN :sessionIds
    ]) {
      botSessionMap.put(
        botSession.ebotdata__Live_Chat_Transcript__r.Messaging_Session_ID__c,
        botSession
      );
    }
    // Prepare MessagingSession records for update
    List<MessagingSession> sessionsToUpdate = new List<MessagingSession>();
    for (MessagingSession session : sessionMap.values()) {
      if (botSessionMap.containsKey(session.Id)) {
        ebotdata__Bot_Session__c botSession = botSessionMap.get(session.Id);
        session.Device_Type__c = botSession.ebotdata__Chat_Channel__c; // Update Device_Type__c
        session.Bot_Session__c = botSession.Id;
        sessionsToUpdate.add(session);
      }
    }
    // Query Messaging_Insight__c and Messaging_Bot_Chat_Log__c records
    Map<Id, Messaging_Insight__c> insightMap = new Map<Id, Messaging_Insight__c>(
      [
        SELECT
          Id,
          Messaging_Session__c,
          (SELECT Id, Topic_Name__c FROM Messaging_Bot_Chat_Logs__r)
        FROM Messaging_Insight__c
        WHERE Messaging_Session__c IN :sessionIds
      ]
    );
    // Query ebotdata__Bot_Chat_Log__c records
    Map<Id, ebotdata__Bot_Chat_Log__c> botChatLogMap = new Map<Id, ebotdata__Bot_Chat_Log__c>();
    for (ebotdata__Bot_Chat_Log__c botChatLog : [
      SELECT
        Id,
        ebotdata__Topic_Name__c,
        ebotdata__Bot_Session__r.ebotdata__Live_Chat_Transcript__r.Messaging_Session_ID__c
      FROM ebotdata__Bot_Chat_Log__c
      WHERE
        ebotdata__Bot_Session__r.ebotdata__Live_Chat_Transcript__r.Messaging_Session_ID__c IN :sessionIds
    ]) {
      botChatLogMap.put(
        botChatLog.ebotdata__Bot_Session__r.ebotdata__Live_Chat_Transcript__r.Messaging_Session_ID__c,
        botChatLog
      );
    }
    // Prepare Messaging_Bot_Chat_Log__c records for update
    List<Messaging_Bot_Chat_Log__c> botChatLogsToUpdate = new List<Messaging_Bot_Chat_Log__c>();
    for (Messaging_Insight__c insight : insightMap.values()) {
      for (
        Messaging_Bot_Chat_Log__c botChatLog : insight.Messaging_Bot_Chat_Logs__r
      ) {
        if (botChatLogMap.containsKey(insight.Messaging_Session__c)) {
          ebotdata__Bot_Chat_Log__c relatedBotChatLog = botChatLogMap.get(
            insight.Messaging_Session__c
          );
          botChatLog.Topic_Name__c = relatedBotChatLog.ebotdata__Topic_Name__c; // Update Topic_Name__c
          botChatLogsToUpdate.add(botChatLog);
        }
      }
    }

    // Perform bulk update
    if (!sessionsToUpdate.isEmpty()) {
      try {
        update sessionsToUpdate;
      } catch (DmlException e) {
        System.debug(
          'Error updating MessagingSession records: ' + e.getMessage()
        );
      }
    }
    if (!botChatLogsToUpdate.isEmpty()) {
      try {
        update botChatLogsToUpdate;
      } catch (DmlException e) {
        System.debug(
          'Error updating Messaging_Bot_Chat_Log__c records: ' + e.getMessage()
        );
      }
    }
  }
  public void finish(Database.BatchableContext BC) {
    // Optional: Send email or log success
  }
}