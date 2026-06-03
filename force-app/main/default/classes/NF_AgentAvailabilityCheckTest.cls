/**
 * Created by adamundus LLC on 9/14/20.
 */

@IsTest
private class NF_AgentAvailabilityCheckTest {
    @isTest static void test1(){
        List<LiveChatDeployment> deploymentList = [SELECT Id FROM LiveChatDeployment];
        List<LiveChatButton> chatButtonIdList =[SELECT Id FROM LiveChatButton];

        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockLiveAgentResponse());

        NF_AgentAvailabilityCheck.Input input = new NF_AgentAvailabilityCheck.Input();
        input.sChatButtonDeveloperName = 'CCARE';
        input.sChatDeploymentDeveloperName = 'CCARE';
        List<NF_AgentAvailabilityCheck.Input> inputList = new List<NF_AgentAvailabilityCheck.Input>{ input };

        System.assert(NF_AgentAvailabilityCheck.checkAgentAvailability(inputList) != null, 'should not be nulls');
        Test.stopTest();
    }

    @IsTest
    static void testButtonAvailability() {
        String deploymentName = 'Customer_Care';
        String buttonName = 'Customer_Care_Bot';

        Test.startTest();
        Boolean isAvailable = NF_AgentAvailabilityCheck.getButtonAvailability(buttonName, deploymentName);
        Test.stopTest();

        System.assertNotEquals(null, isAvailable, 'should not be null');
    }

    public class MockLiveAgentResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"results":{"type":"array","description":"List of ids and their availability","items":{"name":"result","type":"object","properties":{"isAvailable":{"type":"boolean","description":"Whether or not the entity is available for chat","required":true,"version":29.0}}},"required":true}}');
            res.setStatusCode(200);
            return res;
        }
    }
}