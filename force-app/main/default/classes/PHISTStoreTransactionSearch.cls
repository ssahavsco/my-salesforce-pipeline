/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for phistStoreTransactionSearch
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-03-25
* @modified       2021-05-14
* @systemLayer    Controller
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-14      code commenting

* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-23      created lbAPIIntegSettingsMap map for getting integration metadata settings

* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-27      updated the code to make the callouts for all the searhces

* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-14      modified to check CID on Account record on searchByEmail
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class PHISTStoreTransactionSearch {
	public class SearchData{
        public String email;
        public String firstName;
        public String lastName;
        public String zipCode;
        public String storeTransactionId;
        public String transactionDate;
        public String storeNumber;
        public String amount;
        public String paymentType;
        public String searchType;
    }

    public class InitialResponse{
        @AuraEnabled public Boolean success;
        @AuraEnabled public PHISTorderTransactionWrapper.ResponseTransactions successData;
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
        
        String integrationMDTName = ( data.searchType == 'searchByEmail' || data.searchType == 'searchByCustomerName' 
            ? 'PHIST_Search_By_Customer' 
            : data.searchType == 'searchByStoreTransactionId' ? 'PHIST_Search_By_OrderId' : 'PHIST_Search_By_StoreOrder'
        );
        LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get( integrationMDTName );
        
        if( data.searchType == 'searchByStoreTransactionId' ){
            // Integration Setting MDT
            if( lbAPIMDT.Active__c ){
                getReq.setRelativeEndpoint( lbAPIMDT.Endpoint__c + data.storeTransactionId );
                response = phstService.doGet( getReq );
                if( response.getStatusCode() == 200 ){
                    initResponse.successData.transactions = new List<PHISTorderTransactionWrapper.ResponseOrder>();
                    initResponse.successData.transactions.add( ( PHISTorderTransactionWrapper.ResponseOrder )JSON.deserialize( 
                        String.valueOf( response.getData() ), 
                        PHISTorderTransactionWrapper.ResponseOrder.class 
                    ) );
                } else if( response.getStatusCode() == 404 ) {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_404_Message__c;
                } else if( response.getStatusCode() == 500 ) {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
                } else if( response.getStatusCode() == 503 ) {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_503_Message__c;
                } else {
                    // Error code
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
                }
            } else {
                initResponse.success = false;
                initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
            }
        } else {
            String body = '';
            if( data.searchType == 'searchByEmail' ){
                // Get customer based on email
                List<Account> accList = [ SELECT Id, CID__c FROM Account WHERE PersonEmail = :data.email ];
                if( !accList.isEmpty() && accList[0].CID__c != NULL ){
                    body = '{ "customerId":"' + accList[0].CID__c + '", "storeOnlyOrders":true, "resultsSize":75 }';
                } else {
                    initResponse.success = false;
                    initResponse.errorMessage = System.Label.PhistTransactionSearchNotFound;
                    return JSON.serialize( initResponse );
                }
            } else if( data.searchType == 'searchByCustomerName' ){
                body = '{"firstName":"' + data.firstName + '", "lastName":"' + data.lastName + '", "postalCode":"' + data.zipCode + '", "storeOnlyOrders":true, "resultsSize":75}';
            } else if( data.searchType == 'searchByAmount' ){
                body = '{"transactionDate":"' + data.transactionDate + '", "storeId":"' + data.storeNumber + '", "orderTotal":' + data.amount + '}';
            } else if( data.searchType == 'searchByPaymentType' ){
                body = '{"transactionDate":"' + data.transactionDate + '", "storeId":"' + data.storeNumber + '", "paymentType":"' + data.paymentType + '"}';
            }

            if( lbAPIMDT.Active__c ){
                postReq.setRelativeEndpoint( lbAPIMDT.Endpoint__c );
                postReq.setBody( body );

                // Callout
                response = new CallOutService().doPost( postReq );
                if( response.getStatusCode() == 200 ){
                    initResponse.successData = ( PHISTorderTransactionWrapper.ResponseTransactions )JSON.deserialize( 
                        String.valueOf( response.getData() ), 
                        PHISTorderTransactionWrapper.ResponseTransactions.class 
                    );
                } else if( response.getStatusCode() == 404 ) {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_404_Message__c;
                } else if( response.getStatusCode() == 500 ) {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
                } else if( response.getStatusCode() == 503 ) {
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_503_Message__c;
                } else {
                    // Error code
                    initResponse.success = false;
                    initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
                }
            } else {
                initResponse.success = false;
                initResponse.errorMessage = lbAPIMDT.Status_Code_500_Message__c;
            }
        }
        
        return JSON.serialize( initResponse );
    }
}