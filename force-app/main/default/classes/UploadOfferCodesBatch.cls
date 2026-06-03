/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Offer Code Utility class  [ CCS-216 ]
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Himanshu Mishra  <hmishra@victoria.com>
* @version        1.0
* @created        01/11/2024
* @modified       01/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global class UploadOfferCodesBatch implements Database.Batchable<sObject> , Database.Stateful{

    private List<Coupon_Offer__c> csvDataList;
	private Boolean deleteExistingRecords;
    
    global UploadOfferCodesBatch(List<Coupon_Offer__c> csvDataList, Boolean deleteExistingRecords){
        this.csvDataList = csvDataList;
        this.deleteExistingRecords = deleteExistingRecords;
    }
    
    global UploadOfferCodesBatch(Boolean deleteExistingRecords){
        this.deleteExistingRecords = deleteExistingRecords;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query;
        if(deleteExistingRecords){
        	query = 'SELECT Id FROM Coupon_Offer__c limit 40000';
        } else{
            query = 'SELECT Id FROM Coupon_Offer__c limit 1';
        }
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Coupon_Offer__c> scope){
        if(deleteExistingRecords){
            delete scope;
            System.debug('Old List '+scope.size());
        }
        if(csvDataList != null){
            System.debug('Insert List1 '+csvDataList.size());
            insert csvDataList;
        }
    }
    global void finish(Database.BatchableContext BC) { }
}