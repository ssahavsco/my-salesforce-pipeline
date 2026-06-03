/****************************************************************************************************************
* Program Name         : NF_TriggerDispatcher
* Description          : Dispatcher class is responsible for making sure all the methods on the trigger handler are called on trigger context
* Version              : 1.1
* Modification Log     : 16 April,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId                     Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755(Common Class)       1.1       Divyanshu Kumar      16 April,2021    Dispatcher class is responsible for making sure all the methods
*                                                                                               on the trigger handler are called on trigger context
*                                                                                                                                                                                       
*****************************************************************************************************************/

public with sharing class NF_TriggerDispatcher {
    public static void run(NF_ITriggerHandler handler)
    {
        // Check to see if the trigger has been disabled. If it has, return
        if (handler.isDisabled())
            return;

        // Detect the current trigger context and fire the relevant methods on the trigger handler:

        // Before trigger logic
        if (Trigger.IsBefore )
        {
            if (Trigger.IsInsert)
                handler.beforeInsert(trigger.new);

            if (Trigger.IsUpdate)
                handler.beforeUpdate(trigger.newMap, trigger.oldMap);

            if (Trigger.IsDelete)
                handler.beforeDelete(trigger.oldMap);
        }
        // After trigger logic
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert)
                handler.afterInsert(Trigger.newMap);

            if (Trigger.IsUpdate)
                handler.afterUpdate(trigger.newMap, trigger.oldMap);

            if (trigger.IsDelete)
                handler.afterDelete(trigger.oldMap);

            if (trigger.isUndelete)
                handler.afterUndelete(trigger.oldMap);
        }
    }
}