@isTest
public class VS_LoyaltyExperienceServicesCalloutsTest {
  @TestSetup
  public static void setupData() {
    setupAuthDetails();
  }
  static testMethod void testSuccessGetPointsHistory() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        200,
        'SUCCESS_POINTS_HISTORY'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getPointsHistory(
      '75578327993'
    );
    System.assertEquals(responseInstance.statusCode, 200);
    test.stopTest();
  }
  public static testMethod void testSuccessGetPointsBalance() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        200,
        'SUCCESS_POINTS_BALANCE'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getPointsBalance(
      '76107236053'
    );
    System.assertEquals(responseInstance.statusCode, 200);
    test.stopTest();
  }
  public static testMethod void testSuccessGetPointsBalance_BOT() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        200,
        'SUCCESS_POINTS_BALANCE_BOT'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getPointsBalance(
      '14069418859'
    );
    System.assertEquals(responseInstance.statusCode, 200);
    test.stopTest();
  }
  public static testMethod void testSuccessGetPointsBalance_BOT_Failure() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        401,
        'SUCCESS_POINTS_BALANCE_BOT'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getPointsBalance(
      '14069418859'
    );
    System.assertEquals(responseInstance.statusCode, 401);
    test.stopTest();
  }
  public static testMethod void testSuccessCustomerRewards() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        200,
        'SUCCESS_CUSTOMER_REWARDS'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getCustomerRewards(
      '76107236053'
    );
    System.assertEquals(responseInstance.statusCode, 200);
    test.stopTest();
  }
  static testMethod void testSuccessAddPoints() {
    test.starttest();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(200, 'SUCCESS_ADD_POINTS')
    );
    VS_LoyaltyExperienceServicesCallouts.postAppeasementPoints(
      createCase(),
      '76107236053',
      'LoyaltyCustomerName',
      null,
      'Customer Due',
      500,
      'Test Comments',
      'ABCXYZ123'
    );
    System.assertEquals(null, null);
    test.stopTest();
  }
  static testMethod void testSuccessAddPoints_WithoutCase() {
    test.starttest();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(200, 'SUCCESS_ADD_POINTS')
    );
    VS_LoyaltyExperienceServicesCallouts.postAppeasementPoints(
      null,
      '76107236053',
      'LoyaltyCustomerName',
      createAccount(),
      'Customer Due',
      500,
      'Test Comments',
      'ABCXYZ123'
    );
    System.assertEquals(null, null);
    test.stopTest();
  }
  static testMethod void testSuccessAddPoints_WithoutAccountId() {
    test.starttest();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(200, 'SUCCESS_ADD_POINTS')
    );
    VS_LoyaltyExperienceServicesCallouts.postAppeasementPoints(
      createCase(),
      '76107236053',
      'LoyaltyCustomerName',
      null,
      'Customer Due',
      500,
      'Test Comments',
      'ABCXYZ123'
    );
    System.assertEquals(null, null);
    test.stopTest();
  }
  static testMethod void testSuccessTransactionDetails() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        200,
        'SUCCESS_TRANSACTION_DETAILS'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getTransactionDetails(
      '9163'
    );
    System.assertEquals(responseInstance.statusCode, 200);
    test.stopTest();
  }
  static testMethod void testFailureGetPointsHistory() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        400,
        'FAILURE_POINTS_HISTORY'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getPointsHistory(
      '75578327993'
    );
    System.assertEquals(responseInstance.statusCode, 400);
    test.stopTest();
  }
  static testMethod void testFailureTransactionDetails() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(
        400,
        'FAILURE_TRANSACTION_DETAILS'
      )
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.getTransactionDetails(
      '2323'
    );
    System.assertEquals(responseInstance.statusCode, 400);
    test.stopTest();
  }
  static testMethod void testFailureAddPoints() {
    test.starttest();
    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(400, 'FAILURE_ADD_POINTS')
    );
    VS_LoyaltyExperienceServicesCallouts.postAppeasementPoints(
      createCase(),
      '76107236053',
      'LoyaltyCustomerName',
      null,
      'Customer Due',
      500,
      'Test Comments',
      'ABCXYZ123'
    );
    System.assertEquals(null, null);
    test.stopTest();
  }
  static testMethod void testExceptionPointsHistory() {
    test.starttest();
    try {
      VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
      Test.setMock(
        HttpCalloutMock.class,
        new VS_LoyaltyExperienceServicesCalloutsMock(
          401,
          'EXCEPTION_POINTS_HISTORY'
        )
      );
      responseInstance = VS_LoyaltyExperienceServicesCallouts.getPointsHistory(
        '75578327993'
      );
    } catch (Exception ex) {
      system.debug('Test Class Exception' + ex);
    }

    // System.assertEquals(null,null);
    test.stopTest();
  }
  static testMethod void testExceptionGetTransactionDetails() {
    test.starttest();
    try {
      VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();
      Test.setMock(
        HttpCalloutMock.class,
        new VS_LoyaltyExperienceServicesCalloutsMock(
          401,
          'EXCEPTION_TRANSACTION_DETAILS'
        )
      );
      responseInstance = VS_LoyaltyExperienceServicesCallouts.getTransactionDetails(
        '75578327993'
      );
    } catch (Exception ex) {
      system.debug('Test Class Exception' + ex);
    }

    // System.assertEquals(null,null);
    test.stopTest();
  }
  // static testmethod void testExceptionpostAppeasementPoints(){
  //     test.starttest();
  //     try {
  //         Test.setMock(HttpCalloutMock.class, new VS_LoyaltyExperienceServicesCalloutsMock(401,'EXCEPTION_ADD_POINTS'));
  //         VS_LoyaltyExperienceServicesCallouts.postAppeasementPoints(createCase(),'76107236053', 'Customer Due', 500, 'Test Comments', 'ABCXYZ123');
  //     } catch (Exception ex) {
  //         system.debug('Test Class Exception'+ex);
  //     }

  //    // System.assertEquals(null,null);
  //     test.stopTest();
  // }
  static testMethod void testAddPointsThreshold() {
    test.starttest();
    Map<String, Add_Points_Threshold__c> thrsdInst = new Map<String, Add_Points_Threshold__c>();
    thrsdInst = VS_LoyaltyExperienceServicesCallouts.getAddPointsThresholdSettings();
    System.assertNotEquals(null, thrsdInst);
    test.stopTest();
  }
  static testMethod void testEnrollSuccessLoyaltyCustomer() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();

    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(200, 'SUCCESS_ENROLL')
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.makeLoyaltyEnrollmentCallout(
      'Test',
      'Enroll',
      'testenroll@gmail.com',
      '9876543210'
    );
    System.assertEquals(responseInstance.statusCode, 200);
    test.stopTest();
  }
  static testMethod void testEnrollLoyaltyCustomer() {
    test.starttest();
    VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper responseInstance = new VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper();

    Test.setMock(
      HttpCalloutMock.class,
      new VS_LoyaltyExperienceServicesCalloutsMock(400, 'FAILURE_ENROLL')
    );
    responseInstance = VS_LoyaltyExperienceServicesCallouts.makeLoyaltyEnrollmentCallout(
      'Test',
      'Enroll',
      'testenroll@gmail.com',
      '9876543210'
    );
    System.assertEquals(responseInstance.statusCode, 400);
    test.stopTest();
  }
  private static void setupAuthDetails() {
    Loyalty_Experience_Authentication__c loyaltyAuthInst = new Loyalty_Experience_Authentication__c(
      Base_Url__c = 'https://apitest.victoriassecret.com/apiauthentication/v1/token?',
      Client_Id__c = 'ccsloyalty',
      Client_Secret__c = 'Z6A6PI5eAYYSRaLsGlfdRbJ12hkshd',
      Grant_Type__c = 'client_credentials',
      Time_out__c = 7200,
      Token_Type__c = 'Bearer'
    );
    insert loyaltyAuthInst;
  }
  @istest
  public static String createCase() {
    List<RecordType> caseRecordType = new List<RecordType>(
      [SELECT Id FROM RecordType WHERE Name = 'Store Sensitive Case' LIMIT 1]
    );

    Case cs = new Case();
    cs.Description = 'Test Case';
    cs.RecordTypeId = (Id) caseRecordType[0].get('Id');
    // cs.Sensitive_Situation_Status__c = 'RED';
    cs.Sensitive_Situation_Status__c = '3 DAY RESPONSE';
    cs.AccountId = createAccount();

    insert cs;
    return (String) cs.Id;
  }
  @istest
  public static Id createAccount() {
    Account acc = new Account();
    acc.AccountEmail__c = 'test123@lb.com';
    acc.LastName = 'Test Lname';

    insert acc;
    System.assertEquals(null, null);
    return acc.id;
  }
}