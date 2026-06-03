global class NF_CaseOrderTransactionLinkBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful{
    //public variables
    public ErrorWrapper eWrapper;
    public List<ErrorList> eList;
    //constructor
    public NF_CaseOrderTransactionLinkBatch(){
        eList = new List<ErrorList>();
        eWrapper = new ErrorWrapper();
    }
    //start method

    global Database.QueryLocator start(Database.BatchableContext bc){
        String resolution1='Modify order (Credit Card Required)';
        String resolution2='Placed a New Order';
        String query = 'SELECT Id,AO_Order_Number__c,Related_Case__c,Related_Order_Transaction__c from Case_Resolution__c where Related_Order_Transaction__c=null and AO_Order_Number__c!=null AND (Case_Resolution_Type__c=:resolution1 OR Case_Resolution_Type__c=:resolution2)';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case_Resolution__c> caseResolutionList){
        // process each batch of records
        List<String> orderNumberSet = new List<String>();
        //end point calling starts here
        
        for (Case_Resolution__c cr : caseResolutionList){
            try{
                InitialResponse initResponse = getOrderTransactionDetail(cr.AO_Order_Number__c,cr);
                if (initResponse.success){
                    insertOrderTransaction(initResponse, cr);
                } else{
                    ErrorList er = new ErrorList();
                    er.caseResolutionId=cr.Id;
                    er.errorMessage='API Error. Details not retreived from API';
                    er.errorLine='NA';
                    er.orderNumber=cr.AO_Order_Number__c;
                    eList.add(er);
                }
            }catch(Exception e){
                ErrorList er = new ErrorList();
                er.caseResolutionId=cr.Id;
                er.errorMessage=e.getMessage();
                er.errorLine=String.valueOf(e.getLineNumber());
                er.orderNumber=cr.AO_Order_Number__c;
                eList.add(er);
            }
         }
    }

    
	@TestVisible 
    private  InitialResponse getOrderTransactionDetail(String OrderNumber,Case_Resolution__c cr){
        InitialResponse initResponse = new InitialResponse();
        initResponse.success = false;
        initResponse.successData = new PHISTorderTransactionWrapper.ResponseTransactions();
        try{
            List<PHISTorderTransactionWrapper.ResponseOrder> responseOrderList = new List<PHISTorderTransactionWrapper.ResponseOrder>();
            
            GetRequest getReq = new GetRequest();
            PostRequest postReq = new PostRequest();
            RestResponse response = new RestResponse();
            PHISTStoreTransactionService phstService = new PHISTStoreTransactionService();

            String integrationMDTName = 'PHIST_Search_By_OrderId';
            LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get(integrationMDTName);

            if (lbAPIMDT.Active__c){
                getReq.setRelativeEndpoint(lbAPIMDT.Endpoint__c + OrderNumber);
                response = phstService.doGet(getReq);
                if (response.getStatusCode() == 200){
                    initResponse.success = true;
                    initResponse.successData.transactions = new List<PHISTorderTransactionWrapper.ResponseOrder>();
                    initResponse.successData.transactions.add((PHISTorderTransactionWrapper.ResponseOrder)JSON.deserialize(String.valueOf(response.getData()), PHISTorderTransactionWrapper.ResponseOrder.class));
                }

            }
            
        }catch(Exception e){
            ErrorList er = new ErrorList();
            er.caseResolutionId = cr.Id;
            er.errorLine = String.valueOf(e.getLineNumber());
            er.errorMessage = e.getMessage();
            er.orderNumber=cr.AO_Order_Number__c;
            eList.add(er);
        }
        return initResponse;
        
    }
	
    @TestVisible 
    private void insertOrderTransaction(InitialResponse initResponse, Case_Resolution__c cr){
        try{
            if (initResponse.success){
                PHISTorderTransactionWrapper.ResponseOrder responseOrder = initResponse.successData.transactions[0];
                List<Order_Transaction__c> otListToInsert = new List<Order_Transaction__c>();
                String timestamp          = responseOrder.CreatedTimestamp.replace( 'T', ' ' );
                if (responseOrder.OrderLine.isEmpty() || responseOrder.OrderLine==null){
                    Order_Transaction__c ot   = new Order_Transaction__c();
                    ot.Case__c                = cr.Related_Case__c;
                    ot.Amount__c              = responseOrder.OrderTotal;
                    ot.CID__c                 = responseOrder.CustomerId;
                    if(responseOrder.Extended!=null){
                        ot.Register_Number__c = responseOrder.Extended.DeviceId!=null?responseOrder.Extended.DeviceId:'';
                        ot.Store_Number__c    = responseOrder.Extended.OriginStore!=null?responseOrder.Extended.OriginStore:'';
                    }
                    ot.Transaction_Number__c  = responseOrder.OrderId;
                    ot.Order_Status__c        = responseOrder.status;
                    ot.Payment_Method__c      = createPaymentString(responseOrder.Payment);
                    ot.Transaction_Date__c    = Date.valueOf( timestamp );
                    insert ot;
                    cr.Related_Order_Transaction__c=ot.Id;
                    update cr;
                    otListToInsert.add(ot);
                } else{
                    PHISTorderTransactionWrapper.ResponseOrderLine orderLine = responseOrder.OrderLine[0];
                    Order_Transaction__c ot = new Order_Transaction__c();
                    ot.Case__c                = cr.Related_Case__c;
                    ot.Amount__c              = responseOrder.OrderTotal;
                    ot.CID__c                 = responseOrder.CustomerId;
                    if(responseOrder.Extended!=null){
                        ot.Register_Number__c = responseOrder.Extended.DeviceId!=null?responseOrder.Extended.DeviceId:'';
                        ot.Store_Number__c    = responseOrder.Extended.OriginStore!=null?responseOrder.Extended.OriginStore:'';
                    }
                    ot.Transaction_Number__c  = responseOrder.OrderId;
                    ot.Payment_Method__c      = createPaymentString(responseOrder.Payment);
                    ot.Item_Description__c    = orderLine.ItemDescription;
                    ot.Item_ID__c             = orderLine.ItemId;
                    ot.Quantity__c            = orderLine.Quantity;
                    ot.Total_Discount__c      = orderLine.TotalDiscounts;
                    ot.Unit_Price__c          = orderLine.UnitPrice;
                    ot.Price_Paid__c          = orderLine.OrderLineSubTotal;
                    ot.Color__c               = orderLine.ItemColorDescription;
                    ot.Size__c                = orderLine.ItemSize;
                    ot.Transaction_Date__c    = Date.valueOf( timestamp );
                    ot.Order_Status__c        = responseOrder.status;
                    ot.Ship_Date__c           = orderLine.PromisedShipDate != null ? Date.valueOf( orderLine.PromisedShipDate.replace( 'T', ' ' ) ) : null;
                    ot.Estimated_Delivery_Date__c = orderLine.PromisedDeliveryDate != null ? Date.valueOf( orderLine.PromisedDeliveryDate.replace( 'T', ' ' ) ) : null;
                    ot.Ship_Type__c           = orderLine.ShippingMethodId;
                    if( orderLine.FulfillmentDetail != null && !orderLine.FulfillmentDetail.isEmpty() ){
                        ot.Carrier_Code__c    = orderLine.FulfillmentDetail[0].CarrierCode;
                    }
                    insert ot;
                    cr.Related_Order_Transaction__c=ot.Id;
                    update cr;
                    
                }
            }
        }
        catch(Exception e){
            ErrorList er = new ErrorList();
            er.caseResolutionId = cr.Id;
            er.errorLine = String.valueOf(e.getLineNumber());
            er.errorMessage = e.getMessage();
            er.orderNumber=cr.AO_Order_Number__c;
            eList.add(er);
        }
        
    }

    global void finish(Database.BatchableContext bc){
        //if there are any failed records, email them
        if(!eList.isEmpty()){
            Messaging.SingleEmailMessage Emailmessage = new Messaging.SingleEmailMessage();
            Emailmessage.toaddresses = System.Label.NF_CaseOTLinkEmail.split(';');
            Emailmessage.subject='Batch NF_CaseOrderTransactionLinkBatch Failed';
            String Message = 'Hi There! Below is the List of Failed Records from  NF_CaseOrderTransactionLinkBatch Batch Class<br/>';
            Message+='<table><tr><th>Record Id</th><th>Order Number</th><th>Error Line</th><th>Error Message</th></tr>';
            for(ErrorList er : eList){
                Message+='<tr>';
                Message+='<th>'+er.caseResolutionId+'</th>';
                Message+='<th>'+er.orderNumber+'</th>';
                Message+='<th>'+er.errorLine+'</th>';
                Message+='<th>'+er.errorMessage+'</th>';
                Message+='</tr>';
            }
            
            Emailmessage.setHtmlBody(Message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailmessage});
        }
    }

    public class InitialResponse{
        public Boolean success;
        public PHISTorderTransactionWrapper.ResponseTransactions successData;
        public String errorMessage;

    }

    @TestVisible
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMap{
        get{
            if (lbAPIIntegSettingsMap == null){
                lbAPIIntegSettingsMap = LBrands_API_Integration_Setting__mdt.getAll();
            }
            return lbAPIIntegSettingsMap;
        }

        set;
    }

    private static String createPaymentString(List<PHISTorderTransactionWrapper.ResponsePayment> paymentList){
        String paymentMethodString = '';
        if (paymentList != NULL && !paymentList.isEmpty()){
            for (PHISTorderTransactionWrapper.ResponsePayment payment : paymentList){
                if (payment.PaymentMethod != null && !payment.PaymentMethod.isEmpty()){
                    for (PHISTorderTransactionWrapper.ResponsePaymentMethod paymentMethod : payment.PaymentMethod){
                        if (paymentMethod.PaymentType.PaymentTypeId != null){
                            String tempPayment = paymentMethod.PaymentType.PaymentTypeId + ' - ' + paymentMethod.Amount;
                            paymentMethodString += String.isBlank(paymentMethodString) ? tempPayment : ('; ' + tempPayment);
                        }
                    }
                }
            }
        }

        return paymentMethodString;
    }

    public class ErrorWrapper{
        public List<ErrorList> errorList;
        
    }
    public class ErrorList{
        public String errorMessage;
        public String errorLine;
        public String caseResolutionId;
        public String orderNumber;
    }

}