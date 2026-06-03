/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for PHISTDigitalOrderTransactionSearch.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-23
* @modified       2021-05-21
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          ravikant.kedia@neuraflash.com
* 2021-04-29    added comments

* v1.0          ravikant.kedia@neuraflash.com
* 2021-05-21    added method deleteOrderTest()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class PHISTDigitalOrderTransactionSearch_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    static void getOrderHistoryEmailTestWith404StatusCode(){

        Integer cancelTimeStamp = PHISTDigitalOrderTransactionSearch.cancelTimeStamp();
        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(404) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryEmailTest2(){

        Integer cancelTimeStamp = PHISTDigitalOrderTransactionSearch.cancelTimeStamp();
        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Unsuccessful Callout
            data.email = 'exceptionEmail';
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( '{"Error" : "Error"}' , res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryEmailTestWith500StatusCode(){

        Integer cancelTimeStamp = PHISTDigitalOrderTransactionSearch.cancelTimeStamp();
        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(500) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
        Test.stopTest();
    }
    @isTest
    static void getOrderHistoryEmailTestWith503StatusCode(){

        Integer cancelTimeStamp = PHISTDigitalOrderTransactionSearch.cancelTimeStamp();
        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(503) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryEmailTest3(){
        Integer cancelTimeStamp = PHISTDigitalOrderTransactionSearch.cancelTimeStamp();
        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByEmail';
        data.email = 'test@test.com';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            
            // Inactive metadata
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            data.email = 'test@test.com';
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }

    @isTest
    static void getOrderHistoryCustomerNameTest1(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByCustomerName';
        data.firstName = 'Valid';
        data.lastName = 'Name';
        data.zipCode = '123456';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryCustomerNameTest2(){
        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByCustomerName';
        data.firstName = 'Valid';
        data.lastName = 'Name';
        data.zipCode = '123456';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Unsuccessful Callout
            data.firstName = 'Invalid';
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( '{"Error" : "Error"}' , res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryCustomerNameTest3(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByCustomerName';
        data.firstName = 'Valid';
        data.lastName = 'Name';
        data.zipCode = '123456';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Inactive metadata
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryOrderNumberTest1(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByOrderNumber';
        data.orderNumber = 'orderTestNumber';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( true, res.success );
        Test.stopTest();
    }
    @isTest
    static void getOrderHistoryOrderNumberTestWith404Code(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByOrderNumber';
        data.orderNumber = 'orderTestNumber';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(404) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
        Test.stopTest();
    }
    @isTest
    static void getOrderHistoryOrderNumberTestWith500Code(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByOrderNumber';
        data.orderNumber = 'orderTestNumber';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(500) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
        Test.stopTest();
    }
    @isTest
    static void getOrderHistoryOrderNumberTestWith503Code(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByOrderNumber';
        data.orderNumber = 'orderTestNumber';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(503) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Success
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
        Test.stopTest();
    }
    
    @isTest
    static void getOrderHistoryOrderNumberTest2(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByOrderNumber';
        data.orderNumber = 'orderTestNumber';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            // Unsuccessful Callout
            data.orderNumber = 'ExceptionNumber';
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( null, res.errorMessage );
        Test.stopTest();
    }

    @isTest
    static void getOrderHistoryOrderNumberTest3(){

        PHISTDigitalOrderTransactionSearch.SearchData data = new PHISTDigitalOrderTransactionSearch.SearchData();
        data.searchType = 'searchByOrderNumber';
        data.orderNumber = 'orderTestNumber';
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Inactive metadata
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            data.orderNumber = 'orderNumber';
            String result = PHISTDigitalOrderTransactionSearch.getOrderHistory( JSON.serialize( data ) );
            PHISTDigitalOrderTransactionSearch.InitialResponse res = ( PHISTDigitalOrderTransactionSearch.InitialResponse )JSON.deserialize(
                result, PHISTDigitalOrderTransactionSearch.InitialResponse.class
            );
            System.assertEquals( false, res.success );
            System.assertEquals( 'Failure', res.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void deleteOrderTest1(){
        Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case LIMIT 1 ];
        System.assert( String.isBlank( cs.Type ) );
        System.assert( String.isBlank( cs.Sub_Type__c ) );

        PHISTorderTransactionWrapper.ResponseOrder orderData = new PHISTorderTransactionWrapper.ResponseOrder();
        orderData.OrderId                = 'ExceptionOrder';
        orderData.MaxFulfillmentStatusId = '1000';
        orderData.MinFulfillmentStatusId = '1500';
        orderData.CreatedTimestamp       = '2020-10-16T17:50:20.904';
        orderData.OrderType              = new PHISTorderTransactionWrapper.ResponseOrderType();
        orderData.OrderType.OrderTypeId  = 'Test Type';
        orderData.OrderTotal             = 100;
        orderData.CustomerId             = 'testId';
        orderData.Extended               = new PHISTorderTransactionWrapper.ResponseExtended();
        orderData.Extended.DeviceId      = 'deviceId';
        orderData.Extended.OriginStore   = 'originstore';

        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Unsuccessful Callout
            PHISTDigitalOrderTransactionSearch.DeleteResponse result = PHISTDigitalOrderTransactionSearch.deleteOrder(JSON.serialize(orderData), (String)cs.Id);
            System.assertEquals( false, result.success );
            System.assertEquals( 'Failure', result.errorMessage );
        Test.stopTest();
    }
    
    @isTest
    static void deleteOrderTest2(){
        Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case LIMIT 1 ];
        System.assert( String.isBlank( cs.Type ) );
        System.assert( String.isBlank( cs.Sub_Type__c ) );

        PHISTorderTransactionWrapper.ResponseOrder orderData = new PHISTorderTransactionWrapper.ResponseOrder();
        orderData.OrderId                = 'ExceptionOrder';
        orderData.MaxFulfillmentStatusId = '1000';
        orderData.MinFulfillmentStatusId = '1500';
        orderData.CreatedTimestamp       = '2020-10-16T17:50:20.904';
        orderData.OrderType              = new PHISTorderTransactionWrapper.ResponseOrderType();
        orderData.OrderType.OrderTypeId  = 'Test Type';
        orderData.OrderTotal             = 100;
        orderData.CustomerId             = 'testId';
        orderData.Extended               = new PHISTorderTransactionWrapper.ResponseExtended();
        orderData.Extended.DeviceId      = 'deviceId';
        orderData.Extended.OriginStore   = 'originstore';

        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
        
        	// Success
            orderData.OrderId = 'TestOrder';
            PHISTDigitalOrderTransactionSearch.DeleteResponse result = PHISTDigitalOrderTransactionSearch.deleteOrder(JSON.serialize(orderData), (String)cs.Id);
            System.assertEquals( true, result.success );
        Test.stopTest();
        Case newCase = [ SELECT Id, Type, Sub_Type__c FROM Case WHERE Id = :cs.Id ];
        System.assertEquals( 'Order Modification', newCase.Type );
        System.assertEquals( 'Cancel Order', newCase.Sub_Type__c );
    }
    @isTest
    static void deleteOrderTestWith404Code(){
        Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case LIMIT 1 ];
        System.assert( String.isBlank( cs.Type ) );
        System.assert( String.isBlank( cs.Sub_Type__c ) );

        PHISTorderTransactionWrapper.ResponseOrder orderData = new PHISTorderTransactionWrapper.ResponseOrder();
        orderData.OrderId                = 'ExceptionOrder';
        orderData.MaxFulfillmentStatusId = '1000';
        orderData.MinFulfillmentStatusId = '1500';
        orderData.CreatedTimestamp       = '2020-10-16T17:50:20.904';
        orderData.OrderType              = new PHISTorderTransactionWrapper.ResponseOrderType();
        orderData.OrderType.OrderTypeId  = 'Test Type';
        orderData.OrderTotal             = 100;
        orderData.CustomerId             = 'testId';
        orderData.Extended               = new PHISTorderTransactionWrapper.ResponseExtended();
        orderData.Extended.DeviceId      = 'deviceId';
        orderData.Extended.OriginStore   = 'originstore';

        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(404) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
        
        	// Success
            orderData.OrderId = 'TestOrder';
            PHISTDigitalOrderTransactionSearch.DeleteResponse result = PHISTDigitalOrderTransactionSearch.deleteOrder(JSON.serialize(orderData), (String)cs.Id);
            System.assertEquals( false, result.success );
        Test.stopTest();
    }
    @isTest
    static void deleteOrderTestWith500Code(){
        Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case LIMIT 1 ];
        System.assert( String.isBlank( cs.Type ) );
        System.assert( String.isBlank( cs.Sub_Type__c ) );

        PHISTorderTransactionWrapper.ResponseOrder orderData = new PHISTorderTransactionWrapper.ResponseOrder();
        orderData.OrderId                = 'ExceptionOrder';
        orderData.MaxFulfillmentStatusId = '1000';
        orderData.MinFulfillmentStatusId = '1500';
        orderData.CreatedTimestamp       = '2020-10-16T17:50:20.904';
        orderData.OrderType              = new PHISTorderTransactionWrapper.ResponseOrderType();
        orderData.OrderType.OrderTypeId  = 'Test Type';
        orderData.OrderTotal             = 100;
        orderData.CustomerId             = 'testId';
        orderData.Extended               = new PHISTorderTransactionWrapper.ResponseExtended();
        orderData.Extended.DeviceId      = 'deviceId';
        orderData.Extended.OriginStore   = 'originstore';

        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(500) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
        
        	// Success
            orderData.OrderId = 'TestOrder';
            PHISTDigitalOrderTransactionSearch.DeleteResponse result = PHISTDigitalOrderTransactionSearch.deleteOrder(JSON.serialize(orderData), (String)cs.Id);
            System.assertEquals( false, result.success );
        Test.stopTest();
    }
    @isTest
    static void deleteOrderTestWith503Code(){
        Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case LIMIT 1 ];
        System.assert( String.isBlank( cs.Type ) );
        System.assert( String.isBlank( cs.Sub_Type__c ) );

        PHISTorderTransactionWrapper.ResponseOrder orderData = new PHISTorderTransactionWrapper.ResponseOrder();
        orderData.OrderId                = 'ExceptionOrder';
        orderData.MaxFulfillmentStatusId = '1000';
        orderData.MinFulfillmentStatusId = '1500';
        orderData.CreatedTimestamp       = '2020-10-16T17:50:20.904';
        orderData.OrderType              = new PHISTorderTransactionWrapper.ResponseOrderType();
        orderData.OrderType.OrderTypeId  = 'Test Type';
        orderData.OrderTotal             = 100;
        orderData.CustomerId             = 'testId';
        orderData.Extended               = new PHISTorderTransactionWrapper.ResponseExtended();
        orderData.Extended.DeviceId      = 'deviceId';
        orderData.Extended.OriginStore   = 'originstore';

        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock(503) );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
        
        	// Success
            orderData.OrderId = 'TestOrder';
            PHISTDigitalOrderTransactionSearch.DeleteResponse result = PHISTDigitalOrderTransactionSearch.deleteOrder(JSON.serialize(orderData), (String)cs.Id);
            System.assertEquals( false, result.success );
        Test.stopTest();
    }
    
    @isTest
    static void deleteOrderTest3(){

        Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case LIMIT 1 ];
        System.assert( String.isBlank( cs.Type ) );
        System.assert( String.isBlank( cs.Sub_Type__c ) );

        PHISTorderTransactionWrapper.ResponseOrder orderData = new PHISTorderTransactionWrapper.ResponseOrder();
        orderData.OrderId                = 'ExceptionOrder';
        orderData.MaxFulfillmentStatusId = '1000';
        orderData.MinFulfillmentStatusId = '1500';
        orderData.CreatedTimestamp       = '2020-10-16T17:50:20.904';
        orderData.OrderType              = new PHISTorderTransactionWrapper.ResponseOrderType();
        orderData.OrderType.OrderTypeId  = 'Test Type';
        orderData.OrderTotal             = 100;
        orderData.CustomerId             = 'testId';
        orderData.Extended               = new PHISTorderTransactionWrapper.ResponseExtended();
        orderData.Extended.DeviceId      = 'deviceId';
        orderData.Extended.OriginStore   = 'originstore';

        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        Test.startTest();
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;

            // Inactive metadata
            PHISTDigitalOrderTransactionSearch.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapInactiveTest;
            PHISTDigitalOrderTransactionSearch.DeleteResponse result = PHISTDigitalOrderTransactionSearch.deleteOrder(JSON.serialize(orderData), (String)cs.Id );
            System.assertEquals( false, result.success );
            System.assertEquals( 'This service is down, please partner with a supervisor to assist and fill out the VOC.', result.errorMessage );
        Test.stopTest();
    }
    
    private static void testSetupData(){
        
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            PHIST_Client_Secret__c = 'clientSecret',
            PHIST_Client_Id__c     = 'clientId',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd',
            OrderDetails__c = '/orderdetails/v8/orders'
        );
        insert testLBrandsAPI;
        
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account',
            SAP_Store__c = '1300',
            CID__c       = 'TestCID'
        );
        insert testAccount;

        RecordType recType = [ SELECT Id FROM RecordType WHERE sObjectType = 'Case' LIMIT 1 ];
        Case testCase = new Case(
            RecordTypeId = recType.Id,
            AccountId = testAccount.Id
        );
        insert testCase;
    }

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'PHIST_Search_By_Email' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "searchByEmail", "Status_Code_400_Message__c" : "Failure" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
				'PHIST_Search_By_OrderId' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "searchByOrderNumber", "Status_Code_400_Message__c" : "Failure" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'PHIST_Search_By_Customer' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "searchByCustomerDigitalOrder", "Status_Code_400_Message__c" : "Failure" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'PHIST_CancelOrder' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "cancelOrder", "Status_Code_400_Message__c" : "Failure" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                ),
                'AOOrderMaxFulfillmentStatusId' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "MaxFulfillmentStatusId", "Status_Code_400_Message__c" : "This order is in process and is unable to be cancelled." }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'PHIST_Search_By_Email' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Status_Code_400_Message__c" : "Failure" }', LBrands_API_Integration_Setting__mdt.class 
                ),
				'PHIST_Search_By_OrderId' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Status_Code_400_Message__c" : "Failure" }', LBrands_API_Integration_Setting__mdt.class 
                ),
                'PHIST_Search_By_Customer' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Status_Code_400_Message__c" : "Failure" }', LBrands_API_Integration_Setting__mdt.class 
                ),
                'PHIST_CancelOrder' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Status_Code_400_Message__c" : "Failure" }', LBrands_API_Integration_Setting__mdt.class 
                ),
                'AOOrderMaxFulfillmentStatusId' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Status_Code_400_Message__c" : "This service is down, please partner with a supervisor to assist and fill out the VOC." }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    @isTest
    static void checkIfSandboxTest(){
    	PHISTDigitalOrderTransactionSearch.checkIfSandbox();    
    }
    
    @isTest
    static void getOrderDescriptionTest(){
    	List<Order_Description_Mapping__c> odList = PHISTDigitalOrderTransactionSearch.getOrderDescriptionMappings();    
    }
}