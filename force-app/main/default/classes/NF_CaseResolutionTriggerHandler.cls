/****************************************************************************************************************
* Program Name         : NF_CaseResolutionTriggerHandler
* Description          : Trigger Handler Class for CaseResolution.
* Version              : 1.1
* Modification Log     : 16 April,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755      1.1       Divyanshu Kumar      16 April,2021       Trigger Hanlder Class for CaseResolution. 
*                                                                                   Handles all cutom logic on the trigger events 
*                                                                                   for Case Resolution.                                                                                                                                                                                    
*****************************************************************************************************************/

public with sharing class NF_CaseResolutionTriggerHandler extends NF_TriggerHandler {
     // Allows unit tests (or other code) to disable this trigger for the transaction
     public static Boolean TriggerDisabled = false;

     /*Checks to see if the trigger has been disabled either by custom setting or by running code*/
     public override Boolean isDisabled() {
        TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance('CaseResolutionTriggerHandler');
        if(triggerSettings != null){
            if(triggerSettings.IsDisabled__c){
                TriggerDisabled = true;
            }
        }
        return TriggerDisabled;
    }
    //added by Rishabh to populate Case resolution record type
    public override void beforeInsert(List<sObject> newList){
        Map<Id,List<Case_Resolution__c>> caseVsResList = new Map<Id,List<Case_Resolution__c>>();
        Id recId=Schema.SObjectType.Case_Resolution__c.getRecordTypeInfosByName().get('Sales Audit Request').getRecordTypeId();
        for(Case_Resolution__c cr : (List<Case_Resolution__c>) newList){
            if(cr.Related_Case__c!=null && cr.Case_Resolution_Type__c=='Sales Audit Request'){
                cr.RecordTypeId = recId;
                /*if(caseVsResList.containsKey(cr.Related_Case__c)){
                    List<Case_Resolution__c> tempList = caseVsResList.get(cr.Related_Case__c);
                    tempList.add(cr);
                    caseVsResList.put(cr.Related_Case__c,tempList);
                }
                else{
                    caseVsResList.put(cr.Related_Case__c,new List<Case_Resolution__c>{cr});
                }*/
            }
        }
        /*List<Case> caseList = [SELECT Id FROM Case WHERE Id IN: caseVsResList.keySet() AND RecordType.DeveloperName LIKE 'Digital_Phone'];
        if(!caseList.isEmpty()){
            for(Case c : caseList){
                if(caseVsResList.containsKey(c.Id)){
                    for(Case_Resolution__c cr : caseVsResList.get(c.Id)){
                        cr.RecordTypeId = recId;
                    }
                }
            }
            
        }*/
    }

    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        //-------------------DK_01---------------------------
        List<Case_Resolution__c> lstCRsToProcessForCompletion = new List<Case_Resolution__c>();
        for(Case_Resolution__c cr : (List<Case_Resolution__c>)newItems.values()){
            Case_Resolution__c oldCR = (Case_Resolution__c)oldItems.get(cr.Id);
            if(cr.Completion_Date__c != null && oldCR.Completion_Date__c == null){
                lstCRsToProcessForCompletion.add(cr);
            }
        }
        if(!lstCRsToProcessForCompletion.isEmpty()){
            NF_CaseResolutionTriggerHelper.updateCaseStatus(lstCRsToProcessForCompletion);
        }
        //--------------------DK_01---------------------------

        //------------------Mass Rejection--- Change Case Owner------------------
        List<Case_Resolution__c> lstCRsToProcessForRejection = new List<Case_Resolution__c>();
        for(Case_Resolution__c cr : (List<Case_Resolution__c>)newItems.values()){
            Case_Resolution__c oldCR = (Case_Resolution__c)oldItems.get(cr.Id);
            if(cr.Rejection_Date_Time__c != null && oldCR.Rejection_Date_Time__c == null){
                lstCRsToProcessForRejection.add(cr);
            }
        }
        if(!lstCRsToProcessForRejection.isEmpty()){
            NF_CaseResolutionTriggerHelper.updateCaseStatusandOwner(lstCRsToProcessForRejection);
        }
        //------------------Mass Rejection--- Change Case Owner------------------
    }
}