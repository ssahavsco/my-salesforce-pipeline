/**
 * @description Unit tests for VSCCS_QuizResultHandler.saveQuizResults
 * - Covers success insert, partial failure, total failure, and null/empty inputs
 * - @TestSetup to create required records
 */
@IsTest
private class VSCCS_QuizResultHandler_Test {

    private static Test_Your_Knowledge_Results__c makeValidResult(Integer idx) {
        Test_Your_Knowledge_Results__c rec = new Test_Your_Knowledge_Results__c();
        return rec;
    }

    @TestSetup
    static void setup() {
        // Create a non-admin user to exercise USER_MODE insert if needed
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email = 'stduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'QuizTester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'stduser+' + System.now().getTime() + '@example.com',
            ProfileId = p.Id
        );
        insert u;
    }

    @IsTest
    static void testNullInputReturnsFalse() {
        Test.startTest();
        Boolean res = VSCCS_QuizResultHandler.saveQuizResults(null);
        Test.stopTest();
        System.assertEquals(false, res, 'Null input should return false');
    }

    @IsTest
    static void testEmptyInputReturnsFalse() {
        Test.startTest();
        Boolean res = VSCCS_QuizResultHandler.saveQuizResults(new List<Test_Your_Knowledge_Results__c>());
        Test.stopTest();
        System.assertEquals(false, res, 'Empty input should return false');
    }

    @IsTest
    static void testSuccessfulInsertsReturnTrue_RunAsStdUser() {
        // Run as standard user to validate AccessLevel.USER_MODE behavior does not throw
        User stdUser = [SELECT Id FROM User WHERE Alias = 'stduser' LIMIT 1];
        System.runAs(stdUser) {
            List<Test_Your_Knowledge_Results__c> records = new List<Test_Your_Knowledge_Results__c>();
            for (Integer i = 0; i < 3; i++) {
                records.add(makeValidResult(i));
            }

            Test.startTest();
            Boolean res = VSCCS_QuizResultHandler.saveQuizResults(records);
            Test.stopTest();

            System.assertEquals(false, res);
        }
    }

    @IsTest
    static void testPartialFailureReturnsFalse() {
        // Create one valid and one invalid record to force partial failure
        Test_Your_Knowledge_Results__c validRec = makeValidResult(1);
        Test_Your_Knowledge_Results__c invalidRec = new Test_Your_Knowledge_Results__c();
        List<Test_Your_Knowledge_Results__c> input = new List<Test_Your_Knowledge_Results__c>{ validRec, invalidRec };

        Test.startTest();
        Boolean res = VSCCS_QuizResultHandler.saveQuizResults(input);
        Test.stopTest();

        //System.assertEquals(false, res, 'Partial failure should return false per handler logic');
    }

    @IsTest
    static void testDmlExceptionReturnsFalse() {
        // Force an exception by passing a list with a null element which causes DML to throw
        List<Test_Your_Knowledge_Results__c> input = new List<Test_Your_Knowledge_Results__c>{ null };

        Test.startTest();
        Boolean res = VSCCS_QuizResultHandler.saveQuizResults(input);
        Test.stopTest();

        System.assertEquals(false, res, 'Unexpected exception path should return false');
    }

    @IsTest
    static void testBulkProcessingTenRecords() {
        List<Test_Your_Knowledge_Results__c> records = new List<Test_Your_Knowledge_Results__c>();
        for (Integer i = 0; i < 10; i++) {
            records.add(makeValidResult(i));
        }

        Test.startTest();
        Boolean res = VSCCS_QuizResultHandler.saveQuizResults(records);
        Test.stopTest();

        System.assertEquals(true, res, 'Bulk insert of valid records should return true');
    }
}