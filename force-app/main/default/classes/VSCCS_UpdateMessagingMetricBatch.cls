global class VSCCS_UpdateMessagingMetricBatch implements Database.Batchable<SObject>, Schedulable {
  public String query;

  global VSCCS_UpdateMessagingMetricBatch() {
    Integer last_N_Minutes = Integer.valueOf(System.Label.VSCCS_Last_N_Minutes);
    DateTime thirtyMinsAgo = Datetime.now().addMinutes(-last_N_Minutes); // last 30 mins
    query = 'Select Id From MessagingSession Where EndTime >= :thirtyMinsAgo AND Status = \'Ended\' AND Agent_Message_Count__c = NULL';
  }

  global VSCCS_UpdateMessagingMetricBatch(
    DateTime startDate,
    DateTime endDate
  ) {
    query =
      'SELECT Id FROM MessagingSession' +
      ' WHERE CreatedDate >= ' +
      startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
      ' AND CreatedDate < ' +
      endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
      ' AND Status =  \'Ended\' AND Agent_Message_Count__c = NULL';
  }

  global VSCCS_UpdateMessagingMetricBatch(Integer noOfDays) {
    Integer year = Date.today().year();
    Integer month = Date.today().month();
    Integer day = Date.today().day() - noOfDays;
    Datetime last_N_DaysAgo = datetime.newInstance(year, month, day);
    query =
      'SELECT Id, CreatedDate FROM MessagingSession' +
      ' WHERE CreatedDate = last_N_Days:' +
      noOfDays +
      ' AND Status = \'Ended\' AND Agent_Message_Count__c = NULL';
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    Integer last_N_Minutes = Integer.valueOf(System.Label.VSCCS_Last_N_Minutes);
    Datetime thirtyMinsAgo = Datetime.now().addMinutes(-last_N_Minutes); // last 30 mins
    System.debug('Query ' + query);
    return Database.getQueryLocator(query);
  }

  public void execute(
    Database.BatchableContext BC,
    List<MessagingSession> endedSessions
  ) {
    try {
      if (endedSessions.isEmpty()) {
        System.debug('No Messaging Sessions with Status = Ended found.');
        return;
      }

      // Step 2: Collect session IDs
      Set<Id> sessionIds = new Set<Id>();
      for (MessagingSession session : endedSessions) {
        sessionIds.add(session.Id);
      }

      // Step 3: Query MessagingSessionMetrics for these sessions
      List<MessagingSessionMetrics> metricsList = [
        SELECT
          MessagingSessionId,
          MessagingSessionMetricType,
          MessagingSessionMetricValue
        FROM MessagingSessionMetrics
        WHERE MessagingSessionId IN :sessionIds
      ];

      // Step 4: Build Map<Id, Map<MetricType, Value>>
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

      // Step 5: Prepare MessagingSession records to update
      List<MessagingSession> sessionsToUpdate = new List<MessagingSession>();

      for (MessagingSession session : endedSessions) {
        if (!sessionMetricsMap.containsKey(session.Id))
          continue;

        Map<String, Decimal> metrics = sessionMetricsMap.get(session.Id);
        MessagingSession sessionToUpdate = new MessagingSession(
          Id = session.Id
        );

        // Map each metric to a custom field (adjust field names as needed)
        if (metrics.containsKey('AverageAgentResponseTime')) {
          sessionToUpdate.Agent_Average_Response_Time__c = metrics.get(
            'AverageAgentResponseTime'
          );
        }
        if (metrics.containsKey('MaxAgentResponseTime')) {
          sessionToUpdate.Agent_Maximum_Response_Time__c = metrics.get(
            'MaxAgentResponseTime'
          );
        }
        if (metrics.containsKey('MaxEndUserResponseTime')) {
          sessionToUpdate.Customer_Maximum_Response_Time__c = metrics.get(
            'MaxEndUserResponseTime'
          );
        }
        if (metrics.containsKey('AverageEndUserResponseTime')) {
          sessionToUpdate.Visitor_Average_Response_Time__c = metrics.get(
            'AverageEndUserResponseTime'
          );
        }
        if (metrics.containsKey('AgentMessageCount')) {
          sessionToUpdate.Agent_Message_Count__c = metrics.get(
            'AgentMessageCount'
          );
        }
        if (metrics.containsKey('EndUserMessageCount')) {
          sessionToUpdate.Visitor_Message_Count__c = metrics.get(
            'EndUserMessageCount'
          );
        }

        sessionsToUpdate.add(sessionToUpdate);
      }

      // Step 6: Perform bulk update
      if (!sessionsToUpdate.isEmpty()) {
        update sessionsToUpdate;
        System.debug(
          'Updated ' +
            sessionsToUpdate.size() +
            ' Messaging Sessions with metrics.'
        );
      } else {
        System.debug('No Messaging Sessions required updates.');
      }
    } catch (Exception e) {
      Logger.error('Error updating messaging metric')
        .setExceptionDetails(e)
        .addTag('MetricException');
      Logger.saveLog();
    }
  }

  public void finish(Database.BatchableContext BC) {
    // Perform any post-processing logic here
  }

  public void execute(SchedulableContext BC) {
    VSCCS_UpdateMessagingMetricBatch batch = new VSCCS_UpdateMessagingMetricBatch();
    Database.executebatch(batch, 200);
  }
}