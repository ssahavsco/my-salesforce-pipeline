@isTest
public class VS_AdverseCaseToSAPPLM_APITest {
    @TestSetup
    static void setupData(){
        testSetupData();
    }
    
    @isTest
    public static void successTestMethod(){
        //List<VS_AdverseCaseToSAPPLM_API.Input> inputList = new List<VS_AdverseCaseToSAPPLM_API.Input>();
        VS_AdverseCaseToSAPPLM_API.FlowInput input = new VS_AdverseCaseToSAPPLM_API.FlowInput();
        input.articleNo = 'Ag12899';
        input.adverseEventDate = datetime.now();
        input.sfCaseNumber = '0987262';
        input.eventType = 'Non-Serious Adverse Event';
        input.beautyAdverseReactionSurvey = 'Survey Intro: Yes<br>Describe Symptoms: Itchiness<br>Part of Body?: Lips<br>If yes, transfer to Safety Call: <br>Did you consult a Medical Professional?: Yes<br>If yes, what is the Physicians practice?: Other<br>What was the diagnosis?: adverse reaction<br>What was the treatment?: Other<br>If other, what was the treament?: Steroid shot that she was told would act like Benadryl would<br>Experienced this type of event before?: No<br>When did the symptoms develop?: Several Hours Later<br>If other, describe: <br>Changed any routinely used products?: No<br>Do you have any known allergies?: No Known Allergies<br>Were you taking any medications?: Yes<br>How many applications did it occur?: One<br>How long did the symptoms persist?: Longer than 24 hours<br>Describe the discomfort: Mild<br>Use following discomfort?: No<br>Describe frequency?: Continuous<br>Conclusion: Customer incurred $15 Dr. Copay due to this incident. The itching has stopped and the swelling, redness and bumps are still there -- but are going away.';
        input.recordId = [Select Id From Case limit 1].Id;
 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VS_AdverseCaseToSAPPLM_APIHandlerMock(true, '201'));
        List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_API.pushCaseToSAP(new List<VS_AdverseCaseToSAPPLM_API.FlowInput> {input});
        Test.stopTest();
        
    }
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Create Initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){
        
        Case caseObj = new Case();
        caseObj.Date_Time_of_Issue__c = datetime.now();
        insert caseObj;
        
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
    }
}