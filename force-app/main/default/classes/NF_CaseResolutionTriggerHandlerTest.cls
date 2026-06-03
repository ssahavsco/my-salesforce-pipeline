/****************************************************************************************************************
* Program Name         : NF_CaseResolutionTriggerHandlerTest
* Description          : Test class for NF_CaseResolutionTriggerHandler
* Version              : 1.1
* Modification Log     : 06 May,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755      1.1       Divyanshu Kumar      06 May,2021       Test class for NF_CaseResolutionTriggerHandler
*                                                                                                                                                                                   
*****************************************************************************************************************/
@isTest
public class NF_CaseResolutionTriggerHandlerTest {

    @TestSetup
    static void setupData(){
        Account acc = new Account();
        acc.FirstName = 'test FisrtName Account';
        acc.LastName = 'test LastName Acc';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Divyanshu';
        con.LastName = 'test LastName Contact';
        con.Email = 'test12@gmail.com';
        insert con;

        Case testCase = new Case(
            RecordTypeId = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().getRecordTypeInfosByName().get( 'Chat Case' ).getRecordTypeId(),
            Origin = 'Chat',
            Type = 'Account Update / Email Frequency',
            Status = 'Open',
            Sub_Type__c = 'Account Info Update',
            VOC_Comments__c = 'Test Comments',
            Description = 'Test Description',
            AccountId = acc.Id,
            ContactId = con.Id,
            Original_Associate__c = UserInfo.getUserId()
        );
        insert testCase;

        Case_Resolution__c testOT1 = new Case_Resolution__c(
            Related_Case__c = testCase.Id,
            Case_Resolution_Type__c = 'Merchandise Request',
            Completion_Date__c = Date.today()
        );
        Case_Resolution__c testOT2 = new Case_Resolution__c(
            Related_Case__c = testCase.Id,
            Case_Resolution_Type__c = 'Merchandise Request',
            Completion_Date__c = Date.today()
        );
        Case_Resolution__c testOT3 = new Case_Resolution__c(
            Related_Case__c = testCase.Id,
            Case_Resolution_Type__c = 'Check Refund Request (US)'
        );
        List<Case_Resolution__c> crList = new List<Case_Resolution__c>{ testOT1, testOT2, testOT3 };
        insert crList;
    }

    @isTest
    static void updateCaseStatusTest(){
        Case_Resolution__c cR = [ SELECT Id FROM Case_Resolution__c WHERE Case_Resolution_Type__c = 'Check Refund Request (US)'  LIMIT 1 ];
        Test.startTest();
            cR.Completion_Date__c =  Date.today();
            update cR;
        Test.stopTest();
        String statusCase = [ SELECT Status FROM Case].Status;
        System.assertEquals( 'Closed', statusCase );
    }

    @isTest
    static void testGenericTriggerHander(){
        NF_GenericTriggerHandler genHandler = new NF_GenericTriggerHandler();
        System.assertEquals(false, genHandler.checkIsDisabled());
    }

    @isTest
    static void updateCaseStatusandOwnerTest(){
        Case_Resolution__c cR = [ SELECT Id FROM Case_Resolution__c WHERE Case_Resolution_Type__c = 'Check Refund Request (US)'  LIMIT 1 ];
        Test.startTest();
            cR.Rejection_Date_Time__c =  Date.today();
            update cR;
            ServiceChannel SChannelId= [SELECT Id FROM ServiceChannel Where DeveloperName LIKE '%case%' Limit 1];
            Case c = [SELECT Id,Original_Associate__c FROM Case LIMIT 1];
            NF_CaseResolutionTriggerHelper.createAgentWork(c,SChannelId);
            c.Original_Associate__c = null;
            update c;
            Case_Resolution__c cR1 = [ SELECT Id FROM Case_Resolution__c WHERE Case_Resolution_Type__c = 'Merchandise Request'  LIMIT 1 ];
            cR1.Rejection_Date_Time__c =  Date.today();
            update cR1;
        Test.stopTest();
        String statusCase = [ SELECT Status FROM Case].Status;
        System.assertEquals( 'Open', statusCase );
    }
}