/**
 * Created by NeuraFlash LLC on 10/22/19.
 */

public with sharing class NF_AgentAvailabilityCheck {
    public class Input{
        @InvocableVariable(required=true)
        public String sChatButtonDeveloperName;
        @InvocableVariable(required=true)
        public String sChatDeploymentDeveloperName;
    }
    public class Output{
        @InvocableVariable(required=true)
        public boolean bAgentAvailability;
    }

    @InvocableMethod(label='Neuraflash - Check Agent Availability')
    public static List<Output> checkAgentAvailability(List<Input> params){
        Output output = new Output();
        output.bAgentAvailability = false;

        try{
            System.debug(LoggingLevel.DEBUG,'>> NF_AgentAvailabilityCheck.getButtonAvailability: sChatButtonName='+params[0].sChatButtonDeveloperName);
            System.debug(LoggingLevel.DEBUG,'>> NF_AgentAvailabilityCheck.getButtonAvailability: sChatDeploymentName='+params[0].sChatDeploymentDeveloperName);

            output.bAgentAvailability = getButtonAvailability(params[0].sChatButtonDeveloperName,params[0].sChatDeploymentDeveloperName);
            
        }catch(Exception e){
            Logger.error(e.getMessage());
            Logger.saveLog();
            System.debug(LoggingLevel.DEBUG,'Exception: ' + e);
        }
        return new List<Output>{output};
    }
	
    @AuraEnabled
    //public static boolean getButtonAvailability(String botDeploymentId, String botTransferbuttonId){
    public static boolean getButtonAvailability(String botTransferbutton, String botDeployment){
        Boolean isAvailable = false;
        List<LiveChatButton> chatButtonIdList = [SELECT Id
                                                 FROM LiveChatButton
                                                 WHERE DeveloperName = :botTransferbutton
                                                 LIMIT 1];        

        List<LiveChatDeployment> deploymentList = [SELECT Id
                                                   FROM LiveChatDeployment
                                                   WHERE DeveloperName = :botDeployment
                                                   LIMIT 1];

        if(chatButtonIdList.size() > 0 && deploymentList.size() > 0){
            try{
                String botTransferbuttonId = chatButtonIdList[0].Id;
                botTransferbuttonId = botTransferbuttonId.substring(0,15);
                String botDeploymentId = deploymentList[0].Id;
                botDeploymentId = botDeploymentId.substring(0,15);
                String botOrgId = UserInfo.getOrganizationId().substring(0, 15);
                botOrgId = botOrgId.substring(0,15);


                String sPath = 'callout:Live_Chat_Agent_Availability/chat/rest/Visitor/Availability?Availability.ids='+botTransferbuttonId+'&deployment_id='+botDeploymentId+'&org_id='+botOrgId;
                System.debug(LoggingLevel.DEBUG,'>> NF_AgentAvailabilityCheck.getButtonAvailability: sPath='+sPath);

                HttpRequest request = new HttpRequest();
                request.setEndpoint(sPath);
                request.setMethod('GET');
                request.setHeader('X-LIVEAGENT-API-VERSION', '47');

                Http http = new Http();
                HttpResponse response = http.send(request);
                System.debug(LoggingLevel.DEBUG,'NF_AgentAvailabilityCheck.getButtonAvailability: response='+response.getBody());

                // If the request is successful, parse the JSON response.
                if (response.getStatusCode() == 200) {
                    JSONParser parser = JSON.createParser(response.getBody());
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'isAvailable')) {
                            // Get the value.
                            parser.nextToken();
                            isAvailable = parser.getBooleanValue() != null ? parser.getBooleanValue() : false;
                        }
                    }
                }
            }
            catch(Exception e){
                //TODO: add logger
                System.debug(LoggingLevel.DEBUG, 'NF_AgentAvailabilityCheck >> Encountered Exception: ' + e);
                Logger.error(e.getMessage());
                Logger.saveLog();
            }
        }
        return isAvailable;
    }
}