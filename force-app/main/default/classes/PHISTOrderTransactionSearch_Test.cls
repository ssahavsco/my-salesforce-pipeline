/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for PHISTOrderTransactionSearch.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-21
* @modified       2021-09-16
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          ravikant.kedia@neuraflash.com
* 2021-04-29    renamed method getCaseDataStatefulTest() to getTabAndStatefulDataTest()

* v1.0          ravikant.kedia@neuraflash.com
* 2021-04-29    renamed method getCaseDataStatefulTest() to getTabAndStatefulDataTest()
                updated rest methods

* v1.0          ravikant.kedia@neuraflash.com
* 2021-05-06    created phistDOStatusMatrixMapTest and update method getTabAndStatefulDataTest()

* v1.0          ravikant.kedia@neuraflash.com
* 2021-05-14    updated method createOrderTransactionsTest()

* v1.0          ravikant.kedia@neuraflash.com
* 2021-05-24    updated setup data

* v1.0          ravikant.kedia@neuraflash.com
* 2021-06-24    updates method getTabAndStatefulDataTest()

* v1.0          ravikant.kedia@neuraflash.com
* 2021-09-16    updates method getTabAndStatefulDataTest() and testSetupData()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class PHISTOrderTransactionSearch_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    static void getTabAndStatefulDataTest(){
        Case cs = [ SELECT Id FROM Case LIMIT 1 ];
        MessagingSession lct = [ SELECT Id FROM MessagingSession LIMIT 1 ];
        Test.startTest();
            PHISTOrderTransactionSearch.phistDOStatusMatrixMap = phistDOStatusMatrixMapTest;
            PHISTOrderTransactionSearch.TabAndCase result = PHISTOrderTransactionSearch.getTabAndStatefulData( cs.Id, true, lct.Id );
            System.assertEquals( cs.Id, result.caseData.Id );
            System.assertEquals( '1300', result.caseData.Account.SAP_Store__c );
        Test.stopTest();
    }

    @isTest
    static void getCasesDetailsTest(){
        Test.startTest();
            String result = PHISTOrderTransactionSearch.getCasesDetails( 'TestCID' );
            PHISTOrderTransactionSearch.CaseResponse res = ( PHISTOrderTransactionSearch.CaseResponse )JSON.deserialize( 
                result, PHISTOrderTransactionSearch.CaseResponse.class
            );
            System.assert( !res.existingCaseList.isEmpty() );
            System.assertEquals( 'Test Account', res.transactionCustomer.Name );
        Test.stopTest();
    }

    @isTest
    static void createOrderTransactionsTest(){
        PHISTOrderTransactionSearch.SaveData tempData = new PHISTOrderTransactionSearch.SaveData();
        tempData.selectedOrder = new PHISTorderTransactionWrapper.ResponseOrder();
        tempData.selectedOrderLineList = new List<PHISTorderTransactionWrapper.ResponseOrderLine>();
        tempData.selectedCase = [ SELECT Id, AccountId, ContactId FROM Case LIMIT 1 ];
        System.assertEquals( null, tempData.selectedCase.ContactId );

        tempData.selectedOrder.OrderId = '50133001015502112021';
        tempData.selectedOrder.CreatedTimestamp = '02-11-2021 13:44:41';
        tempData.selectedOrder.OrderTotal = 100;
        tempData.selectedOrder.OrderType = new PHISTorderTransactionWrapper.ResponseOrderType();
        tempData.selectedOrder.OrderType.OrderTypeId = 'VSD-MISC';
        tempData.selectedOrder.Extended = new PHISTorderTransactionWrapper.ResponseExtended();
        tempData.selectedOrder.Extended.DeviceId = 'DeviceId';
        tempData.selectedOrder.Extended.OriginStore = 'Origin Store';
        tempData.selectedOrder.Payment = new List<PHISTorderTransactionWrapper.ResponsePayment>();
        PHISTorderTransactionWrapper.ResponsePayment payment = new PHISTorderTransactionWrapper.ResponsePayment();
        payment.PaymentMethod = new List<PHISTorderTransactionWrapper.ResponsePaymentMethod>();
        PHISTorderTransactionWrapper.ResponsePaymentMethod paymentMethod = new PHISTorderTransactionWrapper.ResponsePaymentMethod();
        paymentMethod.Amount = 510;
        paymentMethod.PaymentType = new PHISTorderTransactionWrapper.ResponsePaymentType();
        paymentMethod.PaymentType.PaymentTypeId = 'Credit Card';
        paymentMethod.CardType = new PHISTorderTransactionWrapper.ResponseCardType();
        paymentMethod.CardType.CardTypeId = 'American Express';
        payment.PaymentMethod.add( paymentMethod );
        tempData.selectedOrder.Payment.add( payment );
        Integer orderTransactionCount = [ SELECT COUNT() FROM Order_Transaction__c ];
        System.assertEquals( 0, orderTransactionCount );

        Account acc = [ SELECT Id, PersonContactId FROM Account LIMIT 1 ];

        Test.startTest();
            // No OrderLineItem Selected
            String result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( tempData ), 'StoreTransaction' );
            System.assertEquals( 'SUCCESS', result );
            /**************** Added BY Himanshu ****************/
            tempData.selectedOrder.OrderLine = new List<PHISTorderTransactionWrapper.ResponseOrderLine>();
            PHISTorderTransactionWrapper.ResponseOrderLine orderLine3 = new PHISTorderTransactionWrapper.ResponseOrderLine();
            orderLine3.IsCancelled = false;
            orderLine3.MaxFulfillmentStatusId = '3600';
            orderLine3.ShipToLocationId = 'test';
            tempData.selectedOrder.OrderLine.add( orderLine3 );
            result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( tempData ), 'DigitalOrder' );
            /**************** Added BY Himanshu ****************/
            // OrderLineItem selected
            tempData.selectedOrder.CreatedTimestamp = '2020-10-16T17:50:20.904';
            PHISTorderTransactionWrapper.ResponseOrderLine orderLine = new PHISTorderTransactionWrapper.ResponseOrderLine();
            orderLine.ItemDescription = 'Test Description';
            orderLine.ItemId = '5';
            orderLine.Quantity = 1;
            orderLine.TotalDiscounts = 100;
            orderLine.UnitPrice = 1000;
            orderLine.ItemColorDescription = 'Red';
            orderLine.ItemSize = 'Medium';
        	orderLine.MaxFulfillmentStatusId = '2';
            orderLine.IsCancelled = false;
        	//orderLine.MaxFulfillmentStatusId = '3600';
        	orderLine.ShipToLocationId = 'test';
            tempData.selectedOrderLineList.add( orderLine );
        	PHISTorderTransactionWrapper.ResponseFulfillmentDetail fullfilment = new PHISTorderTransactionWrapper.ResponseFulfillmentDetail();
        	fullfilment.UpdatedTimeStamp = 'abcT76';
        	fullfilment.FulfillmentDate = 'abcT7612';
            result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( tempData ), 'DigitalOrder' );
            System.assertEquals( 'SUCCESS', result );

            // Duplicate OrderLineItem selected
            PHISTorderTransactionWrapper.ResponseOrderLine orderLine2 = new PHISTorderTransactionWrapper.ResponseOrderLine();
            orderLine2.ItemDescription = 'Test Description Dupe';
            orderLine2.ItemId = '5';
            orderLine2.Quantity = 1;
            orderLine2.TotalDiscounts = 100;
            orderLine2.UnitPrice = 1000;
            orderLine2.ItemColorDescription = 'Red';
            orderLine2.ItemSize = 'Medium';
            tempData.selectedOrderLineList.add( orderLine2 );
            result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( tempData ), 'DigitalOrder' );
            System.assertNotEquals( 'SUCCESS', result );
            // Duplicate Order selected with no orderLineItem
            tempData.selectedOrderLineList = new List<PHISTorderTransactionWrapper.ResponseOrderLine>();
            result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( tempData ), 'DigitalOrder' );
            System.assertNotEquals( 'SUCCESS', result );

            // Order selected but with different customerId
            orderLine = new PHISTorderTransactionWrapper.ResponseOrderLine();
            orderLine.ItemDescription = 'Test Description Dupe';
            orderLine.ItemId = '6';
            orderLine.Quantity = 1;
            orderLine.TotalDiscounts = 100;
            orderLine.UnitPrice = 1000;
            orderLine.ItemColorDescription = 'Red';
            orderLine.ItemSize = 'Medium';
        	orderLine.MaxFulfillmentStatusId = '7000';
            tempData.selectedOrderLineList.add( orderLine );
            tempData.customerId = ( String )acc.Id;
        	tempData.selectedOrderLineList.add(orderLine3);
        	tempData.selectedOrderLineList[0].FulfillmentDetail = new List<PHISTorderTransactionWrapper.ResponseFulfillmentDetail>();
        	PHISTorderTransactionWrapper.ResponseFulfillmentDetail fulfillment = new PHISTorderTransactionWrapper.ResponseFulfillmentDetail();
        	fulfillment.UpdatedTimeStamp = '2025-07-03T';
        	fulfillment.FulfillmentDate = '2025-07-03';
        	fulfillment.CarrierCode = 'test';
        	tempData.selectedOrderLineList[0].FulfillmentDetail.add( fulfillment );
            result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( tempData ), 'DigitalOrder' );
            System.assertEquals( 'SUCCESS', result );
        Test.stopTest();

        Case newCase = [ SELECT Id, AccountId, ContactId FROM Case WHERE Id = :tempData.selectedCase.Id ];
        System.assertEquals( acc.Id, newCase.AccountId );
        System.assertEquals( acc.PersonContactId, newCase.ContactId );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){

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
            AccountId    = testAccount.Id,
            Subject      = 'Test Subject - W008078654',
			Origin       = 'Phone'            
        );
        insert testCase;
        
        Case testCaseST = new Case(
            RecordTypeId = recType.Id,
            AccountId    = testAccount.Id,
            Subject      = 'Test Subject - 50133001015502112021',
			Origin       = 'Phone'            
        );
        insert testCaseST;

        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession lct = [ SELECT CaseId FROM MessagingSession LIMIT 1 ];
        lct.CaseId = testCase.Id;
        update lct;
        
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * test rcords for metadata PHIST_DigitalOrder_Status_Matrix__mdt
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, PHIST_DigitalOrder_Status_Matrix__mdt> phistDOStatusMatrixMapTest{
		get {
			return new Map<String, PHIST_DigitalOrder_Status_Matrix__mdt>{
				'Matrix_1000_1000' => ( PHIST_DigitalOrder_Status_Matrix__mdt ) JSON.deserialize(
                    '{ "Min_Status__c" : "1000", "Max_Status__c" : "1000", "Associate_Dispay__c" : "Display1000" }', PHIST_DigitalOrder_Status_Matrix__mdt.class 
                ),
				'Matrix_1000_1500' => ( PHIST_DigitalOrder_Status_Matrix__mdt ) JSON.deserialize(
                    '{ "Min_Status__c" : "1000", "Max_Status__c" : "1500", "Associate_Dispay__c" : "Display1500" }', PHIST_DigitalOrder_Status_Matrix__mdt.class 
                ),
				'Matrix_1500_2000' => ( PHIST_DigitalOrder_Status_Matrix__mdt ) JSON.deserialize(
                    '{ "Min_Status__c" : "1500", "Max_Status__c" : "2000", "Associate_Dispay__c" : "Display2000" }', PHIST_DigitalOrder_Status_Matrix__mdt.class 
                ),
				'Matrix_1500_3000' => ( PHIST_DigitalOrder_Status_Matrix__mdt ) JSON.deserialize(
                    '{ "Min_Status__c" : "1500", "Max_Status__c" : "3000", "Associate_Dispay__c" : "Display3000" }', PHIST_DigitalOrder_Status_Matrix__mdt.class 
                ),
				'Matrix_3500_3500' => ( PHIST_DigitalOrder_Status_Matrix__mdt ) JSON.deserialize(
                    '{ "Min_Status__c" : "3500", "Max_Status__c" : "3500", "Associate_Dispay__c" : "Display3500" }', PHIST_DigitalOrder_Status_Matrix__mdt.class 
                )
			};
		}
		private set;
	}
        @isTest
    static void testGetUserProfileName() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueUsername = 'testuser_' + System.currentTimeMillis() + '@example.com';
User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = uniqueUsername
        );
        insert u;

        // Run as the test user
        System.runAs(u) {
            ResponseWrapper result = PHISTOrderTransactionSearch.getUserProfileName();
            // No assertions, just executing the method
        }
    }
}