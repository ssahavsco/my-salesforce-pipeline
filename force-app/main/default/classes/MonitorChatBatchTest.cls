@isTest
public class MonitorChatBatchTest {
	@testSetup
    public static void setup(){
        DateTime oneMinutePrior = Datetime.now().addMinutes(-2);
        Active_Session__c actSession = new Active_Session__c(Active_Session_Key__c='test',CreatedDate = oneMinutePrior, LastModifiedDate = oneMinutePrior);
        insert actSession;
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Unique_Identifier__c From MessagingSession Limit 1];
        msgSession.Unique_Identifier__c = 'test';
        update msgSession;
    }
    
    @isTest
    public static void testBatch(){
        List<Active_Session__c> activeSessions = [SELECT Id, Active_Session_Key__c, CreatedDate, LastModifiedDate
            FROM Active_Session__c WHERE CreatedDate = TODAY
            ORDER BY CreatedDate DESC ];
        List<MessagingSession> sessions = [SELECT Id, Unique_Identifier__c, CreatedDate, LastModifiedDate
            FROM MessagingSession WHERE CreatedDate = TODAY
            ORDER BY CreatedDate DESC ];
        Test.startTest();
        	MonitorChatBatch batch = new MonitorChatBatch();
            Database.QueryLocator ql = batch.start(null);
            batch.execute(null, activeSessions);
            batch.Finish(null);
        Test.stopTest();
    }
  @isTest
  static void testScheduledBatchExecution() {
    // Start a test context for scheduled job
    Test.startTest();
    // Schedule the batch
    String cronExpression = '0 0 4 * * ?';
    MonitorChatBatch batch = new MonitorChatBatch();
    String jobId = System.schedule(
      'Monitor Chat Batch',
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
  }
}