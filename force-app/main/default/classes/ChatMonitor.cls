@RestResource(urlMapping='/ChatMonitor/*')
global without sharing class ChatMonitor {
  @HttpPatch
  global static String createActiveSession() {
    String responseMsg;

    try {
      RestRequest req = RestContext.request;
      Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(
        req.requestBody.toString()
      );

      if (!data.containsKey('ActiveSessionKey')) {
        RestContext.response.statusCode = 400;
        return '{"status":"error","message":"ActiveSessionKey is required"}';
      }
      String activeSessionKey = (String) data.get('ActiveSessionKey');
      Boolean isMinimized = data.containsKey('IsMinimized')
        ? (Boolean) data.get('IsMinimized')
        : false;
      //System.debug('SessionKey ' + activeSessionKey);

      /*List<MessagingSession> mSession = [
        SELECT Status
        FROM MessagingSession
        WHERE Unique_Identifier__c = :activeSessionKey.trim()  
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];*/
      List<Active_Session__c> existingSessions = [
        SELECT Id, IsMinimized__c
        FROM Active_Session__c
        WHERE Active_Session_Key__c = :activeSessionKey.trim()
        LIMIT 1
      ];
      System.debug('Session Size ' + existingSessions.size());
      /*Boolean isSessionActive =
        mSession.size() > 0 &&
        mSession[0].Status != 'Ended';
      //if (isSessionActive) {*/
      if (existingSessions.size() > 0) {
        existingSessions[0].IsMinimized__c = isMinimized;
        update existingSessions[0];
      } else {
        Active_Session__c session = new Active_Session__c(
          Active_Session_Key__c = activeSessionKey,
          IsMinimized__c = isMinimized
        );
        insert session;
      }
      responseMsg = '{"status":"success","message":"Session processed successfully"}';
      //}
    } catch (Exception e) { RestContext.response.statusCode = 400; responseMsg = '{"status":"error","message":"' + e.getMessage() + '"}'; Logger.error(responseMsg); Logger.saveLog();}

    return responseMsg;
  }
}