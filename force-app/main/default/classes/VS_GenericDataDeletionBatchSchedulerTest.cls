/**
 * @name: VS_GenericDataDeletionBatchSchedulerTest
 * @description: Test class for the VS_GenericDataDeletionBatchScheduler class.
 */
@isTest
public class VS_GenericDataDeletionBatchSchedulerTest {
    @isTest
    static void testschedule() {

        Test.StartTest();
        VS_GenericDataDeletionBatchScheduler scheduler = new VS_GenericDataDeletionBatchScheduler('Account');
        String cron = '0 0 0/1 1/1 * ? *';
        String jobId = System.schedule('Test Schedule Check', cron, scheduler);
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
    }
    @isTest
    static void testscheduleParameter() {
		DateTime startDate = DateTime.newInstance(2021, 2, 19);
		DateTime endDate = DateTime.newInstance(2021, 2, 20);
        Test.StartTest();
        VS_GenericDataDeletionBatchScheduler scheduler = new VS_GenericDataDeletionBatchScheduler('Account', startDate, endDate);
        String cron = '0 0 0/1 1/1 * ? *';
        String jobId = System.schedule('Test Schedule Check', cron, scheduler);
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
    }
    @isTest
    static void purgeProcessOfFeedbackForm() {
        Test.StartTest();
        VS_GenericDataDeletionBatchScheduler scheduler = new VS_GenericDataDeletionBatchScheduler('Associate_Feedback_Form__c', 2);
        String cron = '0 0 3 ? * SUN';
        String jobId = System.schedule('Purge Process', cron, scheduler);
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
    }
}