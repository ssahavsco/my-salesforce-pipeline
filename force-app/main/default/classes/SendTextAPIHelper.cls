public without sharing class SendTextAPIHelper {  
    public static String ERROR_MESSAGE_SEND_TEXT ='We are unable to send a text at this time. Please try again. If the error continues, please contact a supervisor.';
    private static ServiceIntegration__c authTokenService = ServiceIntegration__c.getInstance('SMS_Delivery_Token');
    private static Boolean isTokenUpdated = false;
    public static String runSendTextAPI(String firstName,String lastName, String phoneNumber,String shortenURL){
        String phoneNumberwithCode=NF_Util_SCV.fixPhoneFormat(phoneNumber);
        SendTextRequestWrapper textrequest = new SendTextRequestWrapper(firstName,lastName,phoneNumberwithCode,shortenURL);
        String errorMessage = utilSendTextService(JSON.serialize(textrequest),'SMS_Delivery_API');
       	return errorMessage;
    }
    public static String generateTokenUsingServiceIntegration(String serviceName,Boolean isRegenerateRequired) {
        String accessToken='';
        try {
            if(authTokenService.Authorization_Token__c != null && !isRegenerateRequired && authTokenService.Authorization_Token_Expiry_Time__c !=null && authTokenService.Authorization_Token_Expiry_Time__c>System.now()){
                accessToken=authTokenService.Authorization_Token__c;
            }else{
                HttpRequest request = new HttpRequest();
                String endpoint = authTokenService.Base_Url__c +
                                authTokenService.Suffix_URL__c + 
                                RestApiConstants.AUTH_SECRET_KEY + authTokenService.Client_Secret__c+ 
                                RestApiConstants.AUTH_ID_KEY + authTokenService.Client_Id__c +
                                RestApiConstants.GRANT_KEY + authTokenService.Grant_Type__c;
                request.setEndpoint(endpoint);
                request.setMethod( authTokenService.Method_Name__c );
                request.setTimeout(authTokenService.Time_out__c.intValue());
                HttpResponse response = new Http().send( request );
                if( response.getStatusCode() == 200 ){
                    Map<String, Object> authResponse = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody());
                    accessToken = ( String )authResponse.get( RestApiConstants.ACCESS_TOKEN );
                    Datetime currentDatetime = System.now(); // Get the current Datetime
                    Integer minutesToAdd = authTokenService.Token_Expiry_Minutes__c.intValue();
                    Datetime expiryTime = currentDatetime.addMinutes(minutesToAdd);
                    authTokenService.Authorization_Token__c=String.isNotBlank(accessToken)?accessToken:null;
                    authTokenService.Authorization_Token_Expiry_Time__c = String.isNotBlank(accessToken)?expiryTime:null;
                    isTokenUpdated=true;
                }else{
                    accessToken = '';
                    if(!Test.isRunningTest()){
                        Logger.error('Error while authenticating Experience service'+response.getBody());
                        Logger.saveLog();
                        }
                }
            }
        } catch (Exception ex) {
                Logger.error('Exception while authenticating Experience services'+ex.getMessage());
                Logger.saveLog();
        }
     return accessToken;
    }
    public static String utilSendTextService(String requestBody,String serviceName){
        System.debug(requestBody);
        String errorMessage='';
        try {
            String token = generateTokenUsingServiceIntegration('SMS_Delivery_Token',false);
            if(String.isBlank(token)){
                errorMessage= ERROR_MESSAGE_SEND_TEXT;
            }
            ServiceIntegration__c service_integration = ServiceIntegration__c.getInstance(serviceName);
            HttpResponse response = runServiceAPI(service_integration,token,requestBody);
            if(response.getStatusCode() == 401){
                token = generateTokenUsingServiceIntegration('SMS_Delivery_Token',true);
                response = runServiceAPI(service_integration,token,requestBody);
            }
            if(response.getStatusCode() == 200 ){
                errorMessage= '';
            }else{
                errorMessage = ERROR_MESSAGE_SEND_TEXT;
                Logger.error('Send Pay Link Text Service callout error'+response.getBody());
                Logger.saveLog();
            }
            System.debug(response.getBody());
        } catch (Exception ex) {
            errorMessage= ex.getMessage();
            Logger.error('Exception while calling Send Pay Link service '+String.valueOf(ex.getMessage()));
            Logger.saveLog();
        }
        if(isTokenUpdated){
            update authTokenService;
        }
        return errorMessage;
    }
    
    private static HttpResponse runServiceAPI(ServiceIntegration__c service_integration,String token,String requestBody){
        String endPoint = service_integration.Base_Url__c + service_integration.Suffix_URL__c;    
        HttpRequest request = new HttpRequest();
        request.setEndpoint( endPoint );
        request.setMethod(service_integration.Method_Name__c);
        request.setHeader(RestApiConstants.AUTH_HEADER_KEY,service_integration.Token_Type__c+' '+ token);
        request.setHeader(RestApiConstants.CONTENT_TYPE,service_integration.Content_Type__c);

        request.setBody(requestBody);
        HttpResponse response = new Http().send( request );
        return response;
    }
    public class SendTextRequestWrapper{
        public String firstName;
        public String lastName;
        public String phoneNumber;
        public String shortenedURL;
        public SendTextRequestWrapper(String firstName,String lastName, String phoneNumber,String shortenedURL ){
            this.firstName=firstName;
            this.lastName=lastName;
            this.phoneNumber=phoneNumber;
            this.shortenedURL=shortenedURL;
        }
    }
}