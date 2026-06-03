/**
 * @description       : THis class is used to update the Customer Information After API
 *
 **/
public without sharing class UpdateCaseDetailsController {
  @AuraEnabled
  public static void initiateOnLoadAPI(String recordId) {
    if(String.isEmpty(recordId)){
      return;
    }
    try {
      Account accObj = [
        SELECT
          Id,
          PersonEmail,
          Phone,
          PersonContact.Loyalty_ID__c,
          PersonContactId
        FROM Account
        WHERE Id = :recordId
        LIMIT 1
      ];
      if(accObj ==null){
        return;
      }
      Account obj = new Account(Id = accObj.Id);
      LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty = runVSRewardAPI(
        accObj
      );
      obj.VS_Rewards_Tier__c = getTierCode(getCustomerLoyalty);
      obj.VSCC__c = getVSCCType(getCustomerLoyalty);
      obj.Customer_Location__c = getCustomerLocation(getCustomerLoyalty);
      update obj;
    } catch (Exception e) {
      // Logger.error('Exception in updating Account Details through UpdateCaseDetailsController  :: ' + e.getMessage());
      //   Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }
  @TestVisible
  private static LoyaltyAccountIntegration.GetCustomerLoyalty runVSRewardAPI(
    Account accObj
  ) {
    LoyaltyAccountIntegration.Input inputobj = new LoyaltyAccountIntegration.Input();
    inputobj.phone = accObj.PersonEmail != null ? '' : accObj.Phone;
    LoyaltyAccountIntegration.LoyaltyId loyaltyId = new LoyaltyAccountIntegration.LoyaltyId();
    loyaltyId.id = accObj.PersonContactId != null && accObj.PersonContact.Loyalty_ID__c != null ? accObj.PersonContact.Loyalty_ID__c : '';
    inputobj.loyaltyId = loyaltyId;
    inputobj.email = accObj.PersonEmail != null ? accObj.PersonEmail : '';
    inputobj.direct = false;
    inputobj.brand = 'VSS';
    String cgridResponse = LoyaltyAccountIntegration.loyaltyDetailsLookup(
      JSON.serialize(inputobj)
    );
    if (cgridResponse != null && String.isNotBlank(cgridResponse)) {
      LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty = (LoyaltyAccountIntegration.GetCustomerLoyalty) JSON.deserialize(
        cgridResponse,
        LoyaltyAccountIntegration.GetCustomerLoyalty.class
      );
      return getCustomerLoyalty;
    }

    return null;
  }
  @TestVisible
  private static String getTierCode(
    LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty
  ) {
    String tierCode = 'Not Enrolled';
    if (
      getCustomerLoyalty != null &&
      getCustomerLoyalty?.customer != null &&
      getCustomerLoyalty.customer.size() > 0 &&
      getCustomerLoyalty?.customer[0]?.loyalty != null
    ) {
      System.debug(
        'getCustomerLoyalty' + getCustomerLoyalty.customer[0].loyalty.tierCode
      );
      tierCode = getCustomerLoyalty.customer[0].loyalty.tierCode;
    }
    return tierCode != null ? tierCode : 'Not Enrolled';
  }
  @TestVisible
  private static String getVSCCType(
    LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty
  ) {
    String vsccStatus = 'Not Enrolled';
    if (
      getCustomerLoyalty != null &&
      getCustomerLoyalty?.customer != null &&
      getCustomerLoyalty.customer.size() > 0 &&
      getCustomerLoyalty?.customer[0]?.loyalty?.vsccStatus != null
    ) {
      System.debug(
        'getCustomerLoyalty' + getCustomerLoyalty.customer[0].loyalty.vsccStatus
      );
      vsccStatus = getCustomerLoyalty.customer[0].loyalty.vsccStatus;
    }
    return vsccStatus != null ? vsccStatus : 'Not Enrolled';
  }
  @TestVisible
  private static String getCustomerLocation(
    LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty
  ) {
    String customerLocation = '';
    if (
      getCustomerLoyalty != null &&
      getCustomerLoyalty?.customer != null &&
      getCustomerLoyalty.customer.size() > 0 &&
      getCustomerLoyalty?.customer[0]?.address?.country != null
    ) {
      System.debug(
        'getCustomerLoyalty' +
        getCustomerLoyalty.customer[0].address.country
      );
      customerLocation = 'International';
      if (
        getCustomerLoyalty.customer[0]
          .address.country.equalsIgnoreCase('US')
      ) {
        customerLocation = 'Domestic';
      }
    }
    return customerLocation;
  }
}