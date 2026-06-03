@IsTest
private class AccountVeryHighValueControllerBatch_Test {

    private static Account createPersonAccount(String email, Boolean nonHighValue) {
        Account acc = new Account();
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;
        acc.LastName = 'BatchTest ' + email;
        acc.PersonEmail = email;
        acc.Non_High_Value__c = nonHighValue;
        insert acc;
        return acc;
    }

    @IsTest
    static void test_batch_marksNonHighValue_true_forMatchingEmails() {
        // Matching accounts start with Non_High_Value__c = false
        Account a1 = createPersonAccount('batch1@example.com', false);
        Account a2 = createPersonAccount('batch2@example.com', false);

        // Non-matching email should remain unchanged
        Account a3 = createPersonAccount('nomatch@example.com', false);

        Test.startTest();
        Database.executeBatch(new AccountVeryHighValueControllerBatch(new List<String>{'batch1@example.com','batch2@example.com'}), 200);
        Test.stopTest();

        Map<Id, Account> refreshed = new Map<Id, Account>([
            SELECT Id, PersonEmail, Non_High_Value__c
            FROM Account
            WHERE Id IN :new List<Id>{a1.Id, a2.Id, a3.Id}
        ]);

        System.assertEquals(true, refreshed.get(a1.Id).Non_High_Value__c, 'a1 should be set to true by batch');
        System.assertEquals(true, refreshed.get(a2.Id).Non_High_Value__c, 'a2 should be set to true by batch');
        System.assertEquals(false, refreshed.get(a3.Id).Non_High_Value__c, 'Non-matching email should not be changed');
    }
}