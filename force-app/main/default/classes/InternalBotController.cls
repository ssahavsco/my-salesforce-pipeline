public with sharing class InternalBotController {

    public Configuration config {get;set;} 

    public InternalBotController() {
        Map<String, Grace_Bot_Configuration__mdt> mapBotConfig =  Grace_Bot_Configuration__mdt.getAll();

        config = new Configuration();

       try{
            config.orgId = (String) mapBotConfig.get('grace').get('orgID__c');
            config.buttonId = (String) mapBotConfig.get('grace').get('ButtonId__c');
            config.baseLiveAgentContentURL = (String) mapBotConfig.get('grace').get('Base_Live_Agent_Content_URL__c');
            config.baseLiveAgentURL = (String) mapBotConfig.get('grace').get('Base_Live_Agent_URL__c');
            config.baseURL = (String) mapBotConfig.get('grace').get('baseURL__c');
            config.contentURL = (String) mapBotConfig.get('grace').get('contentURL__c');
            config.deploymentId = (String) mapBotConfig.get('grace').get('DeploymentId__c');
            config.eswDeploymentName = (String) mapBotConfig.get('grace').get('ESW_Deployment_Name__c');
            config.eswLiveAgentDevName = (String) mapBotConfig.get('grace').get('esw_Live_Agent_Dev_Name__c');
            config.iSOfflineSupportEnabled = (Boolean)  mapBotConfig.get('grace').get('Is_Offline_Support_Enabled__c');
       }
       catch(System.NullPointerException  e){
            System.debug(e);
       }


    }

    public class Configuration {
        public String orgId {get; set;} 
        public String buttonId {get; set;} 
        public String baseLiveAgentContentURL {get; set;} 
        public String baseLiveAgentURL {get; set;} 
        public String baseURL {get; set;} 
        public String contentURL {get; set;} 
        public String deploymentId {get; set;} 
        public String eswDeploymentName {get; set;} 
        public String eswLiveAgentDevName {get; set;} 
        public Boolean iSOfflineSupportEnabled {get; set;} 
    }
}