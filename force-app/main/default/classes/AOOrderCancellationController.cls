/*
***********************************************************************************************************
* Program Name      : AOOrderCancellationController
* Description       : Controller class to manage Order Cancellation.
* Version           : 1.1
* Modification Log  : 16-08-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-39921    1.1         Ravikant Kedia      16-08-2021      Created class for Cancel Order from Chat Bot.
***********************************************************************************************************
*/
public class AOOrderCancellationController {
    
    public static Map<String, LBrands_API_Integration_Setting__mdt> endPointMetaData = LBrands_API_Integration_Setting__mdt.getAll();
    
    @InvocableMethod(Label ='Neuraflash - Cancel Order' description='Cancel an order using Chat Bot')
    public static List<ChatBotOutput> cancelOrder( List<ChatBotInput> input) {
        // Created Service class object
        AOOrderCancellationService cancelService = new AOOrderCancellationService();
        RestResponse response = new RestResponse();
        List<ChatBotOutput> outputList = new List<ChatBotOutput>();
        ChatBotOutput output = new ChatBotOutput();
        AOOrderCancellationWrapper acWrap = new AOOrderCancellationWrapper();
        
        try {
            if( endPointMetaData.get('AO_Order_Cancellation').Active__c ) {
                // Created Get Request Object
                PostRequest postReq = new PostRequest();
                postReq.setRelativeEndpoint( endPointMetaData.get('AO_Order_Cancellation').Endpoint__c );
                postReq.setBody('{ "OrderId": \"'+ input[0].orderId + '\" , "MaxFulfillmentStatus": { "StatusId": "9000" }, "IsCancelled": true, "MinFulfillmentStatus": { "StatusId": "9000" }, "CancelReason": { "ReasonId": \"' + input[0].reasonId + '\" }, "CancelComments": \"' + input[0].cancelComments + '\" }');
                System.debug('Cancel Order API Request --> ' + postReq.getBody());
                
                // call service class method and store responce in RestResponse class object
                response = cancelService.doPost ( postReq );                

                if( response.getStatusCode() == 200 ) {
                    System.debug('Cancel Order API Response Controller --> ' + response.getStatusCode() + '-' + response.getData());
                    acWrap = (AOOrderCancellationWrapper) System.JSON.deserialize(response.getData().toString(), AOOrderCancellationWrapper.class);
                } else {
                    System.debug(postReq);
                    System.debug(response);
                    System.debug(response.getHeaders());
                    System.debug('Cancel Order API Response Controller --> ' + response.getStatusCode() + '-' + response.getError());
                    acWrap = (AOOrderCancellationWrapper) System.JSON.deserialize(response.getError().getMessage(), AOOrderCancellationWrapper.class);
                }
                System.debug('JSON to class conversion --> ' + acWrap);
                output.result = acWrap.success;
                output.apiStatusCode = response.getStatusCode();
            } else {
                output.result = false;
                output.apiStatusCode = 503;
            }   
        } catch(Exception e) {
            output.result = false;
            System.debug('***********'+e.getLineNumber()+'***********:'+e.getMessage());
        }
        outputList.add(output);
        return outputList;
    }
    
    public class ChatBotOutput {
        @InvocableVariable
        public Boolean result;

        @InvocableVariable
        public Integer apiStatusCode;
    }
    
    public class ChatBotInput {
        @InvocableVariable(required= false)
        public String orderId;
        
        @InvocableVariable(required= false)
        public String reasonId;
        
        @InvocableVariable(required= false)
        public String cancelComments;
    }
}