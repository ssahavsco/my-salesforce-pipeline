/****************************************************************************************************************
* Program Name         : AccountTriggerHandler
* Description          : Trigger Handler Class for Account Trigger.
* Version              : 1.1
* Modification Log     : 12 May, 2021 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-37893       1.1       Divyanshu Kumar      05/12/2021      Trigger Handler Class for Account Trigger.
*                                                                                                                                                                                       
*****************************************************************************************************************/

public with sharing class AccountTriggerHandler extends NF_TriggerHandler {
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;

    /*Checks to see if the trigger has been disabled either by custom setting or by running code*/
    public override Boolean isDisabled() {
       TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance('AccountTriggerHandler');
       if(triggerSettings != null){
           if(triggerSettings.IsDisabled__c){
               TriggerDisabled = true;
           }
       }
       return TriggerDisabled;
   }

   public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
       //------------------DK_01-----------------------------
       //------- Check if running user is integration user , otherwise make call out
        C_Grid_API_Config__mdt  getCustomerMetadata = C_Grid_API_Config__mdt.getInstance('GETCustomer');
        if(getCustomerMetadata.By_Pass_User_Name__c != UserInfo.getName()){
            Account newAcc = (Account)newItems.values()[0];
            Account oldAcc = (Account)oldItems.get(newAcc.Id);
            List<String> changedFields = AccountTriggerHelper.getChangedFields(newAcc,oldAcc, new List<String>{'FirstName','LastName','MiddleName','PersonEmail','Phone',
                                            'PersonMailingStreet','PersonMailingCity','PersonMailingState','PersonMailingPostalCode','PersonMailingCountry',
                                            'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry'});
            if(!changedFields.isEmpty() && newAcc.CID__c != null && (newAcc.Merge_Requested_CGrid_Update__c == false && oldAcc.Merge_Requested_CGrid_Update__c == false)){
                /**** CCS-13 -- Commented the code on  06/19 - Himanshu ***/
                //Id jobId = System.enqueueJob(new AccountIntegrationService(newAcc,changedFields));   
            }
        }
        //------------------DK_01-----------------------------
   }
}