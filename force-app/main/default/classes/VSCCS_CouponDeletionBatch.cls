public with sharing class VSCCS_CouponDeletionBatch implements Database.Batchable<sObject>{
    
    public String query;
    
    public VSCCS_CouponDeletionBatch(Boolean isDomestic, Boolean isInternational) {
        query = 'Select Id From Coupon_Offer__c where';
        if(isDomestic && isInternational)
            query = 'Select Id From Coupon_Offer__c';
        else if(isInternational)
            query += ' Is_International__c = true';
        else if(isDomestic)
            query += ' Is_International__c = false';
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Database.delete(scope);
    }

    public void finish(Database.BatchableContext BC) {
    }
}