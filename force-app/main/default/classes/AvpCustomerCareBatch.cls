/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Batchable class for the AVP Check Refund Request process, flags Case Resolutions as being sent.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Tara Chand  <tara.chand@neuraflash.com>
* @modifiedBy     Tara Chand  <tara.chand@neuraflash.com>
* @maintainedBy   Tara Chand  <tara.chand@neuraflash.com>
* @version        1.0
* @created        2021-05-07
* @modified       2021-05-07
* @systemLayer    Batchable
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Tara Chand <tara.chand@neuraflash.com>
*               DP-37415: Initial implementation of AVP Check Refund batch job
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

// This class follows the SFDC structure for Batchable classes
global with sharing class AvpCustomerCareBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = System.today();
        List<String> caseResolutionTypeList = new List<String>{'Check Refund Request','Check Refund Request (CA)','Check Refund Request (US)'};
        // DP-37415: query picks up all the Case Resolutions of Check Refund Request type, where no Approval Date is set or is lower than today, and have yet to be sent
        String query = 'SELECT Id,Name,Sent_to_AP_Date_Time__c  FROM Case_Resolution__c WHERE Case_Resolution_Type__c IN:caseResolutionTypeList AND Approval_Date_Time__c !=null AND Approval_Date_Time__c  <: dt AND Sent_to_AP_Date_Time__c = null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Case_Resolution__c> scope) {
        for(Case_Resolution__c resolution : scope) {
            // DP-37415: flag the CR as being sent
            resolution.Sent_to_AP_Date_Time__c = System.now();
        }
        update scope;
    }
    global void finish(Database.BatchableContext BC) {
    }
}