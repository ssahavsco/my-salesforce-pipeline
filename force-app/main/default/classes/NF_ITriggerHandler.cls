/****************************************************************************************************************
* Program Name         : NF_ITriggerHandler
* Description          : Interface class for the Trigger
* Version              : 1.1
* Modification Log     : 16 April,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId                     Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755(Common Class)       1.1       Divyanshu Kumar      16 April,2021    Interface class for the Trigger
*                                                                                                                                                                                       
*****************************************************************************************************************/
public interface NF_ITriggerHandler {
    void beforeInsert(List<SObject> newItems);

    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

    void beforeDelete(Map<Id, SObject> oldItems);

    void afterInsert(Map<Id, SObject> newItems);

    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

    void afterDelete(Map<Id, SObject> oldItems);

    void afterUndelete(Map<Id, SObject> oldItems);

    Boolean isDisabled();
}