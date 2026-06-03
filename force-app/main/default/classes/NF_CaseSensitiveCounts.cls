/****************************************************************************************************************
* Program Name         : NF_CaseSensitiveCounts
* Description          : If any sensitive case is updated, update Sensitive Case counts for related accounts (before and after case update)
* Version              : 1.0
* Modification Log     : 1st October 2021
*------------------------------------------------------------------------------------------------------------
*JiraId       Version    Developer               Date              Description 
*------------------------------------------------------------------------------------------------------------
*DP-47703      1.0       Peter Waddington        1st October 2021  Can be invoked from a list of cases (extracts account ids) or a list of account ids
*                                                                
*****************************************************************************************************************/
public with sharing class NF_CaseSensitiveCounts {
    // list of all record ids which are sensitive
    public static List<Id> sensitiveRecordTypes() {
        List<Id> sensitiveRecordTypeIds = new List<Id>{};
        sensitiveRecordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Sensitive_Case').getRecordTypeId());
        return sensitiveRecordTypeIds;
    }
    // do any of the cases in the list contain a sensitive one?
    // used in the trigger to know if we should run the large function or not
    public static Boolean doesListContainSensitiveCases(List<Case> allCases) {
        List<Id> sensitiveRecordTypeIds = NF_CaseSensitiveCounts.sensitiveRecordTypes();
        for (Case thisCase:allCases) {
            if (sensitiveRecordTypeIds.contains(thisCase.RecordTypeId)) {
                return true;
            }
        }
        return false;
    }
    // recount sensitive cases from a list of cases
    // this function will filter down the list of cases to only the sensitive ones
    // it will then extract the set of accounts related to those cases, 
    // and run the function to gather sensitive cases related to those accounts to establish sensitive case counts
    public static void recountSensitiveCases(List<Case> caseList) {
        List<Case> sensitiveCases = new List<Case>{};
        // get the list of record types for sensitive cases
        List<Id> sensitiveRecordTypeIds = NF_CaseSensitiveCounts.sensitiveRecordTypes();
        // filter the cases down to the sensitive ones
        for (Case thisCase:caseList) {
            if (sensitiveRecordTypeIds.contains(thisCase.RecordTypeId)) {
                sensitiveCases.add(thisCase);
            }
        }
        // gather all account ids from the sensitive cases
        // use a set to prevent dupes
        Set<Id> sensitiveCaseAccountIds = new Set<Id>{};
        for (Case thisCase:sensitiveCases) {
            if (thisCase.AccountId != null) {
                sensitiveCaseAccountIds.add(thisCase.AccountId);
            }
        }
        // now we have the set of relevant account ids, gather cases and update accounts (shared between two funcs)
        gatherCasesAndUpdateAccounts(sensitiveCaseAccountIds);
    }
    // recount sensitive cases from two lists of cases
    // this function exists to be run from the Trigger
    public static void recountSensitiveCases(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        List<Case> allRelevantCaseList = new List<Case>{};
        Set<Id> allCaseIds = newMap.keySet();
        // we're only going to care about a case in certain scenarions
        // filters run in order of most inclusive of data (need to pass new and old) to least inclusive (only new or old)
        for (Id caseId:allCaseIds) {
            Case newCase = (Case)newMap.get(caseId);
            Case oldCase = (Case)oldMap.get(caseId);
            // The account on the case changed
            // now need to update counts on both accounts
            if (newCase.AccountId != oldCase.AccountId) {
                allRelevantCaseList.add(newCase);
                allRelevantCaseList.add(oldCase);
            }
            // The recordtype on the case changed (was, or has become sensitive)
            // Let the child function worry about filtering out the non-sensitive one
            else if (newCase.RecordTypeId != oldCase.RecordTypeId) {
                allRelevantCaseList.add(newCase);
                allRelevantCaseList.add(oldCase);
            }
            // The status on the case changed (may now be closed or reopened)
            else if (newCase.Status != oldCase.Status) {
                allRelevantCaseList.add(newCase);
            }
        }
        // there is a chance that no update of relevance occured on the cases
        // if so, we don't need to continue
        // if however cases of relevance updated, proceed with child function
        if (allRelevantCaseList.size() > 0) {
            recountSensitiveCases(allRelevantCaseList);
        }
    }
    // this function receives a set of account ids that have or had sensitive cases related to them
    // it will then gather all not-closed sensitive cases for those accounts and use that data to update the sensitive case count
    public static void gatherCasesAndUpdateAccounts(Set<Id> sensitiveCaseAccountIds) {
        // get the list of record types for sensitive cases
        List<Id> sensitiveRecordTypeIds = NF_CaseSensitiveCounts.sensitiveRecordTypes();
        // get account information for all the accounts that were part of the updated sensitive account list
        List<Account> accountList = [
            SELECT 
                Id, 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account 
            WHERE Id IN :sensitiveCaseAccountIds
        ];
        // get all open sensitive cases related to the accounts
        List<Case> allOpenAccountSensitiveCases = [
            SELECT 
                Id,
                AccountId
            FROM Case 
            WHERE 
                RecordTypeId IN :sensitiveRecordTypeIds 
                AND AccountId IN :sensitiveCaseAccountIds 
                AND Status != 'Closed'
        ];
        // build a map of account id -> sensitive case list
        // this will prevent the need to nest the for loops later
        Map <Id, List<Case>> accountCases = new Map<Id, List<Case>>();
        for (Case thisCase:allOpenAccountSensitiveCases) {
            if (accountCases.containsKey(thisCase.AccountId)) {
                List<Case> thisAccountCases = accountCases.get(thisCase.AccountId);
                thisAccountCases.add(thisCase);
                accountCases.put(thisCase.AccountId, thisAccountCases);
            } else {
                List<Case> thisAccountCases = new List<Case>{thisCase};
                accountCases.put(thisCase.AccountId, thisAccountCases);
            }
        }
        // use our map to establish account sensitive case counts
        for (Account acc:accountList) {
            // does an entry exist? If yes count = list size, otherwise count = 0
            if (accountCases.containsKey(acc.Id)) {
                acc.In_Progress_Sensitive_Case_Count__c = accountCases.get(acc.Id).size();
            } else {
                acc.In_Progress_Sensitive_Case_Count__c = 0;
            }
        }
        // finally, update the accounts
        update accountList;
    }
}