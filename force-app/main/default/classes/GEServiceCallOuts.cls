/** International Project to Integrate with GE Service
 *  Created By:  ssaha@victoria.com | Date: 19-APR-24
 *  Modified By:  
 */

public with sharing class GEServiceCallOuts {
    
    public static GlobalEServiceSettings__c ge;
    public static GlobalEServiceSettings__c [] config;
    public static Integer timeout ;
    public static String accesstoken;
    public static String ORDER_NUMBER;

    public static void settings(String name){
        ge = GlobalEServiceSettings__c.getValues(name);
        timeout = Integer.valueOf( ge.get('TimeOut__c')) == null ? 5000: Integer.valueOf( ge.get('TimeOut__c'));
    }

    public static void generateAuthToken(){
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();   
        settings('Authorization');
        String endpoint = ge.get('Host__c').toString() ; 
        endpoint+=  ge.get('Endpoint__c') ;    
        endpoint+='grant_type=' + ge.get('Grant_Type__c')    ;  
        endpoint+='&client_secret='+ ge.get('Client_Secret__c');  
        endpoint+='&client_id='+ ge.get('Client_Id__c');  
        request.setEndpoint(endpoint);
        request.setMethod(ge.get('Method__c').toString());
        request.setTimeout(timeout);

        HttpResponse response = http.send(request);
            if(response.getStatusCode()==200){
                Map<String,Object> r = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                config = [SELECT Id, AccessToken__c from GlobalEServiceSettings__c];
                    for (GlobalEServiceSettings__c element : config){
                        element.AccessToken__c = (String)r.get('access_token') ;
                        accesstoken = 'Bearer ' + (String) r.get('access_token');
                    }
            }
    }

    public static HttpResponse globaleHTTPService(String payload, String refundType ){
        String apiResponse;
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();
        settings(refundType);

        String endpoint = ge.get('Host__c').toString() ; 
        endpoint+=  ge.get('Endpoint__c') ; 
        String token = 'Bearer ' + ge.get('AccessToken__c');
        request.setEndpoint(endpoint);
        request.setMethod(ge.get('Method__c').toString());
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token );
        request.setTimeout(timeout);
        request.setBody(payload);

        Logger.info(request.toString()).addTag(ORDER_NUMBER);
        Logger.info( 'HTTP Request :: ' + request.getBody()).addTag(ORDER_NUMBER);
        Logger.saveLog();    

        HttpResponse response = http.send(request);

        Logger.info(request.toString()).addTag(ORDER_NUMBER);
        Logger.info( 'Response from VS-Middleware :: ' + response.getBody() ).addTag(ORDER_NUMBER);
        Logger.saveLog();  
        

            if (response.getStatusCode() == 401) {
                Logger.info('Existing token has been expired and pulling the new token..').addTag(ORDER_NUMBER);
                Logger.saveLog();
                generateAuthToken();
                request.setHeader('Authorization',  accesstoken );
                response = http.send(request);
                update config;
            } 
        return response;
    }

    @AuraEnabled
    public static String refund(String input){
        try {
          
            HttpResponse apiResponse;
            Input obj = new Input();
            obj = (Input) JSON.deserialize(input, Input.class);
            ORDER_NUMBER = obj.request.orderId;
            Logger.info('Refund Request from LWC:: ' + JSON.serializePretty(obj)).addTag(ORDER_NUMBER);

            String requestPayload;
            requestPayload = JSON.serialize(obj.request , true);
            Logger.info( 'Refund Request (Invoking Http Service) :: ' + requestPayload).addTag(ORDER_NUMBER);

            requestPayload =  mapCustomKey(requestPayload, 'currencyCode', 'currency');

            if (obj.actionType == 'Appeasement') {
                apiResponse = globaleHTTPService(requestPayload , 'ItemLevel' );
            } else if (obj.actionType == 'Shipping') {
                apiResponse = globaleHTTPService(requestPayload , 'Shipping' );
            } else if (obj.actionType == 'Claim') {
                apiResponse = globaleHTTPService(requestPayload , 'Claim' );
            }

            GERefundWrapperResponse res = new GERefundWrapperResponse();
            res = (GERefundWrapperResponse) JSON.deserialize(apiResponse.getBody(), GERefundWrapperResponse.class);
            res.customMessage = errorMessage(apiResponse.getStatusCode());
            res.httpStatusCode =  apiResponse.getStatusCode().toString();
            Logger.info( 'HTTP Refund Response ::  ' +  JSON.serializePretty(res)).addTag(ORDER_NUMBER);
            Logger.saveLog();
            return JSON.serialize(res);
            
        } catch(Exception e) {
            Logger.error( 'GEServiceCallOuts :: Exception Line Number : ' + e.getLineNumber() + '::' + e.getMessage()).addTag(ORDER_NUMBER);
            Logger.saveLog();
            throw new AuraHandledException( e.getMessage());
        }
    }

    @AuraEnabled
    public static String cancel(String input){
        try {
            
            HttpResponse apiResponse;
            CancelRequest cancel = new CancelRequest();
            cancel =  (CancelRequest) JSON.deserialize(input, CancelRequest.class);

            ORDER_NUMBER =cancel.cancelRequest.OrderId;
            Logger.info( 'Cancellation Request from LWC :: ' +  JSON.serializePretty(cancel)).addTag(ORDER_NUMBER);

            String requestPayload;
            
            if (cancel.actionType == 'OrderCancel') {
                cancel.cancelRequest.Process = 'OrderCancel';
                requestPayload = JSON.serialize(cancel.cancelRequest , true);
                Logger.info( 'Cancellation Request (Invoking Http Service) :: ' + requestPayload).addTag(ORDER_NUMBER);
                apiResponse = globaleHTTPService(requestPayload , 'Cancel' );
            } else if (cancel.actionType == 'CancelOrderLine') {
                requestPayload = JSON.serialize(cancel.cancelRequest , true);
                Logger.info( 'Cancellation Request (Invoking Http Service) :: ' + requestPayload).addTag(ORDER_NUMBER);
                apiResponse = globaleHTTPService(requestPayload , 'Cancel' );
            }

           

            GERefundWrapperResponse res = new GERefundWrapperResponse();
            res = (GERefundWrapperResponse) JSON.deserialize(apiResponse.getBody(), GERefundWrapperResponse.class);
            res.httpStatusCode =  apiResponse.getStatusCode().toString();
            Logger.info( 'Http Response Payload :: ' +  JSON.serializePretty(res)).addTag(ORDER_NUMBER);
            Logger.saveLog();
            return JSON.serialize(res);

        } catch(Exception e) {
            Logger.error( 'GEServiceCallOuts :: Exception Line Number : ' + e.getLineNumber() + '::' + e.getMessage()).addTag(ORDER_NUMBER);
            Logger.saveLog();
            throw new AuraHandledException( e.getMessage());
        }
    }

    public static String errorMessage(Integer statusCode){
        String errorMessage ;
            if (statusCode == 400) {
                errorMessage= null;
            } else if (statusCode == 401){
                Logger.info('Token has been Expired').addTag(ORDER_NUMBER);
                Logger.saveLog();
            } else if (statusCode == 500) {
                errorMessage= 'International service is currently not responding. Please inform a supervisor and submit a VOC';       
                Logger.info(errorMessage).addTag(ORDER_NUMBER);
                Logger.saveLog();
            }
        return errorMessage;
    }

    public static String mapCustomKey(String jsonInput, String oldMapKey, String newMapKey){
        Map<String, Object> deserializeInput = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        if (deserializeInput.containsKey(oldMapKey)) {
            Object value = deserializeInput.remove(oldMapKey);
            deserializeInput.put(newMapKey, value);
        }   
        String changedPayload = JSON.serialize(deserializeInput);
        return changedPayload;
    }
    @AuraEnabled
    public static String getShoppingCurrency(String shoppingCurrencyCode) {
        String shoppingCurrency = null;
        List<INTL_Curreny_Setting__mdt> currencies = [
            SELECT Shopping_Currency__c, Shopping_Currency_Code__c
            FROM INTL_Curreny_Setting__mdt
            WHERE Shopping_Currency_Code__c = :shoppingCurrencyCode
        ];
        if (currencies.size() > 0) {
            shoppingCurrency = currencies[0].Shopping_Currency__c;
        }
        return shoppingCurrency;
    }
     @AuraEnabled(cacheable=true)
    public static List<Country_Taxation_Policy__mdt> getCountrySetting() {
        List<Country_Taxation_Policy__mdt> countries = [
        SELECT Country_Code__c, Taxes_Duties_Info__c
        FROM Country_Taxation_Policy__mdt];
        if (countries.size() > 0) {
        return countries;
        }
        return new List<Country_Taxation_Policy__mdt>();
    }
    public class Input{
        public String actionType ;
        public GERefundWrapperRequest request;

            public Input(){
                this.request = new GERefundWrapperRequest();
            }
    }


    public class CancelRequest{
        public String actionType ;
        public INTLOrderCancellation cancelRequest;

        public CancelRequest(){
            this.cancelRequest = new INTLOrderCancellation();
        }
    }

    @AuraEnabled
    public static String refundHistory(String input){

        try {
            HttpResponse apiResponse;
            Refund_Input obj = new Refund_Input();
            obj = obj.jsonParse(input);

            ORDER_NUMBER = obj.request.orderId ;
            Logger.info('Refund History Request from LWC:: ' + JSON.serializePretty(obj)).addTag(ORDER_NUMBER);

            String requestPayload;
            requestPayload = JSON.serialize(obj.request , true);
            System.debug(requestPayload);
            Logger.info( 'Refund History Request (Invoking Http Service) :: ' + requestPayload).addTag(ORDER_NUMBER);

            if (obj.actionType == 'RefundHistory') {
                apiResponse = globaleHTTPService(requestPayload , 'RefundHistory' );
            }

            GERefundHistoryResponseWrapper res = new GERefundHistoryResponseWrapper();
            res = (GERefundHistoryResponseWrapper) JSON.deserialize(apiResponse.getBody(), GERefundHistoryResponseWrapper.class);
            res.customMessage = errorMessage(apiResponse.getStatusCode());
            res.httpStatusCode =  apiResponse.getStatusCode().toString();
            Logger.info( 'HTTP Refund History Response ::  ' +  JSON.serializePretty(res)).addTag(ORDER_NUMBER);
            Logger.saveLog();
            return JSON.serialize(res);
        } catch(Exception e) {
            Logger.error( 'GEServiceCallOuts::RefundHistory :: Exception Line Number : ' + e.getLineNumber() + '::' + e.getMessage()).addTag(ORDER_NUMBER);
            Logger.saveLog();
            throw new AuraHandledException( e.getMessage());
        }

    }

    public class Refund_Input {
        public String actionType ;
        public GERefundHistoryRequestWrapper request;
            public Refund_Input(){
                this.request = new GERefundHistoryRequestWrapper();
            }
        public Refund_Input jsonParse(String json) {
            return (Refund_Input) System.JSON.deserialize(json, Refund_Input.class);
        }    
    }
    @AuraEnabled(cacheable=true)
    public static List<Picklist_Dependency__mdt> getClaimPicklistDependency(){

        return [SELECT Id,Claim_Refund_Reason__c,Refund_Condition__c from Picklist_Dependency__mdt Where Category__c='Claim Refund' AND Is_Active__c=true];
    }
}