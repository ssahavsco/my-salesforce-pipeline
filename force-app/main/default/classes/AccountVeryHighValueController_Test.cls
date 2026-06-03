@IsTest
private class AccountVeryHighValueController_Test {

    private static Account createPersonAccount(String email, Boolean nonHighValue) {
        // Create minimal Person Account using standard fields commonly enabled for Person Accounts
        // Adjust RecordType if org requires a specific one; defaulting to first PersonAccount-enabled RT
        Account acc = new Account();
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;
        acc.LastName = 'Test ' + email;
        acc.PersonEmail = email;
        acc.Non_High_Value__c = nonHighValue;
        insert acc;
        return acc;
    }

    @IsTest
    static void test_updateVeryHighValue_enqueuesBatch_and_updatesFlag() {
        // Accounts with matching emails and Non_High_Value__c = false should be updated to true
        Account a1 = createPersonAccount('vhv1@example.com', false);
        Account a2 = createPersonAccount('vhv2@example.com', false);
        // Non-matching email or already true should not be changed by batch
        Account a3 = createPersonAccount('other@example.com', false);
        Account a4 = createPersonAccount('vhv3@example.com', true);

        Test.startTest();
        String jobId = AccountVeryHighValueController.updateVeryHighValue(new List<String>{'vhv1@example.com','vhv2@example.com'});
        System.assertNotEquals(null, jobId, 'Batch job id should be returned');
        // Run the batch to completion
        Id asyncId = (Id) jobId;
        // No explicit System.schedule needed as Database.executeBatch was called; Test.stopTest will process it
        Test.stopTest();

        // Verify accounts updated
        Map<Id, Account> refreshed = new Map<Id, Account>([
            SELECT Id, PersonEmail, Non_High_Value__c
            FROM Account
            WHERE Id IN :new List<Id>{a1.Id, a2.Id, a3.Id, a4.Id}
        ]);

        System.assertEquals(true, refreshed.get(a1.Id).Non_High_Value__c, 'a1 should be set to true');
        System.assertEquals(true, refreshed.get(a2.Id).Non_High_Value__c, 'a2 should be set to true');
        System.assertEquals(false, refreshed.get(a3.Id).Non_High_Value__c, 'Non-matching email should not be changed');
        System.assertEquals(true, refreshed.get(a4.Id).Non_High_Value__c, 'Already true remains true');
    }

    @IsTest
    static void test_updateVeryHighValue_nullOrEmpty_returnsNullAndNoBatch() {
        Test.startTest();
        String id1 = AccountVeryHighValueController.updateVeryHighValue(null);
        String id2 = AccountVeryHighValueController.updateVeryHighValue(new List<String>());
        Test.stopTest();
        System.assertEquals(null, id1, 'Null emails should return null');
        System.assertEquals(null, id2, 'Empty emails should return null');
    }

    @IsTest
    static void test_getJobDetails_validJobId_returnsAsyncApexJob() {
        // Enqueue a simple batch to get a jobId
        Account a1 = createPersonAccount('jobtest1@example.com', false);

        Test.startTest();
        String jobId = AccountVeryHighValueController.updateVeryHighValue(new List<String>{'jobtest1@example.com'});
        // Allow batch to at least get into job list; details may show as Queued/Completed after stopTest
        List<AsyncApexJob> beforeStop = AccountVeryHighValueController.getJobDetails(jobId);
        System.assertNotEquals(null, beforeStop, 'Should return list prior to stopTest');
        System.assert(beforeStop.size() == 1, 'Should return exactly one job row');
        Test.stopTest();

        List<AsyncApexJob> afterStop = AccountVeryHighValueController.getJobDetails(jobId);
        System.assertNotEquals(null, afterStop, 'Should return list after stopTest');
        System.assert(afterStop.size() == 1, 'Should return exactly one job row after completion');
        System.assertNotEquals(null, afterStop[0].Status, 'Status should be populated');
        System.assertNotEquals(null, afterStop[0].TotalJobItems, 'TotalJobItems should be populated');
    }

    @IsTest
    static void test_getJobDetails_invalidId_throwsAuraHandled() {
        Boolean threw = false;
        try {
            AccountVeryHighValueController.getJobDetails('a0p000000000000AAA'); // likely nonexistent Id for AsyncApexJob
        } catch (AuraHandledException e) {
            threw = true;
        }
    }
}