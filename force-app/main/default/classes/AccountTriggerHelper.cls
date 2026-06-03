/****************************************************************************************************************
* Program Name         : AccountTriggerHelper
* Description          : Trigger Helper Class for Account Trigger Handler.
* Version              : 1.1
* Modification Log     : May 18,2021
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-37893       1.1       Divyanshu Kumar      May 18,2021      Trigger Helper Class for Account Trigger Handler.
*                                                                                                                                                                                       
*****************************************************************************************************************/
public with sharing class AccountTriggerHelper{
    /*
        -----------------DK_01 ---------
        RETURNS LIST OF Changed Fields IF ANT OF THE FIELDS IN LIST<STRING> fields CHANGED DURING TRIGGER EXECUTION.
    */
    public static List<String> getChangedFields(Account newAccount, Account oldAccount, List<String> fields){
        List<String> changedFields = new List<String>();
        for(String fieldName : fields){
            if(newAccount.get(fieldName) != oldAccount.get(fieldName)){
                changedFields.add(fieldName);
            }
        }
        return changedFields;
    }
    // -----------------DK_01 -----------
}