/** Created by Sumit Saha
 *  The purpose is to merge the duplicate loyalty accounts into one single account.
 *  /loyaltymerge/v1/ccsmerge
 *  Date: 07-July-2023
 */

public with sharing class LoyaltyAccountMerge {

    @AuraEnabled
    public static string mergeLoyaltyAccount(string payload){
        String response;
    
        Input input = (Input) JSON.deserialize(string.valueOf(payload), Input.class);

            if(String.isNotEmpty(input.targetLoyaltyId) && String.isNotEmpty(input.targetEmailId) && String.isNotBlank(String.valueOf(input.customerArchive))){
                response =  CCSMergeRequest(input);
                Logger.debug('CCSMergeRequest Response ==> ' + response);
                Logger.saveLog(); 
            }
            else{
                logger.error('LoyaltyId,Email & customerArchive are required fields. ' + JSON.serialize(input));
                Logger.saveLog();
            }
        return response;
    }

    private static String CCSMergeRequest(Input input){
        String requestBody;
        String responseBody;

        try {
            C_Grid_API_Config__mdt endPointLoyaltyMerge = C_Grid_API_Config__mdt.getInstance('GetLoyaltyMerge');

            requestBody = JSON.serialize(input);
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            PostRequest postReq   = new PostRequest();
            postReq.setRelativeEndpoint(endPointLoyaltyMerge.Endpoint__c); 
            postReq.setBody( requestBody );
            postReq.setHeaders(headers);
            RestResponse responsePostCall = new CallOutService().doPost( postReq );

                if(responsePostCall.getStatusCode() == 200){
                    Output output = (Output)  JSON.deserialize( String.valueOf( responsePostCall.getData()), Output.class);
                    output.inputParameter = JSON.serialize(input);
                    responseBody = JSON.serialize(output);
                }
                else{
                    Output output = (Output)  JSON.deserialize( String.valueOf( responsePostCall.getError().getMessage() ), Output.class);
                    output.inputParameter = JSON.serialize(input);
                    responseBody = JSON.serialize(output);
                }
            return responseBody;

        } catch(Exception e) {
            Logger.error('Exception in Merge call :: ' + e.getMessage());
            Logger.saveLog(); 
            return null;
        }
    }

    public class Input {
        public String targetLoyaltyId;
        public String targetEmailId;
        public Boolean customerArchive;
    }

    public class Output{
        public String success;	
        public Error error;
        public String inputParameter;

            public Output(){
                this.error = new Error();
            }
    }

    public class Error {
            public String code;	
            public String message;	
           
        }
}