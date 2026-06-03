/*****************************************************************************************************@@
Class Name     :  NF_CaseFieldSetHelper
Purpose        :  helper class used to get the case field set for the VOC coding component placed on Case layout.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Balwant                9/25/2020           Original Version  			DP-34740, DP-40258          

@Testsuite:  {NF_CaseFieldSetHelperTest}                                       
*********************************************************************************************************/
public with sharing class NF_CaseFieldSetHelper {
    
    @AuraEnabled
    public static String getCaseId(String lctId){
        String caseId = '';
        try{
           for(LiveChatTranscript eachRecord : [SELECT Id, CaseId FROM LiveChatTranscript WHERE Id =:lctId]){
            caseId = String.valueOf(eachRecord.CaseId);
           }
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,'exception occurred'+' '+e.getMessage()+ ' at '+e.getLineNumber());
        }
        return caseId;
    }

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();  
    }

    @AuraEnabled
    public static String getCaseFieldSetMap(){
        Map<String,List<String>> fieldSetMap = new Map<String,List<String>>();
        String fieldSetMapString = '';
        try{
            Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Case.fieldSets.getMap();
            Set<String> fieldSetNames = FsMap.keySet();

            if(fieldSetNames != null && !fieldSetNames.isEmpty()){
                for(String eachName : fieldSetNames){
                    List<String> fieldApiNames = new List<String>();
                    List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(eachName,'Case');
                    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
                    {
                        fieldApiNames.add(fieldSetMemberObj.getFieldPath());
                    } 
                    fieldSetMap.put(eachName, fieldApiNames);
                }
            }
            fieldSetMapString = JSON.serialize(fieldSetMap);
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,'exception occurred in getCaseFieldSetMap'+' '+e.getMessage()+ ' at '+e.getLineNumber());
        }
        return fieldSetMapString;
    }

    @AuraEnabled
    public static Map<String, String> getFieldSortCriteria(){
        Map<String,String> fieldCriteriaMap = new Map<String,String>();
       try{
        for(Case_Field_Update_Criteria__mdt eachRecord : [SELECT Criteria_Condition__c, Field_Set_API_to_Use__c FROM Case_Field_Update_Criteria__mdt limit 100]){
            fieldCriteriaMap.put(eachRecord.Field_Set_API_to_Use__c, eachRecord.Criteria_Condition__c);
        }
       }catch(Exception e){
        System.debug(LoggingLevel.DEBUG,'exception occurred in getFieldSortCriteria'+' '+e.getMessage()+ ' at '+e.getLineNumber());
       } 
       return fieldCriteriaMap;
    }
}