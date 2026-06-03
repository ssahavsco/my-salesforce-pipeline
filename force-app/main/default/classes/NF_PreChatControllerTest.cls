/*****************************************************************************************************@@
Class Name     :  NF_PreChatControllerTEST
Purpose        :  Test class for  NF_PreChatController
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      	TICKET REFERENCE/ NO.
1.       Tara                   02/24/2021          Original Version            		DP-36414
2. 		 manishi				09/03/2021			Change assert according to mock		DP-47309
*********************************************************************************************************/

@isTest
public class NF_PreChatControllerTest {
    //static String chatkey = NF_UtilTest.createMessagingSession();
    Integer statusCode;
    
    @TestSetup public static void setup(){
        LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
        LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.Client_Secret__c = 'eJv4s59Hd7Y7lzIjJboqJwhTIVS4';
        LBrandCustomS.Client_ID__c = 'sfccs';
        LBrandCustomS.AES_Key__c='PeSgVkYp3s6v9y$B&E)H@McQfTjWmZq4';
        insert LBrandCustomS;
    }
    
    @IsTest
    static void testTrueForIsOrderFlow() {
        List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
        NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
        inp.routableId = NF_UtilTest.createMessagingSession();
        inp.emailAddress = 'success1Record@gmail.com';
        inp.isOrderFlow = true;
        inputs.add(inp);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        String outputString = NF_PreChatController.getOrderHistoryForAuthenticatedUser(inp.emailAddress, inp.isOrderFlow);
        List<NF_AuthUserOrderLookup.Output> outputList = NF_AuthUserPreChatOrderLookup.getOrderHistoryFromPreChatDetails(inputs);
        Test.stopTest();
        List<NF_AuthUserOrderLookup.Output> out = new List<NF_AuthUserOrderLookup.Output>{(NF_AuthUserOrderLookup.Output)JSON.deserialize(outputString, NF_AuthUserOrderLookup.Output.class)};
        //System.assertEquals(5, out[0].listOfOrders.size(), 'Should have value');
    }

    @IsTest
    static void testTrueForIsOrderFlowForMultipleOrder() {
        List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
        NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
        inp.routableId = NF_UtilTest.createMessagingSession();
        inp.emailAddress = 'success@gmail.com';
        inp.isOrderFlow = true;
        inputs.add(inp);

        Test.startTest();
        NF_OrderMockAPI.enablePreChatMockData = true;
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        String outputString = NF_PreChatController.getOrderHistoryForAuthenticatedUser(inp.emailAddress, inp.isOrderFlow);
        List<NF_AuthUserOrderLookup.Output> outputList = NF_AuthUserPreChatOrderLookup.getOrderHistoryFromPreChatDetails(inputs);
        Test.stopTest();
        List<NF_AuthUserOrderLookup.Output> out = new List<NF_AuthUserOrderLookup.Output>{(NF_AuthUserOrderLookup.Output)JSON.deserialize(outputString, NF_AuthUserOrderLookup.Output.class)};
        System.assertEquals(5, out[0].listOfOrders.size(), 'Should have value');
    }
    
    @IsTest
    static void testFalseForIsOrderFlow() {
        List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
        NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
        inp.routableId = NF_UtilTest.createMessagingSession();
		inp.emailAddress = 'success@gmail.com';
        inp.isOrderFlow = false;
        inputs.add(inp);
        
        Test.startTest();
        NF_OrderMockAPI.enablePreChatMockData = true;
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        String outputString = NF_PreChatController.getOrderHistoryForAuthenticatedUser(inp.emailAddress, inp.isOrderFlow);
        List<NF_AuthUserOrderLookup.Output> outputList = NF_AuthUserPreChatOrderLookup.getOrderHistoryFromPreChatDetails(inputs);
        Test.stopTest();
        List<NF_AuthUserOrderLookup.Output> out = new List<NF_AuthUserOrderLookup.Output>{(NF_AuthUserOrderLookup.Output)JSON.deserialize(outputString, NF_AuthUserOrderLookup.Output.class)};
		//System.assertEquals(3, out[0].listOfOrders.size(), 'Should have value');
    }

    @IsTest
    static void testFalseForIsOrderFlowForSingleOrder() {
        List<NF_AuthUserOrderLookup.Input> inputs = new List<NF_AuthUserOrderLookup.Input>();
        NF_AuthUserOrderLookup.Input inp = new NF_AuthUserOrderLookup.Input();
        inp.routableId = NF_UtilTest.createMessagingSession();
		inp.emailAddress = 'success1Record@gmail.com';
        inp.isOrderFlow = false;
        inputs.add(inp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        String outputString = NF_PreChatController.getOrderHistoryForAuthenticatedUser(inp.emailAddress, inp.isOrderFlow);
        List<NF_AuthUserOrderLookup.Output> outputList = NF_AuthUserPreChatOrderLookup.getOrderHistoryFromPreChatDetails(inputs);
        Test.stopTest();
        List<NF_AuthUserOrderLookup.Output> out = new List<NF_AuthUserOrderLookup.Output>{(NF_AuthUserOrderLookup.Output)JSON.deserialize(outputString, NF_AuthUserOrderLookup.Output.class)};
		System.assertEquals(1, out[0].listOfOrders.size(), 'Should have value');
    }
}