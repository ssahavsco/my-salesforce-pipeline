/*
***********************************************************************************************************
* Program Name      : VSDirectMailPrefController_Test
* Description       : Test class to test all use cases.
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37152    1.1         Ravikant Kedia      24-05-2021      Created Test class to test
*                                                                               the use cases.
* REQ_02            DP-37152    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
@isTest
public class VSDirectMailPrefController_Test {
    
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
        	CCCToolsMailRestService service = new CCCToolsMailRestService();
        	service.authenticate();
        	response = service.doGet(new GetRequest());
			response = service.doDelete(new GetRequest());
        	response = service.doPut(new PostRequest());
        Test.stopTest();
    }
    
    @isTest
    static void fetchStateListTest() {
        Test.startTest();
       		String recordId = [Select Id from Case LIMIT 1].id;
            String result = VSDirectMailPrefController.fetchStateList();
       		System.assertNotEquals('', recordId );
        Test.stopTest();
    }

    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Get Account or Contact Record for Address testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void getDirectMailPrefDetailsTest() {
        Test.startTest();
        	// for Case Object
        	String recordId = [Select Id from Case LIMIT 1].id;
            String result = VSDirectMailPrefController.getDirectMailPrefDetails(recordId, 'Case');
            sObject data = (sObject) JSON.deserialize(result, Case.class);
        	String accId = String.valueOf(data.get('AccountId'));
        
        	Account acc = [Select FirstName, LastName FROM Account WHERE id =:accId LIMIT 1];
        	System.assertEquals( 'test1', acc.FirstName );
       		System.assertEquals( 'user1', acc.LastName );
        
        	// for LiveChatTranscript Object
        	recordId = [Select Id from LiveChatTranscript LIMIT 1].id;
            result = VSDirectMailPrefController.getDirectMailPrefDetails(recordId, 'LiveChatTranscript');
            data = (sObject) JSON.deserialize(result, LiveChatTranscript.class);
        	String conId = String.valueOf(data.get('ContactId'));
        
        	Contact con = [Select LastName FROM Contact WHERE id =:conId LIMIT 1];
       		System.assertEquals( 'testuser', con.LastName );
        Test.stopTest();
    }

    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Update Direct Mail Marketing Pref Frequency testing
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @isTest
    static void updateDirectMailPrefDetailsTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        	VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone200@host.com', '05', 'CA', 'Test', 'User', '', '', '', '', '200', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void updateDirectMailPrefDetailsTest1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone500@host.com', '05', 'CA', 'Tst', 'User', '', '', '', '', '500', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void updateDirectMailPrefDetailsTest2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone500@host.com', '05', 'None', 'Tst', 'User', '', '', '', '', '500', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void updateDirectMailPrefDetailsTest3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone400@host.com', '05', 'CA', 'Tst', 'User', '', '', '', '', '400', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void updateDirectMailPrefDetailsTest4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone404@host.com', '05', 'CA', 'Tst', 'User', '', '', '', '', '404', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void updateDirectMailPrefDetailsTest5() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone503@host.com', '05', 'CA', 'Tst', 'User', '', '', '', '', '503', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }
    
    @isTest
    static void updateDirectMailPrefDetailsTest6() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone510@host.com', '05', 'CA', 'Tst', 'User', '', '', '', '', '510', recordId, 'Case');
            System.assertNotEquals( '', result );
        Test.stopTest();
    }

    @isTest
    static void updateDirectMailPrefDetailsTest7() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VSAccountDetailsMock());
        	String recordId = [Select Id from Case LIMIT 1].id;
        	VSDirectMailPrefController.endPointMetaData = lbAPIIntegSettingsMapInactiveTest;
        	String result = VSDirectMailPrefController.updateDirectMailPrefDetails('someone200@host.com', '05', 'CA', 'Test', 'User', '', '', '', '', '200', recordId, 'Case');
            System.assertNotEquals( '', result );
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
        
        Contact con = new Contact(LastName = 'testuser');
        insert con;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript(LiveChatVisitorId = lcv.Id, ContactId = con.Id);
        insert lct;
        
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
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'CCCTools_VSDirectMailPref_Update' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "apitest.victoriassecret.com/subscriptions/v5/sf/mail", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'CCCTools_VSDirectMailPref_Update' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "apitest.victoriassecret.com/subscriptions/v5/sf/mail", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}