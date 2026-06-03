/**
 * @name: VS_AdverseCaseToSAPPLM_BatchSchedu
 * @description: Test class for the VS_AdverseCaseToSAPPLM_BatchScheduler class.
 */
@isTest
public class VS_AdverseCaseToSAPPLM_BatchScheduTest {
    @isTest
    static void testschedule() {

        Test.StartTest();
        VS_AdverseCaseToSAPPLM_BatchScheduler scheduler = new VS_AdverseCaseToSAPPLM_BatchScheduler();
        String cron = '0 0 0/1 1/1 * ? *';
        String jobId = System.schedule('Test Schedule Check', cron, scheduler);
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
    }
}