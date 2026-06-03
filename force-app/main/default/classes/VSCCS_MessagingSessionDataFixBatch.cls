global class VSCCS_MessagingSessionDataFixBatch implements Database.Batchable<SObject>, Database.Stateful {
  global Datetime startDate;
  global Datetime endDate;

  global VSCCS_MessagingSessionDataFixBatch(
    Datetime startDate,
    Datetime endDate
  ) {
    this.startDate = startDate;
    this.endDate = endDate;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT Id
        FROM MessagingSession
        WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate
      ]
    );
  }

  global void execute(Database.BatchableContext BC, List<SObject> scope) {
    List<Id> sessionIds = new List<Id>();
    for (SObject sObj : scope) {
      sessionIds.add((Id) sObj.Id);
    }

    Map<Id, MessagingSession> sessionMap = new Map<Id, MessagingSession>(
      [
        SELECT
          Id,
          AcceptTime,
          MessagingEndUserId,
          Account__c,
          Contact_Remove__c,
          Session_Escalation_Time__c,
          Chat_Transcript__c,
          Platform__c,
          Browser__c,
          IsGraceChat__c
        FROM MessagingSession
        WHERE Id IN :sessionIds
      ]
    );

    Set<Id> lctIds = new Set<Id>();
    Set<Id> endUserIds = new Set<Id>();
    for (MessagingSession ms : sessionMap.values()) {
      if (ms.Chat_Transcript__c != null) {
        lctIds.add(ms.Chat_Transcript__c);
      }
      if (ms.MessagingEndUserId != null) {
        endUserIds.add(ms.MessagingEndUserId);
      }
    }
    Map<Id, MessagingEndUser> endUserMap = new Map<Id, MessagingEndUser>(
      [
        SELECT Id, AccountId, ContactId, MessagingChannelId
        FROM MessagingEndUser
        WHERE Id IN :endUserIds
      ]
    );

    Map<Id, LiveChatTranscript> lctMap = new Map<Id, LiveChatTranscript>(
      [
        SELECT
          Id,
          Platform,
          Browser,
          AccountId,
          ContactId,
          OwnerId,
          LiveChatButton.DeveloperName,
          (
            SELECT Id, Type, Time
            FROM LiveChatTranscriptEvents
            WHERE
              Type IN ('Transfer', 'TransferredToButton', 'TransferredToQueue')
            ORDER BY Time ASC
          ),
          (
            SELECT Id, ebotdata__Einstein_Bot_Escalation__c, Customer_Type__c
            FROM ebotdata__Einstein_Bot_Chat_Session__r
            LIMIT 1
          )
        FROM LiveChatTranscript
        WHERE Id IN :lctIds
      ]
    );

    Map<Id, Messaging_Insight__c> insightMap = new Map<Id, Messaging_Insight__c>(
      [
        SELECT
          Id,
          Messaging_Session__c,
          Messaging_Session__r.Chat_Transcript__c,
          OwnerId
        FROM Messaging_Insight__c
        WHERE Messaging_Session__r.Chat_Transcript__c IN :lctIds
      ]
    );
    List<MessagingEndUser> endUsersToUpdate = new List<MessagingEndUser>();
    List<MessagingSession> sessionsToUpdate = new List<MessagingSession>();
    List<Messaging_Insight__c> insightsToUpdate = new List<Messaging_Insight__c>();

    for (MessagingSession session : sessionMap.values()) {
      Id endUserId = session.MessagingEndUserId;
      if (endUserId != null && endUserMap.containsKey(endUserId)) {
        MessagingEndUser endUser = endUserMap.get(endUserId);

        // Update AccountId and ContactId fields
        if (session.Account__c != null) {
          endUser.AccountId = session.Account__c;
        }
        if (session.Contact_Remove__c != null) {
          endUser.ContactId = session.Contact_Remove__c;
        }
        endUsersToUpdate.add(endUser);
      }

      Id lctId = session.Chat_Transcript__c;
      if (lctId != null && lctMap.get(lctId) != null) {
        LiveChatTranscript lct = lctMap.get(lctId);
        if (
          lct.OwnerId != null && String.valueOf(lct.OwnerId).startsWith('00G')
        ) {
          session.OwnerId = '0053h000000zr5TAAQ';
        } else if (lct.OwnerId != null) {
          session.OwnerId = lct.OwnerId;
        }
        if (lct.Platform != null) {
          session.Platform__c = lct.Platform;
        }
        if (lct.Browser != null) {
          session.Browser__c = lct.Browser;
        }
        if (lct.LiveChatButton.DeveloperName == 'Grace_Internal_Bot') {
          session.IsGraceChat__c = true;
        }
        for (LiveChatTranscriptEvent event : lct.LiveChatTranscriptEvents) {
          if (event.Type == 'Transfer' && session.AcceptTime == null) {
            session.AcceptTime = event.Time;
          }
          if (
            (event.Type == 'TransferredToButton' ||
            event.Type == 'TransferredToQueue') &&
            session.Session_Escalation_Time__c == null
          ) {
            session.Session_Escalation_Time__c = event.Time;
          }
        }

        sessionsToUpdate.add(session);

        if (insightMap != null) {
          for (Messaging_Insight__c insight : insightMap.values()) {
            if (insight.Messaging_Session__c == session.Id) {
              String escalationValue = 'Not Initiated';

              if (!lct.ebotdata__Einstein_Bot_Chat_Session__r.isEmpty()) {
                ebotdata__Bot_Session__c botSession = lct.ebotdata__Einstein_Bot_Chat_Session__r[0];
                String escalation = botSession.ebotdata__Einstein_Bot_Escalation__c;
                if (escalation == 'Successful') {
                  escalationValue = 'Success';
                } else if (
                  new Set<String>{
                      'No Agents Available',
                      'Missed Chat',
                      'Error',
                      'Closed',
                      'Case Already Created',
                      'Other'
                    }
                    .contains(escalation)
                ) {
                  escalationValue = 'Turned Away';
                }
                if (botSession.Customer_Type__c != null) {
                  insight.Customer_Type__c = botSession.Customer_Type__c;
                }
              }
              insight.Session_Escalation__c = escalationValue;
              //  insight.OwnerId = '0053h000000zr5TAAQ';
              insightsToUpdate.add(insight);
            }
          }
        }
      }
    }
    if (!endUsersToUpdate.isEmpty()) {
      update endUsersToUpdate;
    }
    if (!sessionsToUpdate.isEmpty()) {
      update sessionsToUpdate;
    }
    if (!insightsToUpdate.isEmpty()) {
      update insightsToUpdate;
    }
  }

  global void finish(Database.BatchableContext BC) {
    // Optional: Send email or log success
  }
}