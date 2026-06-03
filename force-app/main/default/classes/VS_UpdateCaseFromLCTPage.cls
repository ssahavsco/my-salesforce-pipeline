public with sharing class VS_UpdateCaseFromLCTPage {
  public final static String AUTO_CLOSE_STRING = 'Auto-Closed Case';
  @AuraEnabled
  public static void updateCase(String lctId) {
    executeUpdateCase(lctId);
  }
  @future
  public static void executeUpdateCase(String lctId) {
    try {
      String msgKeyPrefix = NF_Util.getObjectPrefix('MessagingSession');
      String caseId = '';
      if (lctId.startsWith(msgKeyPrefix)) {
        MessagingSession msgObj = [
          SELECT Id, CaseId
          FROM MessagingSession
          WHERE Id = :lctId
          LIMIT 1
        ];
        caseId = msgObj.CaseId;
      } else {
        LiveChatTranscript transcript = [
          SELECT Id, CaseId
          FROM LiveChatTranscript
          WHERE Id = :lctId
          LIMIT 1
        ];
        caseId = transcript.CaseId;
      }

      Case caseRecord = [
        SELECT
          Id,
          Status,
          Type,
          Sub_Type__c,
          VOC_Comments__c,
          Auto_Closed__c,
          VOC_Updates_Complete__c
        FROM Case
        WHERE Id = :caseId
        LIMIT 1
      ];
      if (String.isBlank(caseRecord.Type)) {
        caseRecord.Type = AUTO_CLOSE_STRING;
        caseRecord.Sub_Type__c = AUTO_CLOSE_STRING;
      }
      if (String.isBlank(caseRecord.Type)) {
        caseRecord.VOC_Comments__c = AUTO_CLOSE_STRING;
      }
      caseRecord.Auto_Closed__c = true;
      caseRecord.VOC_Updates_Complete__c = true;
      caseRecord.Status = 'Closed';
      update caseRecord;
    } catch (DmlException e) {
      Logger.error(
        'Exception Occured in Case update from MessagingSession' +
        e.getMessage()
      );
      Logger.saveLog();
    }
  }
}