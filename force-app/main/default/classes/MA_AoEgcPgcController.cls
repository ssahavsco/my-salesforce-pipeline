/**
 *  Created by : Sumit Saha
 */ 

public with sharing class MA_AoEgcPgcController {

    @AuraEnabled
    public static string submitOrderBatch(String orderBatchNumber){
        // MA_AoEgcPgcQueueable ma = new MA_AoEgcPgcQueueable(orderBatchNumber);
        // Id jobId =  system.enqueueJob(ma);
        // return jobId;

        Id batchJobId = Database.executeBatch(new VSCCS_MA_AoEgcPgcBatch(orderBatchNumber), 5);
        return (String) batchJobId;

    }
}