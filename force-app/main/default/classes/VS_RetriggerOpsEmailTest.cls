@isTest                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
public class VS_RetriggerOpsEmailTest {
    @testSetup
    static void setupTestData() {
        // Test data setup
        ServiceIntegration__c opsEmailService = new ServiceIntegration__c();
        opsEmailService.Name = 'Ops_Email_Service';
        opsEmailService.Base_Url__c = 'https://apitest.victoriassecret.com';
        opsEmailService.Suffix_Url__c = '/dssreturns/v1/triggeremail';
        opsEmailService.Content_Type__c = 'application/json';
        insert opsEmailService;
    }
    
    @isTest
    static void testRetriggerOpsEmail_Success() {
        VS_RetriggerOpsEmail.FlowInput testFlowInput = new VS_RetriggerOpsEmail.FlowInput();
        testFlowInput.emailType = 'RQR'; // Assuming the email types are 'RQR', 'RSL'
        testFlowInput.orderNumber = 'D000000000';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccessResponseGenerator());
        List<VS_RetriggerOpsEmail.FlowOutput> flowOutputList = VS_RetriggerOpsEmail.retriggerOpsEmail(new List<VS_RetriggerOpsEmail.FlowInput>{testFlowInput});
        Test.stopTest();
        System.assertEquals(1, flowOutputList.size());
        VS_RetriggerOpsEmail.FlowOutput output = flowOutputList[0];
        System.assertEquals(true, output.isSuccess);
        System.assertEquals(204, output.apiResponseCode);
    }
    
    @isTest
    static void testRetriggerOpsEmail_Failure() {
        VS_RetriggerOpsEmail.FlowInput testFlowInput = new VS_RetriggerOpsEmail.FlowInput();
        testFlowInput.emailType = 'RQR'; // Assuming the email types are 'RQR', 'RSL'
        testFlowInput.orderNumber = 'D000000000';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpFailureResponseGenerator());
        List<VS_RetriggerOpsEmail.FlowOutput> flowOutputList = VS_RetriggerOpsEmail.retriggerOpsEmail(new List<VS_RetriggerOpsEmail.FlowInput>{testFlowInput});
        Test.stopTest();
        System.assertEquals(1, flowOutputList.size());
        VS_RetriggerOpsEmail.FlowOutput output = flowOutputList[0];
        System.assertEquals(false, output.isSuccess);
        System.assertEquals(404, output.apiResponseCode);
    }
    
    @isTest
    static void testRetriggerOpsEmail_Failure2() {
        VS_RetriggerOpsEmail.FlowInput testFlowInput = new VS_RetriggerOpsEmail.FlowInput();
        testFlowInput.emailType = 'RQR'; // Assuming the email types are 'RQR', 'RSL'
        testFlowInput.orderNumber = 'D000000000';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpFailure2ResponseGenerator());
        List<VS_RetriggerOpsEmail.FlowOutput> flowOutputList = VS_RetriggerOpsEmail.retriggerOpsEmail(new List<VS_RetriggerOpsEmail.FlowInput>{testFlowInput});
        Test.stopTest();
        System.assertEquals(1, flowOutputList.size());
        VS_RetriggerOpsEmail.FlowOutput output = flowOutputList[0];
        System.assertEquals(false, output.isSuccess);
        System.assertEquals(500, output.apiResponseCode);
    }
    // Mock HTTP response generator for success ApiCallout
    private class MockHttpSuccessResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(204);
            return res;
        }
    }
    private class MockHttpFailureResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            return res;
        }
    }
    private class MockHttpFailure2ResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            return res;
        }
    }
}