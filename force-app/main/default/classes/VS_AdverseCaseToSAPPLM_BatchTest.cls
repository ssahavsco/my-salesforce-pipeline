@IsTest
public class VS_AdverseCaseToSAPPLM_BatchTest {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }
    
    static testMethod void deleteDataBetweenSpecificsDates(){
        List<LogEntry__c> logEntryRecords = [Select Id,isDataPublishedToSAP__c,RecordId__c,Message__c,CreatedDate,SAP_Articles__c From LogEntry__c limit 5];
        Test.setMock(HttpCalloutMock.class, new VS_AdverseCaseToSAPPLM_APIHandlerMock(true, '201'));
        Test.startTest();
            VS_AdverseCaseToSAPPLM_Batch cb = New VS_AdverseCaseToSAPPLM_Batch();
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null, logEntryRecords);
            cb.Finish(null);
        Test.stopTest();
    }
    
    private static void testSetupData(){
        Case caseObj = new Case();
        caseObj.Date_Time_of_Issue__c = datetime.now();
        caseObj.VS_Safety_Team_Confirmed_Article__c = '89231209';
        insert caseObj;
        
        Log__c logObj = new Log__c();
        logObj.Status__c = 'New';
        insert logObj;
        
        LogEntry__c logEObj = new LogEntry__c();
        logEObj.isDataPublishedToSAP__c = false;
        logEObj.RecordId__c = [Select Id From Case limit 1].Id;
        logEObj.Message__c = 'Failed due to an error';
        logEObj.Log__c = [Select Id From Log__c limit 1].Id;
        logEObj.CreatedDate = datetime.now();
        insert logEObj;
        
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