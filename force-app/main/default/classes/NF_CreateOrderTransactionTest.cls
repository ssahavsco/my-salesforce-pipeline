@isTest
public class NF_CreateOrderTransactionTest {
   @TestSetup
    static void setupData(){
        testSetupData();
    }


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
        
        Case_Resolution__c testCaseResolution = new Case_Resolution__c(
            Amount__c = 100,
            Related_Case__c = testCase.Id,
            Case_Resolution_Type__c = 'Claim',
            Requested_Gift_Card_Type__c = 'Physical Gift Card'
        );
        insert testCaseResolution;
    }
     @isTest 
    static void getOrderTransactionDetailTest(){
        Test.setMock(  HttpCalloutMock.class, new PHISTStoreTransactionService_Mock() );
        List<NF_CreateOrderTransaction.FlowRequestWrapper>wrapperList = new list<NF_CreateOrderTransaction.FlowRequestWrapper>();
        NF_CreateOrderTransaction.FlowRequestWrapper wrapper = new NF_CreateOrderTransaction.FlowRequestWrapper();
        wrapper.orderNumber ='W009320315';
        wrapper.caseResolutionRecord =[SELECT Id, Case_Resolution_Type__c FROM Case_Resolution__c where Case_Resolution_Type__c = 'Claim'];
        wrapperList.add(wrapper);
        Test.startTest();
        NF_CreateOrderTransaction.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
        NF_CreateOrderTransaction.createRecord(wrapperList);
        Test.stopTest();
    }
     @isTest 
    static void insertOrderTransactionTest(){
        //Test case when there is no orderLine
        List<Case_Resolution__c> crList = [SELECT Id,Related_Case__c,Related_Order_Transaction__c from Case_Resolution__c where Case_Resolution_Type__c='Claim'];
        NF_CreateOrderTransaction.InitialResponse initResponse = new NF_CreateOrderTransaction.InitialResponse();
        initResponse.success=true;
        initResponse.successData = new PHISTorderTransactionWrapper.ResponseTransactions();
        PHISTorderTransactionWrapper.ResponseOrder responseOrder = new PHISTorderTransactionWrapper.ResponseOrder();
        List<PHISTorderTransactionWrapper.ResponseOrderLine> orderLine = new List<PHISTorderTransactionWrapper.ResponseOrderLine>();
        responseOrder.OrderLine=orderLine;
        responseOrder.CreatedTimestamp='2021-03-05T21:32:40.969';
        responseOrder.OrderTotal=100;
        responseOrder.CustomerId='a11992fc-e86d-4153-918e-d1afe8c73e75';
        responseOrder.OrderId='E000022956';
        PHISTorderTransactionWrapper.ResponsePayment payment = new PHISTorderTransactionWrapper.ResponsePayment();
        PHISTorderTransactionWrapper.ResponsePaymentMethod paymentMethod = new PHISTorderTransactionWrapper.ResponsePaymentMethod();
        PHISTorderTransactionWrapper.ResponsePaymentType paymentType = new PHISTorderTransactionWrapper.ResponsePaymentType();
        paymentType.PaymentTypeId='eShopWorld';
        paymentMethod.PaymentType=paymentType;
        paymentMethod.Amount=500;
        payment.PaymentMethod=new List<PHISTorderTransactionWrapper.ResponsePaymentMethod>{paymentMethod};
        responseOrder.Payment=new List<PHISTorderTransactionWrapper.ResponsePayment>{payment};
        //Extended
        PHISTorderTransactionWrapper.ResponseExtended extended = new PHISTorderTransactionWrapper.ResponseExtended();
        extended.DeviceId='cbd0e88e-8b3d-4340-ad6a-13453fbe46c6';
        responseOrder.Extended=extended;
        initResponse.successData.transactions = new List<PHISTorderTransactionWrapper.ResponseOrder>();
        initResponse.successData.transactions.add(responseOrder);
        Test.startTest();
        NF_CreateOrderTransaction.insertOrderTransaction(initResponse,crList[0]);
        Test.stopTest();

    }
    @isTest 
    static void insertOrderTransactionTest2(){
        //Test case when there is no orderLine
        List<Case_Resolution__c> crList = [SELECT Id,Related_Case__c,Related_Order_Transaction__c from Case_Resolution__c where Case_Resolution_Type__c='Claim'];
        NF_CreateOrderTransaction.InitialResponse initResponse = new NF_CreateOrderTransaction.InitialResponse();
        initResponse.success=true;
        initResponse.successData = new PHISTorderTransactionWrapper.ResponseTransactions();
        PHISTorderTransactionWrapper.ResponseOrder responseOrder = new PHISTorderTransactionWrapper.ResponseOrder();
        responseOrder.CreatedTimestamp='2021-03-05T21:32:40.969';
        responseOrder.OrderTotal=100;
        responseOrder.CustomerId='a11992fc-e86d-4153-918e-d1afe8c73e75';
        responseOrder.OrderId='E000022956';
        PHISTorderTransactionWrapper.ResponsePayment payment = new PHISTorderTransactionWrapper.ResponsePayment();
        PHISTorderTransactionWrapper.ResponsePaymentMethod paymentMethod = new PHISTorderTransactionWrapper.ResponsePaymentMethod();
        PHISTorderTransactionWrapper.ResponsePaymentType paymentType = new PHISTorderTransactionWrapper.ResponsePaymentType();
        paymentType.PaymentTypeId='eShopWorld';
        paymentMethod.PaymentType=paymentType;
        paymentMethod.Amount=500;
        payment.PaymentMethod=new List<PHISTorderTransactionWrapper.ResponsePaymentMethod>{paymentMethod};
        responseOrder.Payment=new List<PHISTorderTransactionWrapper.ResponsePayment>{payment};
        //Extended
        PHISTorderTransactionWrapper.ResponseExtended extended = new PHISTorderTransactionWrapper.ResponseExtended();
        extended.DeviceId='cbd0e88e-8b3d-4340-ad6a-13453fbe46c6';
        responseOrder.Extended=extended;
        initResponse.successData.transactions = new List<PHISTorderTransactionWrapper.ResponseOrder>();
        initResponse.successData.transactions.add(responseOrder);
        PHISTorderTransactionWrapper.ResponseOrderLine orderLine = new PHISTorderTransactionWrapper.ResponseOrderLine();
        orderLine.ItemDescription='Test';
        orderLine.ItemId='26195984';
        orderLine.Quantity=2;
        orderLine.TotalDiscounts=200;
        orderLine.UnitPrice=500;
        orderLine.OrderLineSubTotal=800;
        orderLine.ItemColorDescription='4UB0 Black Floral Embroidery';
        orderLine.ItemSize='Large';
        orderLine.PromisedShipDate='2021-03-05T21:33:00';
        orderLine.PromisedDeliveryDate='2021-04-20T00:00:00';
        orderLine.ShippingMethodId='0';
        PHISTorderTransactionWrapper.ResponseFulfillmentDetail fulfilmentDate = new PHISTorderTransactionWrapper.ResponseFulfillmentDetail();
        fulfilmentDate.CarrierCode='ESST';
        orderLine.FulfillmentDetail=new List<PHISTorderTransactionWrapper.ResponseFulfillmentDetail>{fulfilmentDate};
        responseOrder.OrderLine=new List<PHISTorderTransactionWrapper.ResponseOrderLine>{orderLine};
        Test.startTest();
        NF_CreateOrderTransaction.insertOrderTransaction(initResponse,crList[0]);
        Test.stopTest();

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
}