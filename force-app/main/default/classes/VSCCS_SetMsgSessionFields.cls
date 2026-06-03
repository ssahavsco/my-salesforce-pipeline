public with sharing class VSCCS_SetMsgSessionFields {
  public class Input {
    @InvocableVariable(required=true)
    public String routableId;

    @InvocableVariable
    public String associateHoldMessage;

    @InvocableVariable
    public String userComments;

    @InvocableVariable
    public String orderNumber;

    @InvocableVariable
    public String userOfferCode;

    @InvocableVariable
    public Boolean isAuthUser;

    @InvocableVariable
    public Boolean isAwaitingPayment;
  }
  @InvocableMethod(label='Set Messaging Session Fields')
  public static void setMessagingSessionFields(List<Input> input) {
    try {
      MessagingSession msgSession = [
        SELECT
          Id,
          AssociateHoldMessage__c,
          IsUserAuthenticated__c,
          IsAwaitingPayment__c,
          Order_Number__c,
          UserComments__c,
          UserOfferCode__c
        FROM MessagingSession
        WHERE Id = :input[0].routableId
      ];

      if (!String.isBlank(input[0].associateHoldMessage)) {
        msgSession.AssociateHoldMessage__c = input[0].associateHoldMessage;
      }
      if (!String.isBlank(input[0].userComments)) {
        msgSession.UserComments__c = input[0].userComments;
      }
      if (!String.isBlank(input[0].orderNumber)) {
        msgSession.Order_Number__c = input[0].orderNumber;
      }
      if (!String.isBlank(input[0].userOfferCode)) {
        msgSession.UserOfferCode__c = input[0].userOfferCode;
      }
      if (input[0].isAuthUser != null) {
        msgSession.IsUserAuthenticated__c = input[0].isAuthUser;
      }
      if (input[0].isAwaitingPayment != null) {
        msgSession.IsAwaitingPayment__c = input[0].isAwaitingPayment;
      }
      update msgSession;
    } catch (Exception e) {
      Logger.error('Error updating messaging session')
        .setExceptionDetails(e)
        .addTag('BotException');
      Logger.saveLog();
    }
  }
}