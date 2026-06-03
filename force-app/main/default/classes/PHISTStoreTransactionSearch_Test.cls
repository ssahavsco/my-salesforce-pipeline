/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for PHISTStoreTransactionSearch.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-23
* @modified       2021-05-14
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          ravikant.kedia@neuraflash.com
* 2021-04-29    updated test data

* v1.0          ravikant.kedia@neuraflash.com
* 2021-05-14    updated setup data
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class PHISTStoreTransactionSearch_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    static void getOrderHistoryEmailTest1(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test1.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Success
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryEmailTest2(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test1.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // No customer found regarding the emailId
            data.email = 'exceptionEmail';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( 'No results found, please try again.', res.errorMessage );

            // Unsuccessful Callout
            data.email = 'test@test2.com';
            result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
            
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            data.email = 'test@test1.com';
            result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryEmailTest3(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test1.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Unsuccessful Callout
            data.email = 'test@test2.com';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
            
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            data.email = 'test@test1.com';
            result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }

    @isTest
    static void getOrderHistoryEmailTest4(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test1.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            data.email = 'test@test1.com';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryCustomerNameTest1(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByCustomerName';
        data.firstName = 'Valid';
        data.lastName = 'Name';
        data.zipCode = '123456';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Success
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }

    @isTest
    static void getOrderHistoryCustomerNameTest2(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByCustomerName';
        data.firstName = 'Valid';
        data.lastName = 'Name';
        data.zipCode = '123456';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Unsuccessful Callout
            data.firstName = 'Invalid';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
            
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryCustomerNameTest3(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByCustomerName';
        data.firstName = 'Valid';
        data.lastName = 'Name';
        data.zipCode = '123456';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryStoreTransactionIdTest1(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByStoreTransactionId';
        data.storeTransactionId = 'storeTransactionTestId';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Success
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }

    @isTest
    static void getOrderHistoryStoreTransactionIdTest2(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByStoreTransactionId';
        data.storeTransactionId = 'storeTransactionTestId';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Unsuccessful Callout
            data.storeTransactionId = 'ExceptionId';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
            
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryStoreTransactionIdTest3(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByStoreTransactionId';
        data.storeTransactionId = 'storeTransactionTestId';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryAmountTest1(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByAmount';
        data.transactionDate = '2021-04-20';
        data.storeNumber = '50001';
        data.amount = 'CorrectAmount';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Success
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }

    @isTest
    static void getOrderHistoryAmountTest2(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByAmount';
        data.transactionDate = '2021-04-20';
        data.storeNumber = '50001';
        data.amount = 'CorrectAmount';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Unsuccessful Callout
            data.amount = 'IncorrectAmount';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryAmountTest3(){
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByAmount';
        data.transactionDate = '2021-04-20';
        data.storeNumber = '50001';
        data.amount = 'CorrectAmount';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
			// Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryPaymentTypeTest1() {
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByPaymentType';
        data.transactionDate = '2021-04-20';
        data.storeNumber = '50001';
        data.paymentType = 'Credit';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Success
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryPaymentTypeTest2() {
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByPaymentType';
        data.transactionDate = '2021-04-20';
        data.storeNumber = '50001';
        data.paymentType = 'Credit';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Unsuccessful Callout
            data.paymentType = 'Cash';
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryPaymentTypeTest3() {
        PHISTStoreTransactionSearch.SearchData data = new PHISTStoreTransactionSearch.SearchData();
        data.searchType = 'searchByPaymentType';
        data.transactionDate = '2021-04-20';
        data.storeNumber = '50001';
        data.paymentType = 'Credit';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Inactive metadata
            PHISTStoreTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            String result = PHISTStoreTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTStoreTransactionSearch.InitialResponse res = ( PHISTStoreTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTStoreTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            //System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){
        
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            PHIST_Client_Secret__c = 'clientSecret',
            PHIST_Client_Id__c     = 'clientId',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd'
        );
        insert testLBrandsAPI;
        
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount1 = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account1',
            PersonEmail  = 'test@test1.com',
            SAP_Store__c = '1300',
            CID__c       = 'TestCID'
        );
        insert testAccount1;
        Account testAccount2 = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account2',
            PersonEmail  = 'test@test2.com',
            CID__c = 'TestCIDException'
        );
        insert testAccount2;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * test rcords for metadata LBrands_API_Integration_Setting__mdt active and inactive variants
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'PHIST_Search_By_Customer' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "searchByCustomerStoreTransaction", "Status_Code_400_Message__c" : "Failure" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
				'PHIST_Search_By_OrderId' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "searchByStoreTransactionId", "Status_Code_400_Message__c" : "Failure" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
				'PHIST_Search_By_StoreOrder' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "searchByStoreOrder", "Status_Code_400_Message__c" : "Failure" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'PHIST_Search_By_Customer' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "searchByCustomer", "Status_Code_400_Message__c" : "Failure" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
				'PHIST_Search_By_OrderId' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "searchByStoreTransactionId", "Status_Code_400_Message__c" : "Failure" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
				'PHIST_Search_By_StoreOrder' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "searchByStoreOrder", "Status_Code_400_Message__c" : "Failure" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}