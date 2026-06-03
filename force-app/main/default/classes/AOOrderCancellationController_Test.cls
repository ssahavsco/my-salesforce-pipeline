/*
***********************************************************************************************************
* Program Name      : AOOrderCancellationController_Test
* Description       : Test class for test the use cases for AOOrderCancellationController
* Version           : 1.1
* Modification Log  : 16-08-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-39921    1.1         Ravikant Kedia      13-05-2021      Created Test class for testing cases.
***********************************************************************************************************
*/
@isTest
public class AOOrderCancellationController_Test {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Setup method to create test data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestSetup
    static void setupData(){
        testSetupData();
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Calling unused method of service class for coverage
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void callEmptyMethods() {
        Test.startTest();
        	RestResponse response = new RestResponse();
        	AOOrderCancellationService service = new AOOrderCancellationService();
            response = service.doGet(new GetRequest());
            response = service.doPut(new PostRequest());
			response = service.doDelete(new PostRequest());
        Test.stopTest();
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Cancel Order testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void cancelOrderTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order200';
        	cbInput.reasonId = 'Customer Request';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
            
        	result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( true, result[0].result );
        
        	cbInput.orderId = 'Order400';
        	result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        	
        	cbInput.orderId = 'Order404';
        	result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        
        	cbInput.orderId = 'Order500';
        	result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        
        	cbInput.orderId = 'Order503';
        	result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        
        	cbInput.orderId = 'Order510';
        	result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order200';
        	cbInput.reasonId = 'success';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( true, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order400';
        	cbInput.reasonId = 'AuthFail';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order404';
        	cbInput.reasonId = 'AuthFail';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order500';
        	cbInput.reasonId = 'AuthFail';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest5() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order503';
        	cbInput.reasonId = 'AuthFail';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest6() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order510';
        	cbInput.reasonId = 'AuthFail';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    @isTest
    static void cancelOrderTest7() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapInactiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order200';
        	cbInput.reasonId = 'Customer Request';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Calling cancelOrderTest8 method for covering catch block
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void cancelOrderTest8() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'ExeptionOrder';
        	cbInput.reasonId = 'Customer Request';
        	cbInput.cancelComments = 'Cancelled by Digital Assistant';        
        
        	cbInputList.add(cbInput);
        
            result = AOOrderCancellationController.cancelOrder( cbInputList );
            System.assertEquals( false, result[0].result );
        Test.stopTest();
    }
        
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Creating test Data and test rcords for metadata LBrands_API_Integration_Setting__mdt active and inactive variants
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData() {
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd',
            Origin__c = 'Origin',
            AO_Access_Token_1__c = 'Invalid_Token'
        );
        insert testLBrandsAPI;
    }
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest {
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'AO_Order_Cancellation' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "Cancel_Order", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
               	'AO_Authorization_Endpoint' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "Auth_Access_Token", "Request_Method__c" : "POST", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest {
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'AO_Order_Cancellation' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "Cancel_Order", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}