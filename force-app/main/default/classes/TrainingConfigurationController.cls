/**
 * @description       :

 * @company           :
 * @last modified on  : 25-02-2024
 **/
public with sharing class TrainingConfigurationController{
    @AuraEnabled
    public static ConfigWrapper getTrainingConfigurationRecords(){

        return getConfigWrapper();
    }

    private static List<Training_Configuration__c> getTrainingConfigurationRecords(String profileName){

        return [SELECT Id, Display_Title__c, RecordType.DeveloperName, Question__c, Option_A__c, Option_B__c, Option_C__c, Option_D__c, Correct_Answer__c, Correct_Answer_Explanation__c, Wrong_Answer_Explanation__c,Knowledge_Article_Link__c
                FROM Training_Configuration__c
                WHERE (Start_Date__c = null OR Start_Date__c <= TODAY) AND (End_Date__c = null OR End_Date__c >= TODAY) AND IsActive__c = TRUE AND Selected_Profiles__c INCLUDES ( :profileName)];
    }

    private static ConfigWrapper getConfigWrapper(){
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name
                              from Profile
                              where Id = :profileId].Name;

        List<Training_Configuration__c> lstconfig = getTrainingConfigurationRecords(profileName);
        ConfigWrapper wrapper = new ConfigWrapper();
        for (Training_Configuration__c config : lstconfig){
            if (config.RecordType.DeveloperName == 'Breaking_News'){
                wrapper.productAnnouncement.add(config);
            } else if (config.RecordType.DeveloperName == 'Test_Your_Knowledge'){
                wrapper.quizConfig.add(config);

            } else if (config.RecordType.DeveloperName == 'Tip_of_the_Day'){
                wrapper.trainingTip.add(config);

            }
        }
        return wrapper;
    }

    public class ConfigWrapper{
        @AuraEnabled
        public List<Training_Configuration__c> quizConfig;
        @AuraEnabled
        public List<Training_Configuration__c> trainingTip;
        @AuraEnabled
        public List<Training_Configuration__c> productAnnouncement;

        public ConfigWrapper(){
            this.quizConfig = new List<Training_Configuration__c>();
            this.trainingTip = new List<Training_Configuration__c>();
            this.productAnnouncement = new List<Training_Configuration__c>();
        }

    }

}