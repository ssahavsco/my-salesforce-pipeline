/*****************************************************************************************************@@
Class Name     :  NF_ConsoleEventsHandlerController
Purpose        :  Controller class for nf_consoleEventsHandler component
				  used to capture associates omni-channel activities.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version            
2.		 Sunny  				4/22/2021			Modified for enhancement	DP-37943, DP-40244
3.		 Manishi  				5/6/2021			Added trigger bypass 		DP-41198
4.     Himanshu       03/06/2025      Added MIAW Changes      DP-91108   
@Testsuite:  {NF_ConsoleEventsHandlerControllerTest}                                       
*********************************************************************************************************/

public with sharing class NF_ConsoleEventsHandlerController {
  @AuraEnabled
  public static String getInactiveMessage(String recordId) {
    try {
      String languageCode = 'en_US';
      List<MessagingSession> msgSession = [
        SELECT Language_Code__c
        FROM MessagingSession
        WHERE Id = :recordId
      ];
      if (msgSession.size() > 0) {
        languageCode = msgSession[0].Language_Code__c ?? languageCode;
      }
      String message = Label.get(
        '',
        'Agent_Inactive_Customer_Message',
        languageCode
      );
      return message;
    } catch (Exception e) {Logger.error('Error updating messaging session owner').setExceptionDetails(e).addTag('OmniException');
      Logger.saveLog();
      return '';
    }
  }

  @AuraEnabled
  public static String getCustomerName(String recordId) {
    try {
      List<MessagingSession> msgSession = [
        SELECT Name, EndUserAccount.Name
        FROM MessagingSession
        WHERE Id = :recordId
      ];
      if (msgSession.size() > 0) {
        return msgSession[0].EndUserAccount.Name ?? msgSession[0].Name;
      }
      return '';
    } catch (Exception e) { Logger.error('Error updating messaging session owner').setExceptionDetails(e).addTag('OmniException');
      Logger.saveLog();
      return '';
    }
  }
  @AuraEnabled
  public static void UpdateAgentInactivity(String recordId) {
    try {
      List<MessagingSession> msgSession = [
        SELECT OwnerId, Queue_ID__c
        FROM MessagingSession
        WHERE Id = :recordId
      ];
      if (msgSession.size() > 0) {
        List<User> associate = [
          SELECT ManagerId
          FROM User
          WHERE Id = :msgSession[0].OwnerId
        ];
        Associate_Metric__c asscMetric = new Associate_Metric__c();
        asscMetric.Type__c = 'Inactive Chat';
        asscMetric.Messaging_Session__c = recordId;
        asscMetric.Associate__c = msgSession[0].OwnerId;
        asscMetric.Manager__c = associate.size() > 0
          ? associate[0].ManagerId
          : '';
        Database.insert(asscMetric);
      }
    } catch (Exception e) {Logger.error('Error updating Associate Metric' + e.getMessage()).setExceptionDetails(e).addTag('OmniException');
      Logger.saveLog();
    }
  }
  @AuraEnabled
  public static void changeOwnerToQueue(String recordId) {
    try {
      List<MessagingSession> msgSession = [
        SELECT OwnerId, Queue_ID__c
        FROM MessagingSession
        WHERE Id = :recordId
      ];
      if (msgSession.size() > 0) {
        List<User> associate = [
          SELECT ManagerId
          FROM User
          WHERE Id = :msgSession[0].OwnerId
        ];
        Associate_Metric__c asscMetric = new Associate_Metric__c();
        asscMetric.Type__c = 'Unresponsive Chat';
        asscMetric.Messaging_Session__c = recordId;
        asscMetric.Associate__c = msgSession[0].OwnerId;
        asscMetric.Manager__c = associate.size() > 0
          ? associate[0].ManagerId
          : '';
        Database.insert(asscMetric);

        msgSession[0].OwnerId = msgSession[0].Queue_ID__c ??
          System.Label.Normal_Chat_Queue;
        msgSession[0].IsChatTransferred__c = true;
        update msgSession;
      }
    } catch (Exception e) {
      Logger.error('Error updating messaging session owner')
        .setExceptionDetails(e)
        .addTag('OmniException');
      Logger.saveLog();
    }
  }
  @AuraEnabled
  public static void updateActivitySession(String recordId) {
    try {
      MessagingSession sessionRecord = [
        SELECT Unique_Identifier__c, Customer_Last_Message_Time__c
        FROM MessagingSession
        WHERE Id = :recordId
        LIMIT 1
      ];
      String UniqueId = sessionRecord != null
        ? sessionRecord.Unique_Identifier__c
        : null;

      if (UniqueId != null) {
        sessionRecord.Customer_Last_Message_Time__c = datetime.now();
        update sessionRecord;
        List<Active_Session__c> existingSessions = [
          SELECT Id, IsMinimized__c
          FROM Active_Session__c
          WHERE Active_Session_Key__c = :UniqueId.trim()
          LIMIT 1
        ];
        if (existingSessions.size() > 0) {
          existingSessions[0].IsMinimized__c = false;
          update existingSessions[0];
        }
      }
    } catch (Exception e) { Logger.error('Error Updating Activity Session', e.getMessage());
      Logger.saveLog();
    }
  }
  @AuraEnabled
  public static void updateEndUserMessageCount(String recordId) {
    try {
      List<AgentWork> works = [
        SELECT Visitor_Message_Count_With_Agent__c
        FROM AgentWork
        WHERE
          WorkItemId = :recordId
          AND Owner.Name != 'Platform Integration User'
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      if (!works.isEmpty()) {
        works[0].Visitor_Message_Count_With_Agent__c =
          works[0].Visitor_Message_Count_With_Agent__c + 1;
        update works;
      }
    } catch (Exception e) {Logger.error('Error updating enduser message count').setExceptionDetails(e).addTag('OmniException');
      Logger.saveLog();
    }
  }
  @AuraEnabled
  public static Boolean updateAgentFirstMessageTime(String recordId) {
    try {
      List<AgentWork> works = [
        SELECT Agent_First_Message_Time__c
        FROM AgentWork
        WHERE
          WorkItemId = :recordId
          AND Agent_First_Message_Time__c = NULL
          AND Owner.Name != 'Platform Integration User'
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      if (!works.isEmpty()) {
        works[0].Agent_First_Message_Time__c = datetime.now();
        update works;
      }
      return true;
    } catch (Exception e) {Logger.error('Error updating first message time', e.getMessage());
      Logger.saveLog();
      return false;
    }
  }
  @AuraEnabled
  public static void updateCustomerInactivityTime(String recordId) {
    try {
      List<MessagingSession> chats = [
        SELECT Customer_Inactivity_End_Time__c
        FROM MessagingSession
        WHERE Id = :recordId AND Customer_Inactivity_End_Time__c = NULL
      ];
      if (!chats.isEmpty()) {
        chats[0].Customer_Inactivity_End_Time__c = datetime.now();
        update chats;
      }
    } catch (Exception e) {Logger.error('Error updating Customer Inactivity Ended Time',e.getMessage());
      Logger.saveLog();
    }
  }
  /**
   * @Param recordId (of chat trnas. record)
   * @Description Returns caseId related to chat record
   */
  @AuraEnabled
  public static Response getCaseAndContact(String recordId) {
    List<MessagingSession> chats = [
      SELECT CaseId, EndUserContactId, Status
      FROM MessagingSession
      WHERE Id = :recordId
    ];
    if (!chats.isEmpty()) {
      Response resp = new Response();
      resp.caseId = chats.get(0).CaseId;
      // resp.ContactId = chats.get(0).ContactId;
      System.debug('getCaseAndContact >> chats= ' + chats);
      resp.isChatEnded = false;
      if (chats.get(0).Status == 'Ended') {
        resp.isChatEnded = true;
      }
      if (String.isNotBlank(chats.get(0).EndUserContactId)) {
        List<Contact> users = [
          SELECT Id, FirstName, LastName
          FROM Contact
          WHERE Id = :chats.get(0).EndUserContactId
        ];
        System.debug('getCaseAndContact >> contacts= ' + users);
        if (users.size() > 0 && String.isNotBlank(users.get(0).FirstName)) {
          resp.contactName =
            users.get(0).FirstName +
            ' ' +
            users.get(0).LastName;
        }
      }
      return resp;
    }
    return null;
  }

  /** DP-37943 starts **/
  /** method to capture the chat end time **/
  @AuraEnabled
  public static void saveChatEndTime(String msgSessionId) {
    /* modified for DP-41198 */
    try {
      String caseId = '';
      List<MessagingSession> msgSession = [
        SELECT CaseId, Agent_Session_Handle_Time__c
        FROM MessagingSession
        WHERE Id = :msgSessionId
        LIMIT 1
      ];
      if (msgSession.size() > 0) {
        caseId = msgSession[0].CaseId;
        update new MessagingSession(
          Id = msgSessionId,
          Custom_Chat_End_Time__c = system.now()
        );
        Case caseObj = [
          SELECT Id, Average_Agent_Handle_Time__c
          FROM Case
          WHERE Id = :caseId
        ];
        caseObj.Average_Agent_Handle_Time__c = msgSession[0]
          .Agent_Session_Handle_Time__c;
        update caseObj;
      }
    } catch (Exception e) {logger.error('Error in Console Event Handler Class: ' + e.getMessage()).addTag('onChatEnded');
      logger.saveLog();
    }
  }
  @AuraEnabled
  public static boolean sessionIsActive(String sessionId) {
    String sesStatus = [
      SELECT id, Status
      FROM MessagingSession
      WHERE Id = :sessionId
    ]
    .Status;
    return sesStatus == 'Active' ? true : false;
  }

  /** method to capture the actual tab closing time by associates **/
  @AuraEnabled
  public static void saveChatTabCloseTime(String msgSessionId) {
    /* modified for DP-41198 */
    try {
      update new MessagingSession(
        Id = msgSessionId,
        Actual_Tab_Close_Time__c = system.now()
      );
    } catch (Exception e) {logger.error('Error in Console Event Handler Class: ' + e.getMessage()).addTag('onChatTabClosed');
      logger.saveLog();
    }
  }

  @AuraEnabled
  public static void updateMessagingSessionMetrics(String messagingSessionId) {
    // Query MessagingSessionMetrics records
    try {
      List<MessagingSessionMetrics> metricsList = [
        SELECT
          MessagingSessionId,
          MessagingSessionMetricType,
          MessagingSessionMetricValue
        FROM MessagingSessionMetrics
        WHERE MessagingSessionId = :messagingSessionId
      ];

      // Map to store sessionId -> MetricType -> MetricValue
      Map<Id, Map<String, Decimal>> sessionMetricsMap = new Map<Id, Map<String, Decimal>>();

      for (MessagingSessionMetrics metric : metricsList) {
        if (!sessionMetricsMap.containsKey(metric.MessagingSessionId)) {
          sessionMetricsMap.put(
            metric.MessagingSessionId,
            new Map<String, Decimal>()
          );
        }
        sessionMetricsMap.get(metric.MessagingSessionId)
          .put(
            metric.MessagingSessionMetricType,
            metric.MessagingSessionMetricValue
          );
      }

      // List to store sessions for update
      List<MessagingSession> sessionsToUpdate = new List<MessagingSession>();

      for (Id sessionId : sessionMetricsMap.keySet()) {
        MessagingSession session = new MessagingSession(Id = sessionId);
        Map<String, Decimal> metrics = sessionMetricsMap.get(sessionId);

        // Mapping metric types to custom fields
        if (metrics.containsKey('AverageAgentResponseTime')) {
          session.Agent_Average_Response_Time__c = metrics.get(
            'AverageAgentResponseTime'
          );
        }
        if (metrics.containsKey('MaxAgentResponseTime')) {
          session.Agent_Maximum_Response_Time__c = metrics.get(
            'MaxAgentResponseTime'
          );
        }
        if (metrics.containsKey('MaxEndUserResponseTime')) {
          session.Customer_Maximum_Response_Time__c = metrics.get(
            'MaxEndUserResponseTime'
          );
        }
        if (metrics.containsKey('AverageEndUserResponseTime')) {
          session.Visitor_Average_Response_Time__c = metrics.get(
            'AverageEndUserResponseTime'
          );
        }
        if (metrics.containsKey('AgentMessageCount')) {
          session.Agent_Message_Count__c = metrics.get('AgentMessageCount');
        }
        if (metrics.containsKey('EndUserMessageCount')) {
          session.Visitor_Message_Count__c = metrics.get('EndUserMessageCount');
        }

        sessionsToUpdate.add(session);
      }

      // Perform update operation
      if (!sessionsToUpdate.isEmpty()) {
        update sessionsToUpdate;
      }
    } catch (Exception e) {Logger.error('Error in updating Messaging Session Metrics', e);
      Logger.saveLog();
    }
  }

  /** DP-37943 ends **/

  public class Response {
    @AuraEnabled
    public String caseId;
    @AuraEnabled
    public String contactId;
    @AuraEnabled
    public String contactName;
    @AuraEnabled
    public Boolean isChatEnded;
  }
}