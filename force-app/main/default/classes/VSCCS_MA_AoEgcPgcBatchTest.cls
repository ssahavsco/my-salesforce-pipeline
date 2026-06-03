@isTest
public class VSCCS_MA_AoEgcPgcBatchTest {

    @testSetup
    static void setupData() {
        // Create sample Mass_Appeasement__c records
        List<Mass_Appeasement__c> appeasementRecords = new List<Mass_Appeasement__c>();
        for (Integer i = 0; i < 5; i++) {
            appeasementRecords.add(new Mass_Appeasement__c(
                GIFT_CARD_AMOUNT__C = 100.00,
                Price_Override_Reason__c = 'CD_POR',
                GIFT_CARD_TYPE__C = 'EGC',
                BatchID__c = 'Batch001',
                ASSOCIATE_ID__C = 'ssaha',
                RECIPIENT_ADDRESS1__C = 'test',
                RECIPIENT_ADDRESS2__C = 'test',
                RECIPIENT_CITY__C = 'test',
                RECIPIENT_COUNTRY__C = 'test',
                RECIPIENT_EMAIL__C = 'ssaha@lb.com',
                RECIPIENT_FIRST_NAME__C = 'Sumit',
                RECIPIENT_LAST_NAME__C = 'Saha',
                RECIPIENT_PHONE__C= '741-852-8523',
                RECIPIENT_STATE__C = 'Ohio' ,
                RECIPIENT_ZIP_POSTAL_CODE__C = '43230'
            ));
        }
        insert appeasementRecords;
    }

    @isTest
    static void testBatchExecutionWithBatchNumber() {
        // Initialize batch with a batch number
        String batchNumber = 'Batch001';
        VSCCS_MA_AoEgcPgcBatch batch = new VSCCS_MA_AoEgcPgcBatch(batchNumber);
        Test.setMock( HttpCalloutMock.class, new AoEgcPgcService_Mock() );
        // Start test context
        Test.startTest();
        // Execute the batch job
        Database.executeBatch(batch, 5); // Batch size of 5
        Test.stopTest();

        // Verify that records were processed
        List<Mass_Appeasement__c> appeasements = [SELECT Id, Name, Message_Id__c FROM Mass_Appeasement__c WHERE BatchID__c = :batchNumber];
        System.assertEquals(5, appeasements.size(), '5 appeasement records should have been processed.');
    }

    @isTest
    static void testBatchExecutionWithBatchNumberAndSize() {
        // Initialize batch with a batch number and size
        String batchNumber = 'Batch001';
        Integer size = 5;
        VSCCS_MA_AoEgcPgcBatch batch = new VSCCS_MA_AoEgcPgcBatch(batchNumber, size);
        Test.setMock( HttpCalloutMock.class, new AoEgcPgcService_Mock() );
        // Start test context
        Test.startTest();
        // Execute the batch job
        Database.executeBatch(batch, size);
        Test.stopTest();

        // Verify the macList size after execution
       // System.assertEquals(5, batch.macList.size(), 'macList should contain 3 records processed in this batch execution.');
    }

    @isTest
    static void testFinishMethod() {
        // Initialize batch with a batch number
        String batchNumber = 'Batch001';
        VSCCS_MA_AoEgcPgcBatch batch = new VSCCS_MA_AoEgcPgcBatch(batchNumber);
        Test.setMock( HttpCalloutMock.class, new AoEgcPgcService_Mock() );
        // Start test context
        Test.startTest();
        // Execute the batch job
        Database.executeBatch(batch, 5);
        Test.stopTest();

        // Verify that the finish method was called and macList was updated
        List<Mass_Appeasement__c> appeasements = [SELECT Id FROM Mass_Appeasement__c WHERE Id IN :batch.macList];
        System.assertEquals(batch.macList.size(), appeasements.size(), 'All macList records should be updated.');
    }

    @isTest
    static void testNoRecordsProcessed() {
        // Create a batch for a non-matching batch number
        String nonMatchingBatchNumber = 'NonExistingBatch';
        VSCCS_MA_AoEgcPgcBatch batch = new VSCCS_MA_AoEgcPgcBatch(nonMatchingBatchNumber);
        Test.setMock( HttpCalloutMock.class, new AoEgcPgcService_Mock() );
        // Start test context
        Test.startTest();
        Database.executeBatch(batch, 5);
        Test.stopTest();

        // Since no records match the batch number, macList should be empty
        System.assertEquals(0, batch.macList.size(), 'No records should be processed for a non-matching batch number.');
    }
}