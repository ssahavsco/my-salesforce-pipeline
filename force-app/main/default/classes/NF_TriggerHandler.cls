/****************************************************************************************************************
* Program Name         : NF_TriggerHandler
* Description          : TriggerHandler Class that implements Trigger Interface. Every Trigger Handler will extend this class
*                        and override the methods based on thir requirements.
* Version              : 1.1
* Modification Log     : 16 April,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId                     Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755(Common Class)       1.1       Divyanshu Kumar      16 April,2021    TriggerHandler Class that implements Trigger Interface.
*                                                                                               Every Trigger Handler will extend this class
*                                                                                               and override the methods based on thir requirements.
*                                                                                                                                                                                       
*****************************************************************************************************************/

public abstract class NF_TriggerHandler implements NF_ITriggerHandler {
    public virtual void beforeInsert(List<sObject> newList) {
    }
    public virtual void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    public virtual void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
    }
    public virtual void beforeDelete(Map<Id, sObject> oldMap) {
    }
    public virtual void afterInsert(Map<Id, sObject> newMap) {
    }
    public virtual void afterDelete(Map<Id, sObject> oldMap) {
    }
    public virtual void afterUndelete(Map<Id, sObject> newMap) {
    }
    public virtual Boolean isDisabled(){
        return false;
    }
}