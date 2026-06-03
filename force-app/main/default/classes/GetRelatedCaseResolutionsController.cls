/*********************************************************************************************************************************
 * Version		Jira			Modified by			Description
 *
 * 1.0			CCS-180			Himanshu Mishra		Controller class to cancel the case resolution
 * *******************************************************************************************************************************/
public with sharing class GetRelatedCaseResolutionsController {
  @AuraEnabled
  public static List<Case_Resolution__c> retrieveCRs(String recordId) {
    Id caseId = recordId;
    if (
      recordId.startswith(
        MessagingSession.sobjecttype.getDescribe().getKeyPrefix()
      )
    ) {
      caseId = [SELECT CaseId FROM MessagingSession WHERE Id = :recordId]
      .CaseId;
    } else if (
      recordId.startswith(
        LiveChatTranscript.sobjecttype.getDescribe().getKeyPrefix()
      )
    ) {
      caseId = [SELECT Case.Id FROM LiveChatTranscript WHERE Id = :recordId]
      .CaseId;
    } else if (
      recordId.startswith(SocialPost.sobjecttype.getDescribe().getKeyPrefix())
    ) {
      caseId = [SELECT ParentId FROM SocialPost WHERE Id = :recordId].ParentId;
    }
    return [
      SELECT
        Name,
        Status__c,
        Case_Resolution_Type__c,
        Notes_Comments__c,
        Completion_Date__c,
        CreatedDate
      FROM Case_Resolution__c
      WHERE Related_Case__c = :caseId
    ];
  }

  @AuraEnabled
  public static Boolean cancelCRs(Id crId) {
    Boolean isSuccess = false;
    Case_Resolution__c cr = [
      SELECT Is_Cancelled__c, Case_Resolution_Type__c
      FROM Case_Resolution__c
      WHERE Id = :crId
    ];
    if (cr.Case_Resolution_Type__c == 'Issue Gift Card') {
      LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
      Integer remorsePeriod = Integer.valueOf(
        lbAPI.AO_Cancel_Remorse_Duration_Minutes__c
      );
      String giftCardName = [
        SELECT Name
        FROM Gift_Card_Request__c
        WHERE Case_Resolution__c = :crId
      ]
      .Name;
      AOOrderCancellationController.ChatBotInput input = new AOOrderCancellationController.ChatBotInput();
      List<AOOrderCancellationController.ChatBotInput> inputList = new List<AOOrderCancellationController.ChatBotInput>();
      AOOrderCancellationController.ChatBotOutput output = new AOOrderCancellationController.ChatBotOutput();
      input.orderId = giftCardName;
      input.reasonId = 'Cancelled By Case Resolution';
      input.cancelComments = 'Associate cancelled Case Resolution';
      inputList.add(input);
      List<AOOrderCancellationController.ChatBotOutput> outputList = AOOrderCancellationController.cancelOrder(
        inputList
      );
      System.debug('Output ' + outputList);
      if (outputList[0].result) {
        cr.Is_Cancelled__c = true;
        update cr;
        return true;
      } else if (outputList[0].apiStatusCode == 400) {
        CalloutException e = new CalloutException();
        e.setMessage(
          'Case resolution can\'t be cancelled as the remorse period has passed'
        );
        Logger.error('Error ' + e.getMessage());
        Logger.saveLog();
        throw e;
      } else {
        CalloutException e = new CalloutException();
        e.setMessage(
          'Error while cancelling Case resolution!!! ' +
          String.valueOf(outputList[0].apiStatusCode)
        );
        Logger.error('Error - ' + e.getMessage());
        Logger.saveLog();
        throw e;
      }
    } else {
      cr.Is_Cancelled__c = true;
      update cr;
      return true;
    }
  }
}