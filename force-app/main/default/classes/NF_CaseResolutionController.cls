/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for Case Resolutions and supporting custom components.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Waddington  <peter.waddington@neuraflash.com>
* @modifiedBy     Peter Waddington  <peter.waddington@neuraflash.com>
* @maintainedBy   Peter Waddington  <peter.waddington@neuraflash.com>
* @version        1.0
* @created        2021-04-28
* @modified       2021-04-28
* @systemLayer    Controller
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Peter Waddington <peter.waddington@neuraflash.com>
*               DP-37125 and others:
*               Added ability to download a set of Order Transactions related to a Case. This is
*               created to facilitate relating Order Transactions and related data to a Case
*               Resolution without resorting to opening the Order Transaction record and
*               copy-pasting data into the Case Resolution.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class NF_CaseResolutionController {
    // DP-37125
    // This function is available to Aura / LWC components
    // The getCaseOrderTransactions function receives a caseId value from the component calling the function.
    // This function is currently called from the nf_CaseResolutionOrderTransationPicklist LWC component,
    // and sends back a List of all the Order_Transaction__c objects for the Case.
    @AuraEnabled
    public static List<Order_Transaction__c> getCaseOrderTransactions(string caseId) {
        // No Case ID? Return a blank list
        if (caseId == null) {
            return new List<Order_Transaction__c>();
        }
        // ensure a Case for that ID exists, otherwise send a blank list
        Case c;
        try {
            c = [SELECT Id FROM Case WHERE Id = :caseId];
        } catch(QueryException e) {}
        if (c == null) {
            return new List<Order_Transaction__c>();
        }
        // Return the potential list of all Order Transactions for the Case ID,
        // along with supporting fields for the UI
        return [
            SELECT 
                Id,
                Name,
                Amount__c,
                Store_Number__c, 
                Transaction_Date__c, 
                Register_Number__c, 
                Transaction_Number__c, 
                Payment_Method__c,
                Account_Number__c,
                BOPIS_Store_Number_Text__c,
                Pick_up_Date__c 
            FROM Order_Transaction__c 
            WHERE
                Case__c = :caseId
        ];
    }
}