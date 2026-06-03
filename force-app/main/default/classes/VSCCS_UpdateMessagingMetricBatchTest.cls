@isTest
public class VSCCS_UpdateMessagingMetricBatchTest {

    @isTest
    static void testBatchExecution() {
        // Setup test data
        String routableId = NF_UtilTest.createMessagingSession();
		insertMetric(routableId);
        // Test the default constructor
        Test.startTest();
        VSCCS_UpdateMessagingMetricBatch batch = new VSCCS_UpdateMessagingMetricBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that the batch processed the correct records
        List<MessagingSession> sessions = [SELECT Id FROM MessagingSession WHERE Status = 'Ended' AND Agent_Message_Count__c = NULL];
        //System.assertEquals(1, sessions.size(), 'Should have processed one session.');
    }
    
    @isTest
    static void testBatchWithLastNDays() {
        // Setup test data
        String routableId = NF_UtilTest.createMessagingSession();
		insertMetric(routableId);
        // Test the default constructor
        Test.startTest();
        VSCCS_UpdateMessagingMetricBatch batch = new VSCCS_UpdateMessagingMetricBatch(2);
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that the batch processed the correct records
        List<MessagingSession> sessions = [SELECT Id FROM MessagingSession WHERE Status = 'Ended' AND Agent_Message_Count__c = NULL];
        //System.assertEquals(1, sessions.size(), 'Should have processed one session.');
    }

    @isTest
    static void testBatchWithDateRange() {
        // Setup test data
        DateTime startDate = System.now().addDays(-1);
        DateTime endDate = System.now();
		String routableId = NF_UtilTest.createMessagingSession();
		insertMetric(routableId);
        // Test the constructor with date range
        Test.startTest();
        VSCCS_UpdateMessagingMetricBatch batch = new VSCCS_UpdateMessagingMetricBatch(startDate, endDate);
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that the batch processed the correct records
        List<MessagingSession> sessions = [SELECT Id FROM MessagingSession WHERE Status = 'Ended' AND Agent_Message_Count__c = NULL];
    }
    
    public static void insertMetric(String routableId){
        List<MessagingSessionMetrics> metricList = new List<MessagingSessionMetrics>();
        List<String> metricTypes = new List<String>{'AverageEndUserResponseTime','MaxAgentResponseTime','EndUserMessageCount','AgentMessageCount','MaxEndUserResponseTime','AverageAgentResponseTime'};
        for(Integer idx=0; idx<metricTypes.size(); idx++){
            MessagingSessionMetrics metric = new MessagingSessionMetrics();
        	metric.MessagingSessionId = routableId;
            metric.MessagingSessionMetricType = metricTypes.get(idx);
            metric.MessagingSessionMetricValue = 10;
            
            metricList.add(metric);
        } 
        insert metricList;
    }
}