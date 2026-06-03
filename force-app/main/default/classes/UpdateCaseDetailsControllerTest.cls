@isTest
public class UpdateCaseDetailsControllerTest {
  @TestSetup
  static void createTestData() {
    Account acc = new Account();
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    acc.FirstName = 'Divyanshu';
    acc.LastName = 'Kumar';
    acc.PersonEmail = 'thuwaldk@gmail.com';
    acc.Phone = '9699876542';
    acc.PersonMailingCity = 'Coffeyville';
    acc.PersonMailingCountry = 'United States';
    acc.PersonMailingState = 'Kansas';
    acc.PersonMailingStreet = 'East\n North\n Street';
    acc.PersonMailingPostalCode = '67337';
    acc.ShippingCity = 'Coffeyville';
    acc.ShippingCountry = 'United States';
    acc.ShippingState = 'Kansas';
    acc.ShippingStreet = 'East\n North\n Street';
    acc.ShippingPostalCode = '67337';
    acc.CID__c = 'aaa6c118-4601-4bee-8fdc-a6e22e069db5';
    insert acc;
    Contact c = new Contact();
    c.LastName = 'Test Last';
    c.FirstName = 'Test First';
    c.OwnerId = UserInfo.getUserId();
    c.Loyalty_ID__c = 'Test Loyalty ID';
    insert c;

    Case cs = new Case();
    cs.RecordTypeId = '0123h000000dIwCAAU';
    cs.Origin = 'chat';
    cs.AccountId = acc.Id;
    cs.Type = 'Rewards';
    cs.Sub_Type__c = 'Other';
    cs.Status = 'New';
    cs.VOC_Comments__c = 'Test';
    cs.ContactId = c.id;
    cs.OwnerId = UserInfo.getUserId();
    insert cs;
  }
  @isTest
  static void initiateOnLoadAPITest() {
    Id accId = [SELECT id FROM Account LIMIT 1].Id;
    LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj,200));
    Test.startTest();
    UpdateCaseDetailsController.initiateOnLoadAPI(String.valueOf(accId));
    Test.stopTest();
  }
  @isTest
  static void initiateOnLoadAPIFailureTest() {
    Id caseId = [SELECT id FROM case LIMIT 1].Id;
    LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj,400));
    Test.startTest();
    try {
      UpdateCaseDetailsController.initiateOnLoadAPI(String.valueOf('caseId'));
    } catch (AuraHandledException ex) {
      System.debug(ex.getMessage());
    }

    Test.stopTest();
  }

  @isTest
  static void runRewardsAPI() {
    Case caseObj = [
      SELECT
        Id,
        Account.PersonEmail,
        Account.Phone,
        AccountId,
        Contact.Loyalty_ID__c,
        ContactId
      FROM case
      LIMIT 1
    ];
    LoyaltyAccountIntegration.GetAccountResponseWrapper obj = responsePayload();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(obj,200));
	
    Account accObj = [Select Id,FirstName,LastName,PersonEmail,Phone, PersonContactId, PersonContact.Loyalty_ID__c From Account LIMIT 1];
    Test.startTest();
    LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty = UpdateCaseDetailsController.runVSRewardAPI(
      accObj
    );
    UpdateCaseDetailsController.getTierCode(getCustomerLoyalty);
    UpdateCaseDetailsController.getVSCCType(getCustomerLoyalty);
    UpdateCaseDetailsController.getCustomerLocation(getCustomerLoyalty);
    Test.stopTest();
  }
  
  private class MockHttpResponseGenerator implements HttpCalloutMock {
    List<LoyaltyAccountIntegration.GetAccountResponseWrapper> response = new List<LoyaltyAccountIntegration.GetAccountResponseWrapper>();
    Integer statuscode;
    MockHttpResponseGenerator() {
    }

    MockHttpResponseGenerator(
      LoyaltyAccountIntegration.GetAccountResponseWrapper obj,Integer statuCodeInp
    ) {
      response.add(obj);
      statusCode=statuCodeInp;
    }

    public HTTPResponse respond(HTTPRequest req) {
      // System.assertEquals('https://cgridapitest.victoriassecret.com/customer/v4', req.getEndpoint());
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serialize(response));
      res.setStatusCode(statusCode);
      return res;
    }
  }
  static LoyaltyAccountIntegration.GetAccountResponseWrapper responsePayload() {
    LoyaltyAccountIntegration.GetAccountResponseWrapper g = new LoyaltyAccountIntegration.GetAccountResponseWrapper();
    g.id = 'b64140e5-1fba-4c32-abba-bfb3ad0f72df';
    g.rid = 'caa37e4a-63af-4610-8be3-9e51af74d3e2';
    g.brand = 'VSS';
    g.email = 'MSTESTER1AAA1111@VSS-US.COM';
    g.phone = '9803207694';
    g.firstName = 'SUMIT';
    g.lastName = 'SAHA';
    g.direct = false;
    g.phoneType = 'Mobile';
    g.address.streetAddress1 = '2300 WINDY RIDGE PKWY SE';
    g.address.city = 'ATLANTA';
    g.address.postalCode = '30339';
    g.address.state = 'GA';
    g.address.country = 'US';

    g.shipAddress.streetAddress1 = '1';
    g.shipAddress.city = 'GAHANNA';
    g.shipAddress.postalCode = '43230';
    g.shipAddress.state = 'OH';
    g.shipAddress.country = 'US';

    g.loyalty.id = '21779375655';
    // g.loyalty.type = null;
    g.loyalty.adsID = '12345623435';
    g.loyalty.status = 'A';
    g.loyalty.statusReason = null;
    g.loyalty.tierCode = 'VST3';
    g.loyalty.customerType = 'I';

    g.lastUpdateTime = '2022-09-22T21:25:52.254373';

    return g;
  }
}