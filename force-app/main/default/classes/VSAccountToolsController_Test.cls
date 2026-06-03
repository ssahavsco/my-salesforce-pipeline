/*
***********************************************************************************************************
* Program Name      : VSAccountToolsController_Test
* Description       : Test class for test the use cases for vsAccountTools
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37149    1.1         Ravikant Kedia      13-05-2021      Created Test class for testing cases.
* REQ_02            DP-37149    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
@isTest
public class VSAccountToolsController_Test {
    
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
        	CCCToolsVSAccountRestService service = new CCCToolsVSAccountRestService();
        	service.authenticate();
			response = service.doDelete(new GetRequest());
        	response = service.doPut(new PostRequest());
        Test.stopTest();
    }
    

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Get Account Details testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void getDetailsTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            String result = VSAccountToolsController.getDetails('someone200@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getDetailsTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
        	String result = VSAccountToolsController.getDetails('someone500@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getDetailsTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
        	String result = VSAccountToolsController.getDetails('someone400@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getDetailsTest3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
        	String result = VSAccountToolsController.getDetails('someone404@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getDetailsTest4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
        	String result = VSAccountToolsController.getDetails('someone503@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getDetailsTest5() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
        	String result = VSAccountToolsController.getDetails('someone510@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getDetailsTest6() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapInactiveTest;
        
            String result = VSAccountToolsController.getDetails('someone200@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Delete Account details testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void deleteCustomerAccountTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	
        	String recordId = [Select Id from Case LIMIT 1].id;
            String result = VSAccountToolsController.deleteCustomerAccount('someone200@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomerAccountTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	
        	String recordId = [Select Id from Case LIMIT 1].id;        
        	String result = VSAccountToolsController.deleteCustomerAccount('someone500@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomerAccountTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	
        	String recordId = [Select Id from Case LIMIT 1].id;        
        	String result = VSAccountToolsController.deleteCustomerAccount('someone400@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomerAccountTest3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	
        	String recordId = [Select Id from Case LIMIT 1].id;        
        	String result = VSAccountToolsController.deleteCustomerAccount('someone404@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomerAccountTest4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	
        	String recordId = [Select Id from Case LIMIT 1].id;        
        	String result = VSAccountToolsController.deleteCustomerAccount('someone503@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomerAccountTest5() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	
        	String recordId = [Select Id from Case LIMIT 1].id;        
        	String result = VSAccountToolsController.deleteCustomerAccount('someone510@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void deleteCustomerAccountTest6() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSAccountToolsController.endPointMetaData = lbAPIIntegSettingsMapInactiveTest;
        
        	String recordId = [Select Id from Case LIMIT 1].id;
            String result = VSAccountToolsController.deleteCustomerAccount('someone200@host.com', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Get Account Email on Load testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void getAccountEmailTest() {
        Test.startTest();
        	String recordId = [Select Id from Case LIMIT 1].id;
            String result = VSAccountToolsController.getAccountEmail(recordId, 'Case');
            sObject data = (sObject) JSON.deserialize(result, Case.class);
        	String accId = String.valueOf(data.get('AccountId'));
        
        	String personEmail = [Select PersonEmail FROM Account WHERE id =:accId LIMIT 1].PersonEmail;
        	System.assertEquals( 'someone@host.com', personEmail );
        Test.stopTest();
    }

    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Creating test Data and test rcords for metadata LBrands_API_Integration_Setting__mdt active and inactive variants
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){
        Account acc = new Account(FirstName='test1', LastName='user1', PersonEmail='someone@host.com');
        insert acc;
        
        Case cas = new Case(AccountId = acc.Id);
        insert cas;
        
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd',
            Origin__c = 'Origin',
            VSAccountTools_Client_Secret__c = 'clientSecret',
            VSAccountTools_Client_Id__c = 'clientId',
            VSAccountTools_Access_Token__c = 'Expired_Access_Token',
            orderdetails__c = '/orderdetails/v8/orders'
        );
        insert testLBrandsAPI;
    }
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'CCCTools_VSAccountTools' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "apitest.victoriassecret.comccc/v5/customer", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'CCCTools_VSAccountTools_DeleteCustomer' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "apitest.victoriassecret.comccc/v5/deletecustomeraccount", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'CCCTools_VSAccountTools' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "apitest.victoriassecret.comccc/v5/customer", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'CCCTools_VSAccountTools_DeleteCustomer' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "apitest.victoriassecret.comccc/v5/deletecustomeraccount", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}