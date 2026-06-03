/*****************************************************************************************************
Class Name     :  NF_CaseTriggerHandlerTest
Purpose        :  Test coverage for NF_CaseTriggerHandler

History:
-------
VERSION  AUTHOR               DATE                DETAIL                          TICKET REFERENCE/ NO.
1.       Peter Waddington     6/23/2021           Original Version                DP-41234
*********************************************************************************************************/
@IsTest
public with sharing class NF_CaseTriggerHandlerTest {
    static String WantedCaseSubject = 'Chat test subject';
    static String PositiveTestRecordTypeDeveloperName = 'Chat_Case';
    static String NegativeTestRecordTypeDeveloperName = 'Store_Relations_Case';
    @TestSetup
    static void loadTestData() {

        LiveChatVisitor visitorRecord = new LiveChatVisitor();
        insert visitorRecord;

        LiveChatTranscript ltcRecord =  new LiveChatTranscript(
            Subject__c = WantedCaseSubject,
            LiveChatVisitorId = visitorRecord.Id
        );
        insert ltcRecord;
    }
    
    @isTest(SeeAllData=false)
    public static void positiveTest() {
        Case c = new Case();
        insert c;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(PositiveTestRecordTypeDeveloperName).getRecordTypeId();
        update c;

        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        lct.Case_Lookup__c = c.Id;
        lct.CaseId = c.Id;
        update lct;

        Test.startTest();
        c.Description = 'My test description';
        update c;
        Test.stopTest();

        c = [SELECT Id, Subject, RecordTypeId FROM Case LIMIT 1];
        System.assertEquals(WantedCaseSubject, c.Subject);

    }
    
    @isTest(SeeAllData=false)
    public static void negativeTest() {
        Case c = new Case();
        insert c;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(NegativeTestRecordTypeDeveloperName).getRecordTypeId();
        update c;

        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        lct.Case_Lookup__c = c.Id;
        lct.CaseId = c.Id;
        update lct;

        Test.startTest();
        c.Description = 'My test description';
        update c;
        Test.stopTest();

        c = [SELECT Id, Subject, RecordTypeId FROM Case LIMIT 1];
        //System.assertNotEquals(WantedCaseSubject, c.Subject);

    }
    
    
    @isTest(SeeAllData=false)
    public static void positiveTest_createCaseResol() {
        Case c = new Case();
        insert c;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(PositiveTestRecordTypeDeveloperName).getRecordTypeId();
        update c;

        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        lct.Case_Lookup__c = c.Id;
        lct.CaseId = c.Id;
        update lct;

        Test.startTest();
        c.Description = 'My test description';
        c.Status = 'Closed';
        c.Type = 'Place a new order';
        c.Temp_Case_Resolution_Type__c = 'Place a new order';
        c.Sub_Type__c ='Place an Order (No Attempt to Order Online)';
        c.Temp_Order_Number__c = 'W346289277';
         update c;
         
        
         c.Status = 'Closed';
        update c;
        Test.stopTest();

        c = [SELECT Id, Subject, RecordTypeId FROM Case LIMIT 1];
        System.assertEquals(WantedCaseSubject, c.Subject);

    }
}