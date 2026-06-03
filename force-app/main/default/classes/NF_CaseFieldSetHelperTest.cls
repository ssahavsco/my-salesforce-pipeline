/*
* Created By: NeuraFlash LLC
* Author: Balwant Verma
* Created Date : Sept 25, 2020
*/

@IsTest
public with sharing class NF_CaseFieldSetHelperTest {
    
    @TestSetup
    static void data() {
        String lctId = '';

        LiveChatVisitor visitorRecord = new LiveChatVisitor();
        insert visitorRecord;
        
        Case caseRecord = new Case();
        insert caseRecord;

        LiveChatTranscript ltcRecord =  new LiveChatTranscript();
        ltcRecord.LiveChatVisitorId = visitorRecord.Id;
        ltcRecord.CaseId = caseRecord.Id;
        insert ltcRecord;
        lctId = ltcRecord.Id;
    }

    @IsTest(SeeAllData=false)
    public static void testGetCaseId(){
        String caseId = '';
        LiveChatTranscript lctRecord = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        Test.startTest();
        caseId = NF_CaseFieldSetHelper.getCaseId(String.valueOf(lctRecord.Id));
        Test.stopTest();
        System.assert(!String.isBlank(caseId), 'Should have value');
    }

    @IsTest(SeeAllData=false)
    public static void testGetCaseFieldSetMap(){
        String fieldSetMap = '';
        Test.startTest();
        fieldSetMap = NF_CaseFieldSetHelper.getCaseFieldSetMap();
        Test.stopTest();
        System.assert(!String.isBlank(fieldSetMap), 'Should have value');
    }

    @IsTest(SeeAllData=false)
    public static void testGetFieldSortCriteria(){
        Map<String, String> fieldCriteria = new Map<String, String>();
        LiveChatTranscript lctRecord = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        Test.startTest();
        fieldCriteria = NF_CaseFieldSetHelper.getFieldSortCriteria();
        Test.stopTest();
        System.assert(fieldCriteria != null, 'Should have value');
    }
    
}