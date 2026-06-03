/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for phistDigitalOrderTransactionSearch
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-05
* @modified       2021-06-29
* @systemLayer    Controller
* @see            ????
* @see            ????
* @Jira Number    DP-37114, DP-37115, DP-37116, DP-37188, DP-37468, DP-39120, DP-39121
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-14      code commenting

* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-20      created method deleteOrder()

* v1.0            ravikant.kedia@neuraflash.com
* 2021-06-29      updated cancel request
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class PHISTDigitalOrderTransactionSearch {
    
    public class SearchData{
        public String email;
        public String firstName;
        public String lastName;
        public String zipCode;
        public String orderNumber;
        public String searchType;
    }

    public class InitialResponse{
        @AuraEnabled public Boolean success;
        @AuraEnabled public PHISTorderTransactionWrapper.ResponseTransactions successData;
        @AuraEnabled public String errorMessage;
    }

    public class DeleteResponse{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String successMessage;
        @AuraEnabled public String errorMessage;
    }

    @TestVisible
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMap{
        get{
            if( lbAPIIntegSettingsMap == null ){
                lbAPIIntegSettingsMap = LBrands_API_Integration_Setting__mdt.getAll();
            }
            return lbAPIIntegSettingsMap;
        }
        set;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * cancelTimeStamp
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Integer     cancel order extended Minutes
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static Integer cancelTimeStamp() {
        LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
        return Integer.valueOf(lbAPI.AO_Cancel_Remorse_Duration_Minutes__c);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * get orders
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srchData    String( search data to make callout )
    * @return   String      structured data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static String getOrderHistory( String srchData ){
        InitialResponse initResponse = new InitialResponse();
        initResponse.success     = true;
        initResponse.successData = new PHISTorderTransactionWrapper.ResponseTransactions();
        
        SearchData data       = ( SearchData )JSON.deserialize( srchData, SearchData.class );
        GetRequest getReq     = new GetRequest();
        PostRequest postReq   = new PostRequest();
        RestResponse response = new RestResponse();
		PHISTStoreTransactionService phstService = new PHISTStoreTransactionService();
        String integrationMDTName = ( data.searchType == 'searchByEmail' 
            ? 'PHIST_Search_By_Email' 
            : data.searchType == 'searchByCustomerName' ? 'PHIST_Search_By_Customer' : 'PHIST_Search_By_OrderId'
        );
        LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get( integrationMDTName );
		
        try{
            if( data.searchType == 'searchByOrderNumber' ){
                // Integration Setting MDT
                    if( lbAPIMDT.Active__c ){
                        getReq.setRelativeEndpoint( lbAPIMDT.Endpoint__c + data.orderNumber );
                        response = phstService.doGet( getReq );
                        // System.debug('searchByOrderNumber :: ' + response.getData() );
                        if ( response.getStatusCode() == 200 ) {
                            initResponse.successData.transactions = new List<PHISTorderTransactionWrapper.ResponseOrder>();
                            initResponse.successData.transactions.add( ( PHISTorderTransactionWrapper.ResponseOrder )JSON.deserialize( 
                                String.valueOf( response.getData() ), 
                                PHISTorderTransactionWrapper.ResponseOrder.class 
                            ) );
                        System.debug('initResponse :: ' + JSON.serialize(initResponse)); 
                       logger.info(JSON.serialize(initResponse));
                            logger.saveLog();
                        } else if( response.getStatusCode() == 404 ) {
                            initResponse.success = false;
                            initResponse.errorMessage = lbAPIMDT.Status_Code_404_Message__c;
							Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
							Logger.saveLog();
                        } else if( response.getStatusCode() == 500 ) {
                            initResponse.success = false;
                            initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
							Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
							Logger.saveLog();
                        } else if( response.getStatusCode() == 503 ) {
                            initResponse.success = false;
                            initResponse.errorMessage = lbAPIMDT.Status_Code_503_Message__c;
							Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
							Logger.saveLog();
                        } else {
                            // Error code
                            initResponse.success = false;
                            initResponse.errorMessage = response.getError().getMessage();
							Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
							Logger.saveLog();
                        }
                    } else {
                        initResponse.success = false;
                        initResponse.errorMessage = lbAPIMDT.Status_Code_400_Message__c;
						Logger.error('Inactive Phist API ::');
						Logger.saveLog();
                    }
                } 
            else {
                String body = '';
                if( data.searchType == 'searchByEmail' ){
                    body = '{"email":"' + data.email + '", "limit":75}';
                } else if( data.searchType == 'searchByCustomerName' ){
                    body = '{"firstName":"' + data.firstName + '", "lastName":"' + data.lastName + '", "postalCode":"' + data.zipCode + '", "webOnlyOrders":true, "resultsSize":75}';
                }
    
                if( lbAPIMDT.Active__c ){
                    postReq.setRelativeEndpoint( lbAPIMDT.Endpoint__c );
                    postReq.setBody( body );
    
                    // Callout
                    response = new CallOutService().doPost( postReq );
    
    
                    if ( response.getStatusCode() == 200 ) {
                        initResponse.successData = ( PHISTorderTransactionWrapper.ResponseTransactions )JSON.deserialize( 
                            String.valueOf( response.getData() ), 
                            PHISTorderTransactionWrapper.ResponseTransactions.class 
                        );
                        //System.debug('successData'+initResponse.successData.transactions[0].OrderLine[0]);
                    } else if( response.getStatusCode() == 404 ) {
                        initResponse.success = false;
                        initResponse.errorMessage = response.getError().getMessage();
						Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
						Logger.saveLog();
                    } else if( response.getStatusCode() == 500 ) {
                        initResponse.success = false;
                        initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
						Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
						Logger.saveLog();
                    } else if( response.getStatusCode() == 503 ) {
                        initResponse.success = false;
                        initResponse.errorMessage = lbAPIMDT.Status_Code_503_Message__c;
						Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
						Logger.saveLog();
                    } else {
                        // Error code
                        initResponse.success = false;
                        initResponse.errorMessage = response.getError().getMessage();
						Logger.error('Error response from Phist :: ' + initResponse.errorMessage);
						Logger.saveLog();
                    }
                } else {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_400_Message__c;
					Logger.error('Inactive Phist API :: '+initResponse.errorMessage);
					Logger.saveLog();
                }
            }
        } catch(Exception e){
            initResponse.success = false;
            initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
            System.debug( 'Line Number :: ' + e.getLineNumber() + ' Phist Error '+e);
			Logger.error('Error in fetching order details from Phist :: ' + e.getMessage());
			Logger.saveLog();
        }
        return JSON.serialize( initResponse ); 
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * cancel orders
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    orderString    String
    * @param    caseId         String
    * @return   DeleteResponse
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static DeleteResponse deleteOrder( String orderString, String caseId ){
        DeleteResponse response = new DeleteResponse();
        response.success = true;

        orderString = orderString.replaceAll( '\\$', '' );
        PHISTorderTransactionWrapper.ResponseOrder order = ( PHISTorderTransactionWrapper.ResponseOrder )JSON.deserialize( 
            orderString, PHISTorderTransactionWrapper.ResponseOrder.class 
        );

        if( lbAPIIntegSettingsMap.get( 'AOOrderMaxFulfillmentStatusId').Active__c ) {
            PHISTStoreTransactionService phstServic = new PHISTStoreTransactionService();
            
            // make request to check user can cancel the order or not
            PostRequest postRequest = new PostRequest();
            postRequest.setRelativeEndpoint( lbAPIIntegSettingsMap.get('AOOrderMaxFulfillmentStatusId').Endpoint__c );
            postRequest.setBody('{"Query": "OrderId=' + order.OrderId + '","Size": 100,"Template": {"OrderId": null,"CreatedTimestamp":null,"DoNotReleaseBefore": null,"MinFulfillmentStatusId": null,"MaxFulfillmentStatusId": null}}');
            RestResponse resp = phstServic.checkMaxFullfillmentStatusId( postRequest );

            if( resp.getStatusCode() == 200 ) {
                if( resp.getData() != null && Integer.valueOf(resp.getData()) < 3000) {
                    LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get( 'PHIST_CancelOrder' );
                    if( lbAPIMDT.Active__c ){
                        PHISTorderTransactionWrapper.DeleteRequest delRequestBody = new PHISTorderTransactionWrapper.DeleteRequest();
                        delRequestBody.OrderId                       = order.OrderId;
                        delRequestBody.MaxFulfillmentStatus          = new PHISTorderTransactionWrapper.ResponseFulfillmentStatus();
                        delRequestBody.MaxFulfillmentStatus.StatusId = '9000';
                        delRequestBody.IsCancelled                   = true;
                        delRequestBody.MinFulfillmentStatus          = new PHISTorderTransactionWrapper.ResponseFulfillmentStatus();
                        delRequestBody.MinFulfillmentStatus.StatusId = '9000';
                        delRequestBody.CancelReason                  = new PHISTorderTransactionWrapper.CancellingReason();
                        delRequestBody.CancelReason.ReasonId         = 'Customer Request';
                        delRequestBody.CancelComments                = 'Cancelled by Associate';
                        String body = JSON.serialize( delRequestBody );

                        PostRequest postReq   = new PostRequest();
                        postReq.setRelativeEndpoint( lbAPIMDT.Endpoint__c );
                        postReq.setBody( body );

                        PHISTStoreTransactionService phstService = new PHISTStoreTransactionService();
                        RestResponse res = phstService.doPost( postReq );
                        if( res.getStatusCode() == 200 ) {
                            response.successMessage = System.Label.PhistOrderCancelSubmit;

                            // Updating Case
                            Case cs = [ SELECT Id, Type, Sub_Type__c FROM Case WHERE Id = :caseId ];
                            if( String.isBlank( cs.Type ) && String.isBlank( cs.Sub_Type__c ) ){
                                cs.Type = 'Order Modification';
                                cs.Sub_Type__c = 'Cancel Order';
                                update cs;
                            }

                            // Creating Order_Transaction__c record
                            PHISTOrderTransactionSearch.SaveData data = new PHISTOrderTransactionSearch.SaveData();
                            data.selectedOrder = order;
                            data.selectedOrderLineList = new List<PHISTorderTransactionWrapper.ResponseOrderLine>();
                            data.selectedCase = cs;
                            data.customerId = null;
                            String result = PHISTOrderTransactionSearch.createOrderTransactions( JSON.serialize( data ), 'DigitalOrder' );
                        } else if( res.getStatusCode() == 404 ) {
                            response.success = false;
                            response.errorMessage = lbAPIMDT.Status_Code_404_Message__c;
							Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
							Logger.saveLog();
                        } else if( res.getStatusCode() == 500 ) {
                            response.success = false;
                            response.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
							Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
							Logger.saveLog();
                        } else if( res.getStatusCode() == 503 ) {
                            response.success = false;
                            response.errorMessage = lbAPIMDT.Status_Code_503_Message__c;
							Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
							Logger.saveLog();
                        } else {
                            // Error code
                            response.success = false;
                            response.errorMessage = lbAPIMDT.Status_Code_400_Message__c;
							Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
							Logger.saveLog();
                        }
                    } else {
                        response.success = false;
                        response.errorMessage = lbAPIMDT.Status_Code_400_Message__c;
						Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
						Logger.saveLog();
                    }
                } else {
                    response.success = false;
                    response.errorMessage = System.Label.AOOrderUnableCancel;
					Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
					Logger.saveLog();
                }
            } else {
                response.success = false;
                response.errorMessage = System.Label.CCCToolsServiceDown;
				Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
				Logger.saveLog();
            }
        } else {
            response.success = false;
            response.errorMessage = System.Label.CCCToolsServiceDown;
			Logger.error('Error in fetching order details from Phist :: ' + response.errorMessage);
			Logger.saveLog();
        }
        
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkIfSandbox(){
        Boolean isSandBox = [SELECT IsSandbox FROM organization LIMIT 1].IsSandbox;
        return isSandBox;
    }
    @AuraEnabled(cacheable=true)
    public static List<Order_Description_Mapping__c> getOrderDescriptionMappings() {
        return [SELECT Id,Name,Order_Description__c FROM Order_Description_Mapping__c];
    }
}