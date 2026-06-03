/**
 *  Created/Modified by  Sharath/Sumit;
 */ 

public with sharing class VSCCS_MA_AoEgcPgcBatch implements Database.Batchable<sObject>, Database.Stateful,  Database.AllowsCallouts{

        private String batchNumber;
        private Integer size;
        public List<Mass_Appeasement__c> macList = new List<Mass_Appeasement__c>();
    
        public VSCCS_MA_AoEgcPgcBatch(String batchNumber) {
            this.batchNumber = batchNumber;
        }
        public VSCCS_MA_AoEgcPgcBatch(String batchNumber, Integer size) {
            this.batchNumber = batchNumber;
            this.size = size;
        }
    
        public Database.QueryLocator start(Database.BatchableContext context) {
            return Database.getQueryLocator([
                SELECT Id, Name, CreatedDate, Message_Id__c, BatchID__c 
                FROM Mass_Appeasement__c 
                WHERE CreatedDate = TODAY 
                  AND BatchID__c = :batchNumber 
                  AND Message_Id__c = NULL
            ]);
        }
    
        public void execute(Database.BatchableContext context, List<Mass_Appeasement__c> orders) {
            for (Mass_Appeasement__c ord : orders) {
                Mass_Appeasement__c ma = new  Mass_Appeasement__c();
                ma = MA_AoEgcPgcService.sendEcgPcgReq(ord.Name);
                macList.add(ma);
             }
        }
    
        public void finish(Database.BatchableContext context) {
            System.debug('Batch job completed for batchNumber: ' + batchNumber);
    	System.debug('macList :: ' +  macList.size());

        // Filter out null values from macList before updating
        List<Mass_Appeasement__c> nonNullMacList = new List<Mass_Appeasement__c>();
        for (Mass_Appeasement__c ma : macList) {
            if (ma != null) {
                nonNullMacList.add(ma);
            }
        }

            // Perform update only if nonNullMacList has valid records
            if (!nonNullMacList.isEmpty()) {
                update nonNullMacList;
            } else {
                System.debug('No valid Mass_Appeasement__c records to update.');
            }
        }
    }