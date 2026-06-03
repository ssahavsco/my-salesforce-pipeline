@isTest
private class ChatMonitorTest {
    
    @isTest
    static void testCreateActiveSession_Success() {
        RestRequest req = new RestRequest();
        System.RestResponse res = new System.RestResponse();
		String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Unique_Identifier__c From MessagingSession Limit 1];
        msgSession.Unique_Identifier__c = 'TEST_KEY_123';
        update msgSession;
        Test.startTest();

        req.requestURI = System.Label.Monitor_Chat_Endpoint; //'https://vscocustomercare--uat.sandbox.my.salesforce-sites.com/services/apexrest/ChatMonitor/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.Valueof('{"ActiveSessionKey":"TEST_KEY_123", "IsMinimized":false}');
        RestContext.request = req;
        RestContext.response = res;
        ChatMonitor.createActiveSession();
        Test.StopTest();
        
    }
    
    @isTest
    static void testCreateActiveSession_MissingKey() {
        
        RestRequest req = new RestRequest();
        System.RestResponse res = new System.RestResponse();
		String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select Unique_Identifier__c From MessagingSession Limit 1];
        msgSession.Unique_Identifier__c = 'TEST_KEY_123';
        update msgSession;
        Test.startTest();

        req.requestURI = System.Label.Monitor_Chat_Endpoint; //'https://vscocustomercare--uat.sandbox.my.salesforce-sites.com/services/apexrest/ChatMonitor/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.Valueof('{"WrongKey":"Value"}');
        RestContext.request = req;
        RestContext.response = res;
        ChatMonitor.createActiveSession();
        
        Test.StopTest();
    }
    
}