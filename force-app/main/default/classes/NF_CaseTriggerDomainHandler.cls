/****************************************************************************************************************
* Program Name         : NF_CaseTriggerDomainHandler
* Description          : Domain Class for the Case trigger.
* Version              : 1.0
* Modification Log     : 28 May, 2021.
*------------------------------------------------------------------------------------------------------------
*JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------
*DP-42120      1.0       Tarun Kochhar        28 May, 2021       Domain class for the Case Trigger which 
*                                                                extends to NF_TriggerHandler class.
*
*DP-47703      1.1       Peter Waddington     1st October 2021   Now includes code to count sensitive cases related to an account
*****************************************************************************************************************/
public class NF_CaseTriggerDomainHandler extends NF_TriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    
    //Use this flag to stop future call out again and again
    public static Boolean isEmialParseEnable = true;
    public static Boolean isSensitiveCountEnabled = true;
    
    /*Checks to see if the trigger has been disabled either by custom setting or by running code*/
    public override Boolean isDisabled() {
        TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance('CaseTriggerDomainHandler');
        if(triggerSettings != null){
            if(triggerSettings.IsDisabled__c){
                TriggerDisabled = true;
            }
        }
        return TriggerDisabled;
    }
    
    public override void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        NF_CaseTriggerHandler.updateChatCaseSubject(Trigger.new);
    }
    
    public override void beforeInsert(List<sObject> newList) {
        NF_CaseTriggerHandler.updateChatCaseSubject(Trigger.new);
    }
    
    public override void afterInsert(Map<Id, sObject> newMap) {
        if(isEmialParseEnable){
            isEmialParseEnable=false;
            //NF_ParseEmail2Case.parseForStringWithRegEx(Trigger.new);
        }

        if (isSensitiveCountEnabled) {
            if (NF_CaseSensitiveCounts.doesListContainSensitiveCases(Trigger.new)) {
                NF_CaseSensitiveCounts.recountSensitiveCases(Trigger.new);
            }
        }
    }

    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        if (isSensitiveCountEnabled) {
            if (NF_CaseSensitiveCounts.doesListContainSensitiveCases(Trigger.new) || NF_CaseSensitiveCounts.doesListContainSensitiveCases(Trigger.old)) {
                NF_CaseSensitiveCounts.recountSensitiveCases(newMap, oldMap);
            }
        }
        NF_CaseTriggerHandler.updateCaseForMissingResolution(Trigger.new,oldMap);

    }

    public override void afterDelete(Map<Id, sObject> oldMap) {
        if (isSensitiveCountEnabled) {
            if (NF_CaseSensitiveCounts.doesListContainSensitiveCases(Trigger.old)) {
                NF_CaseSensitiveCounts.recountSensitiveCases(Trigger.old);
            }
        }
    }
}