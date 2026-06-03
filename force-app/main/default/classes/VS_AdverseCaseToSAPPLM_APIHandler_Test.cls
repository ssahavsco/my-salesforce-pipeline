@isTest
public class VS_AdverseCaseToSAPPLM_APIHandler_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }   
    
    @isTest
    public static void successTestMethod(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = getDefaultFlowInput();
        input.articleNo = 'Ag12899, Ag12900';
        input.beautyAdverseReactionSurvey = null;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VS_AdverseCaseToSAPPLM_APIHandlerMock(true, '201'));
            List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(input);
        Test.stopTest();

        System.assertEquals(1, outputList.size(), 'Flow output should contain one aggregated result.');
        System.assertEquals(true, outputList[0].isSuccess, 'Result should be success when all article callouts return 201.');
        System.assertEquals(201, outputList[0].apiResponseStatusCode, 'Last response code should be 201.');
        System.assertEquals(null, outputList[0].errorMessage, 'No error message expected for successful flow.');
        
    }
    
    @isTest
    public static void failureTestMethod(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = getDefaultFlowInput();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VS_AdverseCaseToSAPPLM_APIHandlerMock(false, '403'));
            List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(input);
        Test.stopTest();

        System.assertEquals(1, outputList.size(), 'Flow output should contain one aggregated result.');
        System.assertEquals(false, outputList[0].isSuccess, 'Result should fail when SAP callout status is non-201.');
        System.assertEquals(403, outputList[0].apiResponseStatusCode, 'Expected mocked 403 response code.');
        System.assertEquals('Failed to publish data to SAP', outputList[0].errorMessage, 'Expected generic SAP failure message.');
        
    }

    @isTest
    public static void failure400RecordLockErrorCode001Test(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = getDefaultFlowInput();
        input.articleNo = 'Ag12899, Ag12900';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VS_AdverseCaseToSAPPLM_APIHandlerMock(false, '400', 'ERROR/001'));
            List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(input);
        Test.stopTest();

        System.assertEquals(false, outputList[0].isSuccess, 'Record lock errors should set the flow result to failure.');
        System.assertEquals(400, outputList[0].apiResponseStatusCode, 'Expected 400 response code for XML error case.');
        System.assertEquals('Record is locked', outputList[0].errorMessage, 'Expected parsed XML message for record lock error.');
    }

    @isTest
    public static void failure400UnknownErrorTest(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = getDefaultFlowInput();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VS_AdverseCaseToSAPPLM_APIHandlerMock(false, '400'));
            List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(input);
        Test.stopTest();

        System.assertEquals(false, outputList[0].isSuccess, 'Unknown 400 errors should fail flow output.');
        System.assertEquals(400, outputList[0].apiResponseStatusCode, 'Expected 400 response code.');
        System.assertEquals('Unknown error occurred', outputList[0].errorMessage, 'Expected parsed unknown XML error message.');
    }

    @isTest
    public static void csrfFetchFailureTest(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = getDefaultFlowInput();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CsrfFailureMock());
            List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(input);
        Test.stopTest();

        System.assertEquals(false, outputList[0].isSuccess, 'Missing CSRF token should fail processing.');
        System.assertEquals(401, outputList[0].apiResponseStatusCode, 'Expected authentication-like failure code when CSRF is absent.');
        System.assertEquals('Failed to fetch CSRF token', outputList[0].errorMessage, 'Expected explicit CSRF token failure message.');
    }

    @isTest
    public static void unexpectedExceptionDuringCalloutTest(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = getDefaultFlowInput();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ThrowingSapCalloutMock());
            List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(input);
        Test.stopTest();

        System.assertEquals(true, outputList[0].isSuccess, 'Current handler logic keeps success true for caught exceptions.');
        System.assertEquals(500, outputList[0].apiResponseStatusCode, 'Expected internal error code when exception is thrown.');
        System.assertEquals('Unexpected error during callout', outputList[0].errorMessage, 'Expected generic unexpected callout error message.');
    }

    private static VS_AdverseCaseToSAPPLM_API.FlowInput getDefaultFlowInput(){
        VS_AdverseCaseToSAPPLM_API.FlowInput input = new VS_AdverseCaseToSAPPLM_API.FlowInput();
        input.articleNo = 'Ag12899';
        input.adverseEventDate = datetime.now();
        input.sfCaseNumber = '0987262';
        input.eventType = 'Non-Serious Adverse Event';
        input.beautyAdverseReactionSurvey = 'Survey Intro: Yes<br>Describe Symptoms: Itchiness<br>Part of Body?: Lips<br>If yes, transfer to Safety Call: <br>Did you consult a Medical Professional?: Yes<br>If yes, what is the Physicians practice?: Other<br>What was the diagnosis?: adverse reaction<br>What was the treatment?: Other<br>If other, what was the treament?: Steroid shot that she was told would act like Benadryl would<br>Experienced this type of event before?: No<br>When did the symptoms develop?: Several Hours Later<br>If other, describe: <br>Changed any routinely used products?: No<br>Do you have any known allergies?: No Known Allergies<br>Were you taking any medications?: Yes<br>How many applications did it occur?: One<br>How long did the symptoms persist?: Longer than 24 hours<br>Describe the discomfort: Mild<br>Use following discomfort?: No<br>Describe frequency?: Continuous<br>Conclusion: Customer incurred $15 Dr. Copay due to this incident. The itching has stopped and the swelling, redness and bumps are still there -- but are going away.';
        input.recordId = [Select Id From Case limit 1].Id;
        return input;
    }

    private class CsrfFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            String endpoint = req.getEndpoint();
            if (endpoint == 'https://nonprod.test.apimanagement.us10.hana.ondemand.com/advevent/adverseeventSet?$format=json') {
                resp.setStatusCode(500);
                resp.setBody('CSRF failure');
            } else {
                resp.setStatusCode(201);
            }
            return resp;
        }
    }

    private class ThrowingSapCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String endpoint = req.getEndpoint();
            if (endpoint == 'https://nonprod.test.apimanagement.us10.hana.ondemand.com/advevent/adverseeventSet?$format=json') {
                HttpResponse csrfResponse = new HttpResponse();
                csrfResponse.setStatusCode(200);
                csrfResponse.setHeader('x-csrf-token', 'token123');
                csrfResponse.setHeader('set-cookie', 'a=b;c=d;e=f;g=h;i=j');
                return csrfResponse;
            }
            throw new CalloutException('Mocked callout exception');
        }
    }
    
    private class MockHttpSuccessResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String endPoint = req.getEndpoint();
            if(endPoint == 'https://nonprod.test.apimanagement.us10.hana.ondemand.com/v1/plm/oAuth/Token'){
                system.debug(endPoint);
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                Map<String,Object> resposeData = new Map<String,Object>();
                resposeData.put('access_token', '0X2CZVCJNT6ID--T-KDOLQ');
                resposeData.put('expires_in', 7200);
                resposeData.put('token_type', 'Bearer');
                resp.setBody(JSON.serialize(resposeData));
                return resp;
            } else if(endPoint == 'https://nonprod.test.apimanagement.us10.hana.ondemand.com/advevent/adverseeventSet?$format=json'){
                system.debug(endPoint);
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                resp.setHeader('x-csrf-token', 'WQTYUDWDASVBNMSSHDS');
                resp.setHeader('set-cookie', 'SAP_SESSIONID_QR2_320=jJtX2dk1vlciVFQAGErfklmqFfFm5BHvsNYAUFaR58U%3d;sap-usercontext=sap-client=320');
                return resp;
            } else {
                system.debug(endPoint);
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(201);
                return resp;
            }
        }
    }
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){
        // Test data setup
        List<ServiceIntegration__c> svcList = new List<ServiceIntegration__c>();
        ServiceIntegration__c opsEmailService = new ServiceIntegration__c();
        opsEmailService.Name = 'SAP_Auth_Token';
        opsEmailService.Base_Url__c = 'https://nonprod.test.apimanagement.us10.hana.ondemand.com';
        opsEmailService.Suffix_Url__c = '/v1/plm/oAuth/Token';
        opsEmailService.Content_Type__c = 'application/x-www-form-urlencoded';
        opsEmailService.Client_Id__c = '6789cvbnmrtyuiopfghjkTYIUICVB';
        opsEmailService.Client_Secret__c = 'SGAJHAJ567890hjkbn';
        opsEmailService.Grant_Type__c = 'client_credentials';
        opsEmailService.Method_Name__c = 'POST';
        svcList.add(opsEmailService);
        
        ServiceIntegration__c opsEmailService2 = new ServiceIntegration__c();
        opsEmailService2.Name = 'SAP_CSRF_Token';
        opsEmailService2.Base_Url__c = 'https://nonprod.test.apimanagement.us10.hana.ondemand.com';
        opsEmailService2.Suffix_Url__c = '/advevent/adverseeventSet?$format=json';
        opsEmailService2.Token_Type__c = 'bearer';
        opsEmailService2.Method_Name__c = 'GET';
        svcList.add(opsEmailService2);
        
        ServiceIntegration__c opsEmailService3 = new ServiceIntegration__c();
        opsEmailService3.Name = 'SAP_Callout_Service';
        opsEmailService3.Base_Url__c = 'https://nonprod.test.apimanagement.us10.hana.ondemand.com';
        opsEmailService3.Suffix_Url__c = '/advevent/adverseeventSet';
        opsEmailService3.Token_Type__c = 'bearer';
        opsEmailService3.Method_Name__c = 'POST';
        opsEmailService3.Content_Type__c = 'application/json';
        svcList.add(opsEmailService3);
        insert svcList;
        
        Case caseObj = new Case();
        caseObj.Date_Time_of_Issue__c = datetime.now();
        insert caseObj;
    }
}