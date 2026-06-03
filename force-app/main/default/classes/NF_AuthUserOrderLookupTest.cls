/**
 * Created by adamundus on 9/14/20.
 * Modified By - Himanshu Mishra - 02/28/2025
 * Accomodate MIAW changes
 */

@IsTest
public class NF_AuthUserOrderLookupTest {
  Integer statusCode;

  public NF_AuthUserOrderLookupTest(Integer statusCode) {
    this.statusCode = statusCode;
  }

  @TestSetup
  public static void setup() {
    LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
    LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
    LBrandCustomS.Client_Secret__c = 'eJv4s59Hd7Y7lzIjJboqJwhTIVS4';
    LBrandCustomS.Client_ID__c = 'sfccs';
    LBrandCustomS.AES_Key__c = 'PeSgVkYp3s6v9y$B&E)H@McQfTjWmZq4';
    LBrandCustomS.OrderDetails__c = '/orderdetails/v8/orders';
    insert LBrandCustomS;

    //LiveChatTranscript livechatTransObj = new LiveChatTranscript();
    //LiveChatVisitor liveChatVisitorObj = new LiveChatVisitor();
    MessagingSession msgSession = new MessagingSession();
    MessagingEndUser endUser = new MessagingEndUser();

    try {
      //livechatTransObj.ChatKey = 'acfgcbc';
      //msgSession.JWT_Token__c = 'Zv9LnzlXZcRpPPqOp0s5VAlxAQZbtFSy0ijQsUEzNAp9Wmw/1h6GL3lJ9DYhg/kdL5+9MXV91FnGG9mcRA2yniZenmXEpxpDi91oNk49tg9E+Bd26HcSDiMWypKZAUpeSWstlDfp2XJNu7zSrfqh3XfBYizQGZV20T9fm1GqRI6KAVigQGmPl/Tw6lO+f/Qahf4ACWm4kt644bwIO/4jUUhHYCKNIHYTH1meSmYxmaK2gHyqbc23iLKRWMSDaNgYTem/d4XmI1Vd3HCt2sM73o0w1KQZDsJebwezkaMDauEfzY3MDEuWbd7IdDyHdN/jQno7MMlqKB0eCctKeJgNXbrx6x26S95BOQKhFiMT+TKs8vmDLdMokb2lz8jUSh/K8+pNk9g98UejFxMSKqW5g0Jg9OIyXnMJtEh3mwZa4mlb0L3pouiqsqoXSrL0VVm3G4NWV2E3xKS5vtHFI92YQnd2CETi3qrrVDAVoO0qoxSfd/FR930x2EZIFHBKpJpHd94UrWf77seDarq7bZkxNWtWkPwT9tgG/mxoWbxeiPTls6OkPmgJLuBNjM2/Mhan';
      //insert msgSession;
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception: ' + e);
    }
  }

  @IsTest
  static void testTrueForIsOrderFlowWith1Record() {
    List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
    NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
    //routableId = NF_UtilTest.createMessagingSession();
    inp.routableId = NF_UtilTest.createMessagingSession();
    inp.emailAddress = 'success1Record@gmail.com';
    inp.isOrderFlow = true;
    inputs.add(inp);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
    List<NF_AuthUserOrderLookup.Output> out = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      inputs
    );
    Test.stopTest();
    System.assertEquals(1, out[0].listOfOrders.size(), 'Should have value');
  }
    @IsTest
  static void testFalseForIsOrderFlowWith1Record() {
    List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
    NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
    //routableId = NF_UtilTest.createMessagingSession();
    inp.routableId = NF_UtilTest.createMessagingSession();
    inp.emailAddress = 'success1Record@gmail.com';
    inp.isOrderFlow = false;
    inputs.add(inp);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
    List<NF_AuthUserOrderLookup.Output> out = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      inputs
    );
    Test.stopTest();
    System.assertEquals(1, out[0].listOfOrders.size(), 'Should have value');
  }
    @IsTest
  static void testTrueForIsOrderFlow() {
    List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
    NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
    //routableId = NF_UtilTest.createMessagingSession();
    inp.routableId = NF_UtilTest.createMessagingSession();
    inp.emailAddress = 'success@gmail.com';
    inp.isOrderFlow = true;
    inputs.add(inp);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
    List<NF_AuthUserOrderLookup.Output> out = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      inputs
    );
    Test.stopTest();
    System.assertEquals(5, out[0].listOfOrders.size(), 'Should have value');
  }
    @IsTest
  static void testWithErrorResponse() {
    List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
    NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
    //routableId = NF_UtilTest.createMessagingSession();
    inp.routableId = NF_UtilTest.createMessagingSession();
    inp.emailAddress = '';
    inp.isOrderFlow = true;
    inputs.add(inp);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
    List<NF_AuthUserOrderLookup.Output> out = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      inputs
    );
    Test.stopTest();
    System.assertEquals(0, out[0].orderResponseSize, 'Order Response size should be 0 because of Exception');
  }
  
  @IsTest
  static void testFalseForIsOrderFlow() {
    List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
    NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
    inp.routableId = NF_UtilTest.createMessagingSession();

    inp.isOrderFlow = false;
    inp.emailAddress = 'success@gmail.com';
    inputs.add(inp);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
    List<NF_AuthUserOrderLookup.Output> out = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      inputs
    );
    Test.stopTest();
    System.assertNotEquals(null, out[0].listOfOrders, 'Should have value');
  }

  @isTest
  static void validate() {
    Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
    Test.startTest();
    //Case1
    NF_AuthUserOrderLookup.Input input = new NF_AuthUserOrderLookup.Input();
    input.routableId = 'abc';
    input.emailAddress = 'test@neuraflash.com';
    input.isOrderFlow = true;
    List<NF_AuthUserOrderLookup.Output> output = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      new List<NF_AuthUserOrderLookup.Input>{ input }
    );

    //Case2
    input.isOrderFlow = false;
    output = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      new List<NF_AuthUserOrderLookup.Input>{ input }
    );

    //case3
    input = new NF_AuthUserOrderLookup.Input();
    input.routableId = 'abc';
    input.isOrderFlow = true;
    output = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      new List<NF_AuthUserOrderLookup.Input>{ input }
    );

    //case4
    input.isOrderFlow = false;
    output = NF_AuthUserOrderLookup.getOrderHistoryForAuthenticatedUser(
      new List<NF_AuthUserOrderLookup.Input>{ input }
    );
    Test.stopTest();
  }
}