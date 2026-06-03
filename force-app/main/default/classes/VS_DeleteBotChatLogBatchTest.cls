@isTest
private class VS_DeleteBotChatLogBatchTest {

    @isTest
    static void testBatchExecution() {
        // Create a Bot Session record as a parent for Bot Chat Log records
        ebotdata__Bot_Session__c botSession = new ebotdata__Bot_Session__c(/* populate required fields here */);
        insert botSession;

        // Create test records with the required field populated
        List<ebotdata__Bot_Chat_Log__c> testRecords = new List<ebotdata__Bot_Chat_Log__c>();
        for(Integer i = 0; i < 100; i++) {
            testRecords.add(new ebotdata__Bot_Chat_Log__c(
                ebotdata__Bot_Session__c = botSession.Id,
                CreatedDate = DateTime.newInstance(2020, 1, 1).addDays(i)
            ));
        }
        insert testRecords;

        // Define start and end dates for the batch job
        DateTime startDate = DateTime.newInstance(2020, 1, 1); // January 1, 2020
        DateTime endDate = DateTime.newInstance(2020, 1, 11);  // January 11, 2020

        Test.startTest();

        // Execute the batch job
        VS_DeleteBotChatLogBatch batchJob = new VS_DeleteBotChatLogBatch(startDate, endDate);
        Database.executeBatch(batchJob);

        Test.stopTest();

        // Verify that the records within the specified date range are deleted
        Integer remainingRecordsCount = [SELECT COUNT() FROM ebotdata__Bot_Chat_Log__c WHERE CreatedDate >= :startDate AND CreatedDate < :endDate];
        System.assertEquals(0, remainingRecordsCount, 'Expected records within the date range to be deleted');
    }
}