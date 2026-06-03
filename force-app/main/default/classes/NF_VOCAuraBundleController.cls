public with sharing class NF_VOCAuraBundleController {
  @AuraEnabled
  public static ResponseWrapper getOrderNumber(String recordId) {
    ResponseWrapper resp = new ResponseWrapper();
    try {
      Map<String, String> respMap = new Map<String, String>();
      String orderNumber = '';
      Id recId = Id.valueOf(recordId);
      String sObjectType = recId.getSObjectType().getDescribe().getName();
      if (sObjectType == 'Case') {
        orderNumber = [
          SELECT Id, Order_Number__c
          FROM Case
          WHERE id = :recordId
        ]
        .Order_Number__c;
      } else if (sObjectType == 'MessagingSession') {
        orderNumber = [
          SELECT Id, Case.Order_Number__c
          FROM MessagingSession
          WHERE Id = :recordId
        ]
        .Case.Order_Number__c;
      }
      respMap.put('sObjectType', sObjectType);
      respMap.put('orderNumber', orderNumber);
      resp.data = JSON.serialize(respMap);
      resp.status = true;
      resp.errormessage = '';
    } catch (Exception e) {resp.data = '';resp.status = false;resp.errormessage = e.getMessage();Logger.error('Exception in getOrderNumber ' + e.getMessage());Logger.SaveLog();
    }

    return resp;
  }
  @AuraEnabled
  public static Boolean vocAccessable(Id messagingSessionId) {
    if (messagingSessionId == null) {
      return false;
    }
    if (FeatureManagement.checkPermission('Is_Test_Associate')) {
      return true;
    }

    // Check if current user is System Administrator
    if (isCurrentUserSystemAdmin()) {
      return true;
    }
    MessagingSession ms = [
      SELECT Id, OwnerId, Case.Status
      FROM MessagingSession
      WHERE Id = :messagingSessionId
      LIMIT 1
    ];

    return (ms.OwnerId == UserInfo.getUserId() || ms.Case.Status == 'Closed');
  }

  private static Boolean isCurrentUserSystemAdmin() {
    Profile p = [
      SELECT Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
      LIMIT 1
    ];
    return p.Name != null && p.Name.equalsIgnoreCase('System Administrator');
  }
}