@isTest
private class NF_CreateCaseFormControllerTest {
  static testMethod void getLiveChatTest() {
    String routableId = NF_UtilTest.createMessagingSession();
    NF_CreateCaseFormController.getLiveChatList(routableId);
  }

  static testMethod void createCaseTest() {
    String routableId = NF_UtilTest.createMessagingSession();
    MessagingSession msgSession = [
      SELECT Customer_Type__c
      FROM MessagingSession
      WHERE Id = :routableId
    ];
    msgSession.Customer_Type__c = 'Unauthenticated';
    update msgSession;
    NF_CreateCaseFormController.createCase(routableId, null);
  }
}