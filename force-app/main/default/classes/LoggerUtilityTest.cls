/****************************************************************************************************************
* Program Name         : LoggerUtilityTest
* Description          : Test class for the LoggerUtilityClass
* Version              : 1.0
* Modification Log     : 9 August 2021
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId           Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          Utility Class      1.0       Peter Waddington       08/09/2021      Test coverage for the LoggerUtility class
* 
*****************************************************************************************************************/
@isTest
public with sharing class LoggerUtilityTest {
    /*
    @Author : Peter Waddington
    @Company : Neuraflash
    @Description : Test coverage for the LoggerUtility class
    */
    static testMethod void testInsertLog() {
        LoggerUtility.Logger loggerTest = new LoggerUtility.Logger('request', 'response');
        Case c = new Case(
            Origin='Email'
        );
        insert c;
        Test.startTest();
        try {
            c.Sub_Type__c = 'BadValue';
            update c;
        }
        catch (Exception e) {
            LoggerUtility.insertLog('LoggerUtility', 'insertLog', e);
        }
        LoggerUtility.insertLog('LoggerUtility', 'insertLog', loggerTest);
        Test.stopTest();
        List<Logger__c> logs = [SELECT Id FROM Logger__c];
        System.assertEquals(2, logs.size(), 'Logger entries should be created');
    }
    static testMethod void testFailInsertLog() {
        LoggerUtility.Logger loggerTest = new LoggerUtility.Logger(
            'A'.repeat(140000),
            'response'
        );
        Test.startTest();
        LoggerUtility.insertLog('LoggerUtility', 'insertLog', loggerTest);
        Test.stopTest();
        List<Logger__c> logs = [SELECT Id FROM Logger__c];
        System.assertEquals(0, logs.size(), 'Logger entry should not have been created');
    }
}