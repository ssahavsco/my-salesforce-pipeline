/*****************************************************************************************************@@
Class Name     :  NF_OrderHistoryController
Purpose        :  Controller class for OrderHistory component
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version            

@Testsuite:  {NF_OrderHistoryControllerTest}                                       
*********************************************************************************************************/
public with sharing class NF_OrderHistoryController {
  /**
   * @name searchOrder
   * @param emailId
   * @description Fetches response for the emailId argumented
   */
  @AuraEnabled
  public static string searchOrder(String emailId) {
    try {
      return NF_OrderHistoryAPI.searchOrder(emailId);
    } catch (Exception e) {
      Logger.error(
        'Error in getting Details by Id and Email :: ' + e.getMessage()
      );
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @name getCustomSettingsInfo
   * @description Fetches CustomSettings Info
   */
  @AuraEnabled
  public static string getCustomSettingsInfo() {
    List<LBrandsAPI__c> lb_apiList = [
      SELECT Id, Active_Omni_Link__c, Image_Base_URL__c
      FROM LBrandsAPI__c
    ];
    if (!lb_apiList.isEmpty()) {
      return JSON.serialize(lb_apiList[0]);
    }
    return null;
  }

  /**
   * @name searchOrder
   * @param orderId
   * @param emailId
   * @description Fetches response for the emailId and orderId argumented
   */
  @AuraEnabled
  public static string orderByIdAndEmail(String orderId, String email) {
    //try {
      return NF_OrderHistoryAPI.orderByIdAndEmail(orderId, email);
    /*} catch (Exception e) {
      Logger.error(
        'Error in getting Details by Id and Email :: ' + e.getMessage()
      );
      Logger.saveLog();
      return null;
    }*/
  }

  /**
   * @name getEmail
   * @param recordId
   * @description Fetches email for the recordId argumented
   */
  @AuraEnabled
  public static String getEmail(String recordId) {
    if (
      recordId != null &&
      recordId != '' &&
      String.valueOf(recordId).trim() != '' &&
      recordId instanceof Id
    ) {
      if (((Id) recordId).getSobjectType() == Schema.Account.SObjectType) {
        return [SELECT PersonEmail FROM Account WHERE Id = :recordId]
        .PersonEmail;
      } else if (((Id) recordId).getSobjectType() == Schema.Case.SObjectType) {
        return [SELECT Contact.Email FROM Case WHERE Id = :recordId]
        .Contact.Email;
      } else if (
        ((Id) recordId).getSobjectType() == Schema.MessagingSession.SObjectType
      ) {
        return [
          SELECT EndUserContact.Email
          FROM MessagingSession
          WHERE Id = :recordId
        ]
        .EndUserContact.Email;
      } else if (
        ((Id) recordId).getSobjectType() == Schema.Contact.SObjectType
      ) {
        return [SELECT Email FROM Contact WHERE Id = :recordId].Email;
      }
    }
    return null;
  }
}