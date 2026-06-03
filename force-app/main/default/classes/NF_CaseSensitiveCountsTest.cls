/****************************************************************************************************************
* Program Name         : NF_CaseSensitiveCountsTest
* Description          : Test coverage for NF_CaseSensitiveCounts
* Version              : 1.0
* Modification Log     : 1st October 2021
*------------------------------------------------------------------------------------------------------------
*JiraId       Version    Developer               Date              Description 
*------------------------------------------------------------------------------------------------------------
*DP-47703      1.0       Peter Waddington        1st October 2021  Test coverage for NF_CaseSensitiveCounts
*                                                                
*****************************************************************************************************************/

@IsTest
private class NF_CaseSensitiveCountsTest {
    static Id recordTypeIdPA = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    static Id sensitiveCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Sensitive_Case').getRecordTypeId();
    static Id relationsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Relations_Case').getRecordTypeId();
    @testSetup
    static void createTestData() {
        NF_CaseTriggerDomainHandler.isSensitiveCountEnabled = true;

        Account testAccountA = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account A'
        );
        Account testAccountB = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account B'
        );
        Account testAccountC = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account C'
        );
        insert new Account[]{testAccountA, testAccountB, testAccountC};
        
        Case testCaseRelationsA = new Case(
            RecordTypeId = relationsCaseRecordTypeId,
            AccountId = testAccountA.Id
        );
        Case testCaseSensitiveA = new Case(
            RecordTypeId = sensitiveCaseRecordTypeId,
            AccountId = testAccountA.Id
        );
        Case testCaseRelationsC = new Case(
            RecordTypeId = relationsCaseRecordTypeId,
            AccountId = testAccountC.Id
        );
        Case testCaseSensitiveCOne = new Case(
            RecordTypeId = sensitiveCaseRecordTypeId,
            AccountId = testAccountC.Id
        );
        Case testCaseSensitiveCTwo = new Case(
            RecordTypeId = sensitiveCaseRecordTypeId,
            AccountId = testAccountC.Id
        );
        Case testCaseSensitiveCThree = new Case(
            RecordTypeId = sensitiveCaseRecordTypeId,
            AccountId = testAccountC.Id
        );
        insert new Case[]{testCaseRelationsA, testCaseSensitiveA, testCaseRelationsC, testCaseSensitiveCOne, testCaseSensitiveCTwo, testCaseSensitiveCThree};
    }

    @IsTest
    static void validateSetup() {
        Account accA = [
            SELECT 
                Id, 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account A'
        ];
        Account accC = [
            SELECT 
                Id, 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account C'
        ];
        System.assertEquals(1, accA.In_Progress_Sensitive_Case_Count__c);
        System.assertEquals(3, accC.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testNewSensitiveCase() {
        Id sensitiveCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Sensitive_Case').getRecordTypeId();
        Account beforeAccA = [
            SELECT 
                Id, 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account A'
        ];
        Test.startTest();
        Case testCase = new Case(
            RecordTypeId = sensitiveCaseRecordTypeId,
            AccountId = beforeAccA.Id
        );
        insert testCase;
        Test.stopTest();
        Account afterAccA = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE Id = :beforeAccA.Id
        ];
        System.assertEquals(2, afterAccA.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testChangeAccountOnSensitiveCase() {
        Id sensitiveCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Sensitive_Case').getRecordTypeId();
        Account beforeAccB = [
            SELECT 
                Id, 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account B'
        ];
        Case beforeCase = [
            SELECT 
                Id,
                AccountId
            FROM Case
            WHERE RecordTypeId = :sensitiveCaseRecordTypeId
            AND Account.LastName = 'Account A'
            LIMIT 1
        ];
        beforeCase.AccountId = beforeAccB.Id;
        Test.startTest();
        update beforeCase;
        Test.stopTest();
        Account afterAccA = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account A'
        ];
        Account afterAccB = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account B'
        ];
        System.assertEquals(0, afterAccA.In_Progress_Sensitive_Case_Count__c);
        System.assertEquals(1, afterAccB.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testChangeAccountOnMultipleSensitiveCase() {
        Id sensitiveCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Sensitive_Case').getRecordTypeId();
        Account beforeAccB = [
            SELECT 
                Id, 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account B'
        ];
        List<Case> beforeCaseList = [
            SELECT 
                Id,
                AccountId
            FROM Case
            WHERE RecordTypeId = :sensitiveCaseRecordTypeId
            AND Account.LastName = 'Account C'
        ];
        for (Case beforeCase:beforeCaseList) {
            beforeCase.AccountId = beforeAccB.Id;
        }
        Test.startTest();
        update beforeCaseList;
        Test.stopTest();
        Account afterAccB = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account B'
        ];
        Account afterAccC = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE LastName = 'Account C'
        ];
        System.assertEquals(3, afterAccB.In_Progress_Sensitive_Case_Count__c);
        System.assertEquals(0, afterAccC.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testCloseSensitiveCase() {
        Case beforeCase = [
            SELECT 
                Id,
                AccountId
            FROM Case
            WHERE RecordTypeId = :sensitiveCaseRecordTypeId
            LIMIT 1
        ];
        beforeCase.Auto_Closed__c = true;
        beforeCase.Status = 'Closed';
        Test.startTest();
        update beforeCase;
        Test.stopTest();
        Account afterAccA = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE Id = :beforeCase.AccountId
        ];
        System.assertEquals(0, afterAccA.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testRelationsCaseBecomesSensitive() {
        Case beforeCase = [
            SELECT 
                Id,
                AccountId
            FROM Case
            WHERE RecordTypeId = :relationsCaseRecordTypeId
            LIMIT 1
        ];
        beforeCase.RecordTypeId = sensitiveCaseRecordTypeId;
        Test.startTest();
        update beforeCase;
        Test.stopTest();
        Account afterAccA = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE Id = :beforeCase.AccountId
        ];
        System.assertEquals(2, afterAccA.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testDeleteSensitiveCase() {
        Case beforeCase = [
            SELECT 
                Id,
                AccountId
            FROM Case
            WHERE RecordTypeId = :sensitiveCaseRecordTypeId
            LIMIT 1
        ];
        Test.startTest();
        delete beforeCase;
        Test.stopTest();
        Account afterAccA = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE Id = :beforeCase.AccountId
        ];
        System.assertEquals(0, afterAccA.In_Progress_Sensitive_Case_Count__c);
    }

    @IsTest
    static void testDeleteRelationsCase() {
        Case beforeCase = [
            SELECT 
                Id,
                AccountId
            FROM Case
            WHERE RecordTypeId = :relationsCaseRecordTypeId
            LIMIT 1
        ];
        Test.startTest();
        delete beforeCase;
        Test.stopTest();
        Account afterAccA = [
            SELECT 
                In_Progress_Sensitive_Case_Count__c 
            FROM Account
            WHERE Id = :beforeCase.AccountId
        ];
        System.assertEquals(1, afterAccA.In_Progress_Sensitive_Case_Count__c);
    }
}