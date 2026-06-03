global class VS_DeleteBotChatLogBatch implements Database.Batchable<sObject> {

    // Start and end date parameters
    private DateTime startDate;
    private DateTime endDate;

    // Constructor to accept date parameters
    global VS_DeleteBotChatLogBatch(DateTime startDate, DateTime endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for the records you want to delete based on the provided date range
        return Database.getQueryLocator([
            SELECT Id 
            FROM ebotdata__Bot_Chat_Log__c 
            WHERE CreatedDate >= :startDate 
            AND CreatedDate < :endDate
        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // Delete the records in the batch
        List<ebotdata__Bot_Chat_Log__c> recordsToDelete = (List<ebotdata__Bot_Chat_Log__c>) scope;
        delete recordsToDelete;
    }

    global void finish(Database.BatchableContext BC) {
        // Perform any post-processing if needed
    }
}