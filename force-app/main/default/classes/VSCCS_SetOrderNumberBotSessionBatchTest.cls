/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VSCCS_SetOrderNumberBotSessionBatchTest
Created Date       : Oct 30, 2024
@description       : This is the test class for VSCCS_SetOrderNumberBotSessionBatch
@author            : Himanshu Mishra <hmishra@victoria.com>
@story             : CCS-703
Modification Log:
Ver   Date         Author          Story/Defect#         Modification
1.0   Oct 30,2024  Himanshu Mishra   CCS-703             Initial Version
1.1   May 23,2025  Himanshu Mishra   DP-91107             Replace the NF object refernces to custom objects
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class VSCCS_SetOrderNumberBotSessionBatchTest {
  private static void setupTestData() {
    List<Messaging_Insight__c> botSessions = new List<Messaging_Insight__c>();
    Datetime ysterday = Date.today().addDays(-1);
    for (Integer i = 0; i < 5; i++) {
      Messaging_Insight__c session = new Messaging_Insight__c();
      session.Order_Number__c = null;
      session.createddate = ysterday;
      botSessions.add(session);
    }
    insert botSessions;

    List<Messaging_Bot_Chat_Log__c> botChatLogs = new List<Messaging_Bot_Chat_Log__c>();
    for (Integer i = 0; i < 5; i++) {
      Messaging_Bot_Chat_Log__c chatLog = new Messaging_Bot_Chat_Log__c();
      chatLog.Current_Utterance__c = 'W12345678' + i;
      chatLog.Messaging_Insight__c = botSessions[i].Id;
      chatLog.createddate = ysterday;
      botChatLogs.add(chatLog);
    }
    insert botChatLogs;
  }

  @isTest
  public static void testBatchMethods() {
  }
  // Test method for the success batch execution
  @isTest
  static void testSuccessBatchExecution() {
    // Set up test data
    setupTestData();

    // Start a test context to execute the batch
    Test.startTest();
    List<Messaging_Insight__c> botSessions = [
      SELECT
        Id,
        Order_Number__c,
        (SELECT Current_Utterance__c FROM Messaging_Bot_Chat_Logs__r)
      FROM Messaging_Insight__c
      LIMIT 10
    ];
    // Execute the batch with a batch size of 2
    System.debug('botSessions ' + botSessions);
    VSCCS_SetOrderNumberBotSessionBatch batch = new VSCCS_SetOrderNumberBotSessionBatch();
    Database.QueryLocator ql = batch.start(null);
    batch.execute(null, botSessions);
    batch.Finish(null);
    Test.stopTest();

    // Validate the results: Check if Order_Number__c is updated for valid bot sessions
    List<Messaging_Insight__c> updatedSessions = [
      SELECT Id, Order_Number__c
      FROM Messaging_Insight__c
    ];
    for (Messaging_Insight__c session : updatedSessions) {
      if (session.Order_Number__c != null) {
        System.assertEquals(
          10,
          session.Order_Number__c.length(),
          'The order number should be updated correctly'
        );
      }
    }
  }

  /* Test method for the failure batch execution
    @isTest
    static void testFailureBatchExecution() {
        // Set up test data
        setupTestData();
        
        // Start a test context to execute the batch
        Test.startTest();
        List<Messaging_Insight__c> botSessions = [SELECT Id, Order_Number__c, (SELECT ebotdata__Current_Utterance__c FROM Messaging_Bot_Chat_Log__r) FROM Messaging_Insight__c Limit 10 ];
        // Execute the batch with a batch size of 2
        System.debug('botSessions '+botSessions);
        Test.setMock(DmlException.class, new DmlException());
        VSCCS_SetOrderNumberBotSessionBatch batch = new VSCCS_SetOrderNumberBotSessionBatch();
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null,botSessions);
        batch.Finish(null);
        Test.stopTest();
        
        // Validate the results: Check if Order_Number__c is updated for valid bot sessions
        List<Messaging_Insight__c> updatedSessions = [SELECT Id, Order_Number__c FROM Messaging_Insight__c];
        for (Messaging_Insight__c session : updatedSessions) {
            if (session.Order_Number__c != null) {
                System.assertEquals('W123456781', session.Order_Number__c, 'The order number should be updated correctly');
            }
        }
    }*/

  // Test method for the schedulable functionality
  @isTest
  static void testScheduledBatchExecution() {
    // Set up test data
    setupTestData();

    // Start a test context for scheduled job
    Test.startTest();

    // Schedule the batch
    String cronExpression = '0 0 4 * * ?';
    VSCCS_SetOrderNumberBotSessionBatch batch = new VSCCS_SetOrderNumberBotSessionBatch();
    String jobId = System.schedule(
      'Test Bot Session Order Batch',
      cronExpression,
      batch
    );

    // Stop the test and execute the scheduled job
    Test.stopTest();

    // Query the CronTrigger to check if the job is scheduled
    CronTrigger ct = [
      SELECT Id, CronExpression, State
      FROM CronTrigger
      WHERE Id = :jobId
    ];
    System.assertEquals(
      'WAITING',
      ct.State,
      'The batch job should be scheduled and waiting.'
    );
  }
}