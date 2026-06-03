/*****************************************************************************************************@@
Class Name     :  VS_RetriggerOpsEmail
Description    :  Retrigger ops email for resending return label or QR code to customers
Modification log : 
-------
VERSION  AUTHOR                 DATE                DETAIL                      			TICKET REFERENCE/ NO.
1.      Himanshu Mishra        6/6/24           Original Version            				CCS-397 
  
*********************************************************************************************************/

public with sharing class VS_RetriggerOpsEmail {
    private static ServiceIntegration__c opsEmailService = ServiceIntegration__c.getInstance('Ops_Email_Service');

    @InvocableMethod(Label='Resend Return Label OR QR Code')
    public static List<FlowOutput> retriggerOpsEmail(List<FlowInput> inputList) {
        String emailType = inputList[0].emailType;
        String orderNumber = inputList[0].orderNumber;

        return makeApiCallout(emailType, orderNumber);
    }
    
    public static List<FlowOutput> makeApiCallout(String emailType, String orderNumber){

        List<FlowOutput> flowOutputList = new List<FlowOutput>();
        FlowOutput flowOutput = new FlowOutput();
        
        String endPoint = opsEmailService.Base_Url__c + opsEmailService.Suffix_URL__c;
        String requestBody = '{ "emailType": "'+emailType+'", "orderNumber": "'+orderNumber+'" }';

        try{
            System.debug('OpsEmailService '+opsEmailService.Base_Url__c + ' Suffix '+opsEmailService.Suffix_URL__c);
            HttpRequest request = new HttpRequest();
            request.setEndpoint( endPoint );
            request.setMethod('POST');
            request.setHeader(RestApiConstants.CONTENT_TYPE,opsEmailService.Content_Type__c);
            request.setBody(requestBody);
            System.debug('Body '+requestBody);
            Logger.info('Endpoint '+endPoint);
            Logger.info('Body '+request.getBody());
            Logger.saveLog();
            HttpResponse response = new Http().send( request );
            System.debug('Response '+response);
            if( response.getStatusCode() == 204 ){
                flowOutput.apiResponseCode = 204;
                flowOutput.isSuccess = true;
            } else if( response.getStatusCode() == 404 ){
                flowOutput.apiResponseCode = 404;
                flowOutput.isSuccess = false;
                Logger.error('404 Error while calling OPS Email trigger service'+response.getBody());
                Logger.saveLog();
            } else {
                flowOutput.apiResponseCode = response.getStatusCode();
                flowOutput.isSuccess = false;
                Logger.error('Error while calling OPS Email trigger service'+response.getBody());
                Logger.saveLog();
            }
            flowOutputList.add(flowOutput);
            return flowOutputList;            
        } catch(Exception e){
            flowOutput.isSuccess = false;
            flowOutputList.add(flowOutput);
            Logger.error('Error while calling OPS Email trigger service '+e);
            Logger.saveLog();
            return flowOutputList;
        }
    }
    
    public class FlowOutput{
        @InvocableVariable(Required=false)
        public Integer apiResponseCode;
        @InvocableVariable(Required=false)
        public Boolean isSuccess;
    }
    public class FlowInput{
        @InvocableVariable(Required=false)
        public String emailType;
        @InvocableVariable(Required=false)
        public String orderNumber;
    }
}