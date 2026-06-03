/*
***********************************************************************************************************
* Program Name      : VSEmailPrefController_Test
* Description       : Test class to test all use cases of controller.
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37150    1.1         Ravikant Kedia      24-05-2021      Created Test class to test the use cases..
* REQ_02            DP-37150    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
@isTest
public class VSEmailPrefController_Test {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Calling unused method of service class for coverage
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void callEmptyMethods() {
        Test.startTest();
        	RestResponse response = new RestResponse();
        	CCCToolsEmailRestService service = new CCCToolsEmailRestService();
        	service.authenticate();
			response = service.doDelete(new GetRequest());
        	response = service.doPut(new PostRequest());
        Test.stopTest();
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Get Email Pref Frequency detail testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void getEmailPrefDetailsTest() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            String result = VSEmailPrefController.getEmailPrefDetails('someone200@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getEmailPrefDetailsTest1() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
     
        	String result = VSEmailPrefController.getEmailPrefDetails('someone500@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getEmailPrefDetailsTest2() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
     
        	String result = VSEmailPrefController.getEmailPrefDetails('someone400@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getEmailPrefDetailsTest3() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
     
        	String result = VSEmailPrefController.getEmailPrefDetails('someone404@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getEmailPrefDetailsTest4() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
     
        	String result = VSEmailPrefController.getEmailPrefDetails('someone503@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getEmailPrefDetailsTest5() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
     
        	String result = VSEmailPrefController.getEmailPrefDetails('someone510@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void getEmailPrefDetailsTest6() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapInactiveTest;
        
            String result = VSEmailPrefController.getEmailPrefDetails('someone200@host.com');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Update Email Pref Frequency testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest 
    static void updateEmailPrefDetailsTest() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
            String result = VSEmailPrefController.updateEmailPrefDetails('someone200@host.com', '05', case1.Id ,'Case');
            CCCToolsVSEmailPrefWrapper wrap = (CCCToolsVSEmailPrefWrapper) System.JSON.deserialize(result, CCCToolsVSEmailPrefWrapper.class);
        	System.assertNotEquals( '', wrap.cid );
        Test.stopTest();
    }
    
    @isTest 
    static void updateEmailPrefDetailsTest1() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
        	String result = VSEmailPrefController.updateEmailPrefDetails('someone500@host.com', '05', case1.Id ,'Case');
        	System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest 
    static void updateEmailPrefDetailsTest2() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
        	String result = VSEmailPrefController.updateEmailPrefDetails('someone400@host.com', '05', case1.Id ,'Case');
        	System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest 
    static void updateEmailPrefDetailsTest3() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
        	String result = VSEmailPrefController.updateEmailPrefDetails('someone404@host.com', '05', case1.Id ,'Case');
        	System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest 
    static void updateEmailPrefDetailsTest4() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
        	String result = VSEmailPrefController.updateEmailPrefDetails('someone503@host.com', '05', case1.Id ,'Case');
        	System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest 
    static void updateEmailPrefDetailsTest5() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
        	String result = VSEmailPrefController.updateEmailPrefDetails('someone510@host.com', '05', case1.Id ,'Case');
        	System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest 
    static void updateEmailPrefDetailsTest6() {
        Case cas = new Case();
        insert cas;
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	VSEmailPrefController.endPointMetaData = lbAPIIntegSettingsMapInactiveTest;
        
            Case case1 = [Select Id from Case LIMIT 1];
            String result = VSEmailPrefController.updateEmailPrefDetails('someone200@host.com', '05', case1.Id ,'Case');
            CCCToolsVSEmailPrefWrapper wrap = (CCCToolsVSEmailPrefWrapper) System.JSON.deserialize(result, CCCToolsVSEmailPrefWrapper.class);
        	System.assertNotEquals( '', wrap.cid );
        Test.stopTest();
    }
    
  
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Creating test Data and test rcords for metadata LBrands_API_Integration_Setting__mdt active and inactive variants
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestSetup
    static void setupData(){
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd',
            Origin__c = 'Origin',
            VSAccountTools_Client_Secret__c = 'clientSecret',
            VSAccountTools_Client_Id__c = 'clientId',
            VSAccountTools_Access_Token__c = 'Expired_Access_Token'
        );
        insert testLBrandsAPI;
    }
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'CCCTools_VSEmailPref_Detail' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "apitest.victoriassecret.com/ccc/v5/emailpref", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'CCCTools_VSEmailPref_Update' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "apitest.victoriassecret.com/ccc/v5/updateemailpref", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'CCCTools_VSEmailPref_Detail' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "apitest.victoriassecret.com/ccc/v5/emailpref", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'CCCTools_VSEmailPref_Update' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "apitest.victoriassecret.com/ccc/v5/updateemailpref", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}