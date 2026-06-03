/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for PHISTStoreTransactionService.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-29
* @modified       2021-04-29
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class PHISTStoreTransactionService_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }
    
    
    
    @isTest
    static void checkMaxFullfillmentStatusIdTest(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
        	PHISTStoreTransactionService service = new PHISTStoreTransactionService();
        	
        	PostRequest postReq = new PostRequest();
            postReq.setRelativeEndpoint( 'checkStatusId' );
        	postReq.setBody('{"Query": "OrderId = 123","Size": 100,"Template": {"OrderId": null,"CreatedTimestamp":null,"DoNotReleaseBefore": null,"MinFulfillmentStatusId": null,"MaxFulfillmentStatusId": null}}');
            RestResponse response = service.checkMaxFullfillmentStatusId( postReq );
            System.assertEquals( 200, response.getStatusCode() );
        Test.stopTest();
    }

    @isTest
    static void doGetTest(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionService service = new PHISTStoreTransactionService();
            // Success
            GetRequest getReq = new GetRequest();
            getReq.setRelativeEndpoint( 'doGetSuccess' );
            RestResponse response = service.doGet( getReq );
            System.assertEquals( 200, response.getStatusCode() );

            // Unsuccessful
            getReq = new GetRequest();
            getReq.setRelativeEndpoint( 'doGetFailure' );
            response = service.doGet( getReq );
            System.assertEquals( 403, response.getStatusCode() );
        Test.stopTest();
    }

    @isTest
    static void doPostTest1(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionService service = new PHISTStoreTransactionService();
            // Success
            PostRequest postReq = new PostRequest();
            postReq.setRelativeEndpoint( 'doPostSuccess' );
            postReq.setBody( 'RequestBody' );
            RestResponse response = service.doPost( postReq );
            System.assertEquals( 200, response.getStatusCode() );
        Test.stopTest();
    }
    
    @isTest
    static void doPostTest2(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionService service = new PHISTStoreTransactionService();
            // Unsuccessful
            PostRequest postReq = new PostRequest();
            postReq = new PostRequest();
            postReq.setRelativeEndpoint( 'doPostFailure' );
            postReq.setBody( 'RequestBody' );
            RestResponse response = service.doPost( postReq );
            System.assertEquals( 403, response.getStatusCode() );
        Test.stopTest();
    }
    
    @isTest
    static void doPostTest3(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionService service = new PHISTStoreTransactionService();
            // Unsuccessful due to authorization and then successful
            PostRequest postReq = new PostRequest();
            postReq = new PostRequest();
            postReq.setRelativeEndpoint( 'doPostSuccess' );
            postReq.setBody( 'RequestBody' );
            RestResponse response = service.doPost( postReq );
            System.assertEquals( 200, response.getStatusCode() );
        Test.stopTest();
    }

    @isTest
    static void coverageTest(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionService service = new PHISTStoreTransactionService();
            RestResponse response = service.doPut( new GetRequest() );
            response = service.doDelete( new GetRequest() );
         service.authenticate( );
        Test.stopTest();
    }

    private static void testSetupData(){

        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            PHIST_Client_Secret__c = 'clientSecret',
            PHIST_Client_Id__c     = 'clientId',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd'
        );
        insert testLBrandsAPI;
    }
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'AO_Authorization_Endpoint' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Request_Method__c" : "POST", "Endpoint__c" : "authenticationCancelOrderEndpoint", "Status_Code_400_Message__c" : "Failure" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}