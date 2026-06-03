/****************************************************************************************************************
* Program Name         : NF_ChatTranscriptDataFixBatchSchTest
* Description          : Test class for NF_ChatTranscriptDataFixBatchSchTest
* Version              : 1.1
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   _          		DP-51067      1.1       Manishi      23 Dec,2021       Schedulable class to schedule batch NF_ChatTranscriptDataFixBatch
*     
*****************************************************************************************************************/
@isTest
private class NF_ChatTranscriptDataFixBatchSchTest {

    @isTest
    static void testschedule() {

        Test.StartTest();
        NF_ChatTranscriptDataFixBatchScheduler scheduler = new NF_ChatTranscriptDataFixBatchScheduler();
        String cron = '0 0 0/1 1/1 * ? *';
        String jobId = System.schedule('Test Schedule Check', cron, scheduler);
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
    }
    @isTest
    static void testscheduleParameter() {

        Test.StartTest();
        NF_ChatTranscriptDataFixBatchScheduler scheduler = new NF_ChatTranscriptDataFixBatchScheduler(1);
        String cron = '0 0 0/1 1/1 * ? *';
        String jobId = System.schedule('Test Schedule Check', cron, scheduler);
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
    }

}