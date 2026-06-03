/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for AoEgcPgcService.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-22
* @modified       2021-04-28
* @systemLayer    Test class
* @see            ????
* @see            ????
* @Jira Number    DP-37135, DP-37137
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
*
* v1.0          Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* 2021-04-28    updated method sendEcgPcgReqFailureTest()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class AoEgcPgcService_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    static void sendEcgPcgReqSuccessTest(){
        Gift_Card_Request__c gcr = [ SELECT Id, Message_Id__c, Price_Override_Reason__c FROM Gift_Card_Request__c LIMIT 1 ];
        System.assertEquals( NULL, gcr.Message_Id__c );

        Test.setMock( HttpCalloutMock.class, new AoEgcPgcService_Mock() );
        Test.startTest();
            AoEgcPgcService.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            AoEgcPgcService.aoEPRequestValueMap = aoEPRequestValueMapTest;
            List<String> result = AoEgcPgcQueueable.sendEcgPcgReq( new List<Id>{ gcr.Id } );
            System.assertEquals( 'sent', result[0] );
        Test.stopTest();
        AsyncApexJob[] jobs = [Select Id FROM AsyncApexJob 
                             WHERE ApexClass.Name = 'AoEgcPgcQueueable'];
    	System.assert(!jobs.isEmpty(),'AOEgcPgcQueueable job should be created');
    }

    @isTest
    static void sendEcgPcgReqFailureTest(){
        Gift_Card_Request__c gcr = [ SELECT Id, Message_Id__c, Price_Override_Reason__c FROM Gift_Card_Request__c LIMIT 1 ];
        System.assertEquals( NULL, gcr.Message_Id__c );
        gcr.Price_Override_Reason__c = 'T2_POR';
        update gcr;

        Test.setMock( HttpCalloutMock.class, new AoEgcPgcService_Mock() );
        Test.startTest();
            AoEgcPgcService.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            AoEgcPgcService.aoEPRequestValueMap = aoEPRequestValueMapTest;
            List<String> result = AoEgcPgcQueueable.sendEcgPcgReq( new List<Id>{ gcr.Id } );
            System.assertEquals( 'sent', result[0] );
        Test.stopTest();
        AsyncApexJob[] jobs = [Select Id FROM AsyncApexJob 
                             WHERE ApexClass.Name = 'AoEgcPgcQueueable'];
    	System.assert(!jobs.isEmpty(),'AOEgcPgcQueueable job should be created');

        Gift_Card_Request__c newGCR = [ SELECT Id, Message_Id__c FROM Gift_Card_Request__c WHERE Id = :gcr.Id ];
        System.assertEquals( NULL, newGCR.Message_Id__c );
    }

    @isTest
    static void sendEcgPcgReqTestCoverage(){
        Test.startTest();
            AoEgcPgcService clone = new AoEgcPgcService();
            clone.authenticate();

            RestResponse response = clone.doGet( new GetRequest() );

            response  = clone.doPut( new GetRequest() );
            response  = clone.doDelete( new GetRequest() );
        Test.stopTest();
    }

    private static void testSetupData(){

        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account'
        );
        insert testAccount;

        RecordType recType = [ SELECT Id FROM RecordType WHERE sObjectType = 'Case' LIMIT 1 ];
        Case testCase = new Case(
            RecordTypeId = recType.Id,
            AccountId = testAccount.Id
        );
        insert testCase;

        Case_Resolution__c testCaseResolution = new Case_Resolution__c(
            Amount__c = 100,
            Related_Case__c = testCase.Id,
            Case_Resolution_Type__c = 'Claim',
            Requested_Gift_Card_Type__c = 'Physical Gift Card'
        );
        insert testCaseResolution;

        Gift_Card_Request__c testGiftCard = new Gift_Card_Request__c(
            Case_Resolution__c = testCaseResolution.Id,
            Price_Override_Reason__c = 'RT_POR',
            Recipient_Address1__c = 'Test Street',
            Recipient_City__c = 'Test City',
            Recipient_Country__c = 'Test Country',
            Recipient_Email__c = 'test@test.com',
            Recipient_First_Name__c = 'Test',
            Recipient_Last_Name__c = 'Name',
            Recipient_Phone__c = '1234567890',
            Recipient_State__c = 'Test State',
            Recipient_Zip_Postal_Code__c = '123456'
        );
        insert testGiftCard;
    }


    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest{
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'AOEcgPcg_Dev' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "testEndpoint", "Status_Code_200_Message__c" : "Success", "Status_Code_400_Message__c" : "Failure" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, AoEgPgcRequestValue__mdt> aoEPRequestValueMapTest{
		get {
			return new Map<String, AoEgPgcRequestValue__mdt>{
				'CurrencyCode' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "USD" }', AoEgPgcRequestValue__mdt.class ),
				'DocTypeId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "CustomerOrder" }', AoEgPgcRequestValue__mdt.class ),
				'AngelCard' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "false" }', AoEgPgcRequestValue__mdt.class ),
				'FreeReturn' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "N" }', AoEgPgcRequestValue__mdt.class ),
				'AssociateOrder' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "No" }', AoEgPgcRequestValue__mdt.class ),
				'IsAngelCardUsed' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "false" }', AoEgPgcRequestValue__mdt.class ),
				'IsConfirmed' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'IsAlreadyPriced' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'IsAlreadyCharged' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'IsAlreadyTaxed' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'OrderExtension2' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderChargeDetail' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderHold' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderPromotionRequest' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderTaxDetail' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderTotal' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "0" }', AoEgPgcRequestValue__mdt.class ),
				'OrderTypeId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "VSD-MISC" }', AoEgPgcRequestValue__mdt.class ),
				'OrderLineId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "1" }', AoEgPgcRequestValue__mdt.class ),
				'DeliveryMethodId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "ShipToAddress" }', AoEgPgcRequestValue__mdt.class ),
				'IsGiftCard' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'IsPriceOverridden' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'GiftCardValue' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "290" }', AoEgPgcRequestValue__mdt.class ),
				'IsHazmat' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "false" }', AoEgPgcRequestValue__mdt.class ),
				'ItemId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "itemId" }', AoEgPgcRequestValue__mdt.class ),
				'OrderLineChargeDetail' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderLineNote' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'OrderLineTaxDetail' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'Quantity' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "1" }', AoEgPgcRequestValue__mdt.class ),
				'IsAddressVerified' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "true" }', AoEgPgcRequestValue__mdt.class ),
				'UOM' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "Unit" }', AoEgPgcRequestValue__mdt.class ),
				'UnitPrice' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "0" }', AoEgPgcRequestValue__mdt.class ),
				'FulfillmentGroupId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "M000369523Email" }', AoEgPgcRequestValue__mdt.class ),
				'IsClearance' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "N" }', AoEgPgcRequestValue__mdt.class ),
				'PromisedSupplyType' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "OnHand" }', AoEgPgcRequestValue__mdt.class ),
				'ShopperOrderLineId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "" }', AoEgPgcRequestValue__mdt.class ),
				'CategoryCode' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "1001" }', AoEgPgcRequestValue__mdt.class ),
				'CategoryDescription' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "VSD Non Merch" }', AoEgPgcRequestValue__mdt.class ),
				'SubBrandDescription' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "VSD BRANDED OTHER" }', AoEgPgcRequestValue__mdt.class ),
				'AddressVerified' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "false" }', AoEgPgcRequestValue__mdt.class ),
				'ShippingMethodId' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "S" }', AoEgPgcRequestValue__mdt.class ),
				'OrderLineExtension2' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "null" }', AoEgPgcRequestValue__mdt.class ),
				'PaymentStatus' => ( AoEgPgcRequestValue__mdt ) JSON.deserialize( '{ "Value__c" : "null" }', AoEgPgcRequestValue__mdt.class )
			};
		}
		private set;
	}
}