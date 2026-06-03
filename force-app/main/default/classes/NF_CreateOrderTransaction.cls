public with sharing class NF_CreateOrderTransaction {

    @InvocableMethod(label='Create Order Transaction Record' 
    description ='Makes a callout to external system to create and insert an order transaction record'
    callout=true)
    public static void createRecord(List<FlowRequestWrapper> flowInputs){
        try{
            InitialResponse response =getOrderTransactionDetail(flowInputs[0].orderNumber);
            if(response.success){
                insertOrderTransaction(response, flowInputs[0].caseResolutionRecord);
            } else{
                Logger.error('Error response from Phist :: ' + response.errorMessage);
				Logger.saveLog();
            }
        }
        catch(Exception e){
            system.debug(e.getMessage());
            Logger.error('Error response from Phist :: ' + e.getMessage());
			Logger.saveLog();
        }
            
    }

    public static InitialResponse getOrderTransactionDetail(String OrderNumber){
        List<PHISTorderTransactionWrapper.ResponseOrder> responseOrderList = new List<PHISTorderTransactionWrapper.ResponseOrder>();

        InitialResponse initResponse = new InitialResponse();
        initResponse.success = false;
        initResponse.successData = new PHISTorderTransactionWrapper.ResponseTransactions();

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
            } else{
                Logger.error('Error response from Phist :: '+response.getData());
				Logger.saveLog();
            }
            initResponse.statusCode =response.getStatusCode();

        }
        return initResponse;
    }

    public static void insertOrderTransaction(InitialResponse initResponse, Case_Resolution__c cr){
        if (initResponse.success){
            PHISTorderTransactionWrapper.ResponseOrder responseOrder = initResponse.successData.transactions[0];
            List<Order_Transaction__c> otListToInsert = new List<Order_Transaction__c>();
            String timestamp          = responseOrder.CreatedTimestamp.replace( 'T', ' ' );
            if (responseOrder.OrderLine.isEmpty() || responseOrder.OrderLine==null){
                Order_Transaction__c ot = new Order_Transaction__c();
                if(cr!=null){
                    ot.Case__c = cr.Related_Case__c;
                }
                
                ot.Amount__c             = responseOrder.OrderTotal;
                ot.CID__c = responseOrder.CustomerId;
                if(responseOrder.Extended!=null){
                    ot.Register_Number__c = responseOrder.Extended.DeviceId!=null?responseOrder.Extended.DeviceId:'';
                    ot.Store_Number__c = responseOrder.Extended.OriginStore!=null?responseOrder.Extended.OriginStore:'';
                 }
                
                ot.Transaction_Number__c = responseOrder.OrderId;
                ot.Order_Status__c       = responseOrder.status;
                ot.Payment_Method__c = createPaymentString(responseOrder.Payment);
                ot.Transaction_Date__c   = Date.valueOf( timestamp );
                try{
                    insert ot;
                     if(cr!=null){
                        cr.Related_Order_Transaction__c=ot.Id;
                        update cr;
                     }
                } catch(Exception e){
                    Logger.error('Exception while creating/updating order transaction record in SF :: ' + e.getMessage());
					Logger.saveLog();
                }
                
                 
                otListToInsert.add(ot);
            } else{
                for (PHISTorderTransactionWrapper.ResponseOrderLine orderLine : responseOrder.OrderLine){
                    Order_Transaction__c ot = new Order_Transaction__c();
                    ot.Case__c = cr.Related_Case__c;
                    //ot.Amount__c             = eshopOrder ? svData.selectedOrder.orderExtension3[0].Extended.ShopperTotal : svData.selectedOrder.OrderTotal;
                    ot.CID__c = responseOrder.CustomerId;
                    ot.Register_Number__c = responseOrder.Extended.DeviceId;
                    ot.Store_Number__c = responseOrder.Extended.OriginStore;
                    ot.Transaction_Number__c = responseOrder.OrderId;
                    ot.Payment_Method__c = createPaymentString(responseOrder.Payment);
                    ot.Item_Description__c = orderLine.ItemDescription;
                    ot.Item_ID__c = orderLine.ItemId;
                    ot.Quantity__c = orderLine.Quantity;
                    ot.Total_Discount__c = orderLine.TotalDiscounts;
                    ot.Unit_Price__c         = orderLine.UnitPrice;
                    ot.Price_Paid__c = orderLine.OrderLineSubTotal;
                    ot.Color__c              = orderLine.ItemColorDescription;
                    ot.Size__c               = orderLine.ItemSize;
                    ot.Transaction_Date__c   = Date.valueOf( timestamp );
                     

                   // if( digitalOrder ){
                     ot.Order_Status__c = responseOrder.status;
                     ot.Ship_Date__c = orderLine.PromisedShipDate != null ? Date.valueOf( orderLine.PromisedShipDate.replace( 'T', ' ' ) ) : null;
                     ot.Estimated_Delivery_Date__c = orderLine.PromisedDeliveryDate != null ? Date.valueOf( orderLine.PromisedDeliveryDate.replace( 'T', ' ' ) ) : null;
                     ot.Ship_Type__c = orderLine.ShippingMethodId;
                     if( orderLine.FulfillmentDetail != null && !orderLine.FulfillmentDetail.isEmpty() ){
                     ot.Carrier_Code__c = orderLine.FulfillmentDetail[0].CarrierCode;
                     }
                     //}

                    /** DP-50494 ****
                     * @description - checking if this is Store order and Paid with Credit card
                     * @author Sumit Saha
                     */
                    /*if (!digitalOrder && svData.selectedOrder.Payment.size() > 0) {
                     for(Integer i=0; i < svData.selectedOrder.Payment[0].PaymentMethod.size() ; i++){
                     If(svData.selectedOrder.Payment[0].PaymentMethod[i].CardTypeId == 'Credit' ){
                     System.debug( 'Account Number:: ' + svData.selectedOrder.Payment[0].PaymentMethod[i].AccountNumber);
                     ot.Account_Number__c = svData.selectedOrder.Payment[0].PaymentMethod[i].AccountNumber;
                     break;
                     }
                     }
                     }*/
                    try{
                         insert ot;
                         if(cr!=null){
                            cr.Related_Order_Transaction__c=ot.Id;
                            update cr;
                         }
                    } catch(Exception e){
                        Logger.error('Exception while creating/updating order transaction record in SF :: ' + e.getMessage());
                        Logger.saveLog();
                    }
                     break;
                    otListToInsert.add(ot);
                }
            }
            if (!otListToInsert.isEmpty()){
                //insert otListToInsert;
            }
        }
    }

    public class InitialResponse{
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public PHISTorderTransactionWrapper.ResponseTransactions successData;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Integer statusCode;

    }
    public class FlowRequestWrapper{
        @InvocableVariable(label = 'Order Number')
        public String orderNumber;

        @InvocableVariable(label = 'Case Resolution record')
        public Case_Resolution__c caseResolutionRecord;
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
}