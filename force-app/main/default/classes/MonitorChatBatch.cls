global class MonitorChatBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    // Query all active session records (exclude ended sessions)
    Integer last_x_minutes = Integer.valueOf(System.label.VSCCS_Last_X_Minutes);
    DateTime dt = System.Now().addMinutes(-last_x_minutes);
    return Database.getQueryLocator(
      [
        SELECT Id, Active_Session_Key__c, LastModifiedDate
        FROM Active_Session__c
        WHERE
          LastModifiedDate >= :dt
          AND Active_Session_Key__c != NULL
          AND IsMinimized__c = FALSE
        ORDER BY LastModifiedDate DESC
        LIMIT 50000
      ]
    );
  }

  global void execute(
    Database.BatchableContext bc,
    List<Active_Session__c> scope
  ) {
    // Group by Active_Session_Key__c
    try {
      Set<String> uniqueIds = new Set<String>();
      Map<String, Active_Session__c> grouped = new Map<String, Active_Session__c>();

      for (Active_Session__c rec : scope) {
        if (!grouped.containsKey(rec.Active_Session_Key__c)) {
          grouped.put(rec.Active_Session_Key__c, rec);
        }
      }

      String inActiveChats = '';
      for (String key : grouped.keySet()) {
        Active_Session__c latest = grouped.get(key);
        // Check if difference > 1 min
        Integer maxTimeLimit = Integer.valueOf(
          System.label.VSCCS_Inactive_Batch_Duration
        );
        if (
          Datetime.now().getTime() - latest.LastModifiedDate.getTime() >
          maxTimeLimit
        ) {
          uniqueIds.add(key);
        }
      }
      List<MessagingSession> sessions = [
        SELECT Id
        FROM MessagingSession
        WHERE Status != 'Ended' AND Unique_Identifier__c IN :uniqueIds
      ];
      Logger.debug('SessionIds ' + sessions);
      Logger.saveLog();
      if (sessions.size() > 0) {
        for (MessagingSession session : sessions) {
          inActiveChats += session.Id + ',';
        }
        Logger.debug('Inactive Messaging Session Ids ' + inActiveChats); Logger.saveLog();
        Inactive_Chat__e eventsToPublish = new Inactive_Chat__e(
          InActive_Chat_Ids__c = inactiveChats
        );
        Database.SaveResult results = EventBus.publish(eventsToPublish);
      }
    } catch (Exception e) {Logger.error('Exception in MonitorChatBatch execute method', e.getMessage()); Logger.saveLog();}
  }
  //Deleting Older Active session records of last 3 minutes
  global void finish(Database.BatchableContext bc) {
    try {
      Integer last_x_del_minutes = Integer.valueOf(
        System.label.VSCCS_Delete_X_Minutes
      );
      DateTime lastxMinutes = System.Now().addMinutes(-last_x_del_minutes);
      List<Active_Session__c> olderRecords = [
        SELECT Id
        FROM Active_Session__c
        WHERE LastModifiedDate <= :lastxMinutes
        LIMIT 10000
      ];
      if (!olderRecords.isEmpty()) {
        delete olderRecords;
      }
    } catch (Exception e) { Logger.error('Exception in MonitorChatBatch finish method', e.getMessage()); Logger.saveLog();}
  }
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new MonitorChatBatch(), 50);
  }
}