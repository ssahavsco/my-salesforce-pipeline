public class NF_CreateCaseFormController {
  @AuraEnabled
  public static ResponseWrapper getLiveChatList(String chatRecordId) {
    ResponseWrapper resp = new ResponseWrapper();
    resp.status = true;
    resp.errormessage = '';
    List<MessagingSession> chatList = [
      SELECT Id, CaseId, MessagingEndUser.AccountId, MessagingEndUser.ContactId
      FROM MessagingSession
      WHERE id = :chatRecordId
    ];
    System.debug('chatList' + chatList);
    resp.data = JSON.serialize(chatList);
    return resp;
  }

  @AuraEnabled
  public static ResponseWrapper createCase(
    String chatRecordId,
    String accountId
  ) {
    ResponseWrapper resp = new ResponseWrapper();
    try {
      System.debug('chatRecordId' + chatRecordId);
      resp.status = true;
      resp.data = '';
      resp.errormessage = '';
      logger.info('createCase chatRecordId' + chatRecordId);
      logger.info('createCase accountId' + accountId);
      String caseId = '';
      String msgKeyPrefix = NF_Util.getObjectPrefix('MessagingSession');
      MessagingSession msgSession = [
        SELECT
          Id,
          EndUserAccountId,
          EndUserContactId,
          CaseId,
          JWT_Token__c,
          MessagingEndUserId,
          Customer_Type__c
        FROM MessagingSession
        WHERE Id = :chatRecordId
      ];
      caseId = msgSession.CaseId;

      List<Account> accs = [
        SELECT PersonContactId
        FROM Account
        WHERE Id = :accountId
      ];
      String contactId;
      if (!accs.isEmpty()) {
        contactId = accs[0].PersonContactId;
      }

      if (caseId != '') {
        System.debug('inside if');
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get('Chat_Case')
          .getRecordTypeId();
        Case caseToInsert = new Case();
        caseToInsert.Status = 'New';
        caseToInsert.Origin = 'Chat';
        caseToInsert.SourceId = chatRecordId;
        caseToInsert.userAuth__c = (msgSession != null &&
          msgSession.Customer_Type__c == 'Authenticated')
          ? 'Authenticated'
          : 'Not Authenticated';
        caseToInsert.RecordTypeId = recordTypeId;
        if (accountId != null) {
          caseToInsert.AccountId = accountId;
          caseToInsert.ContactId = contactId;
        } else {
          caseToInsert.AccountId = msgSession.EndUserAccountId;
          caseToInsert.ContactId = msgSession.EndUserContactId;
        }
        insert caseToInsert;
        if (chatRecordId.startsWith(msgKeyPrefix)) {
          MessagingSession msgSesion = new MessagingSession(Id = chatRecordId);
          msgSesion.CaseId = caseToInsert.Id;
          MessagingEndUser endUser = [
            SELECT AccountId
            FROM MessagingEndUser
            WHERE Id = :msgSession.MessagingEndUserId
          ];
          if (accountId != null) {
            endUser.AccountId = accountId;
          }
          if (contactId != null) {
            endUser.ContactId = contactId;
          }
          update endUser;
          update msgSesion;
        }

        // NF_ChatTranscriptTriggerHandler.triggerDisabled = true;
      } else {
        System.debug('inside else');
        resp.status = false;
        resp.data = '';
        resp.errormessage = 'Case Already Created for this Chat';
      }
    } catch (Exception e) {
      resp.status = false;
      resp.data = '';
      resp.errormessage = e.getMessage();
      logger.error('Error while creating case - ' + e.getMessage());
    }
    logger.saveLog();
    return resp;
  }
}