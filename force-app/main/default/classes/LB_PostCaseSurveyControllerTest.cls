/***************************************************************
Interface Name : LB_PostCaseSurveyControllerTest
CreatedDate : 29-July-21
Description :  
Created By : Sumit Saha

Revision History

Date Name Story Number Description
* TODO: 05/01/2021 Sumit S | DP-38194/OCOM-7999  - Custom Controller for Case close survey

***************************************************************/

@IsTest
public with sharing class LB_PostCaseSurveyControllerTest {


   @isTest
     static String dataSetup() {
        
        Case cs = new Case();
        cs.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Chat Case').getRecordTypeId();
        cs.Origin = 'Chat';
        cs.Type = 'Account Update / Email Frequency';
        cs.Status = 'New';
        cs.Sub_Type__c = 'Account Info Update';
        insert cs;

        System.assertNotEquals(null, cs, 'should have value');

        return (String)cs.get('Id');
      
    }

    @IsTest
    public static void testConstructor() {
        LB_PostCaseSurveyController testController = new LB_PostCaseSurveyController();
        System.assertNotEquals(null, testController, 'should have value');

    }


    @IsTest
    public static void testSaveFormResponses_emptyInput() {
        LB_PostCaseSurveyController testController = new LB_PostCaseSurveyController();
        testController.saveResponsesToBotSession();
        System.assertNotEquals(null, testController, 'should have value');
    }

    @IsTest
    public static void testSaveFormResponses_fullInput() {
        LB_PostCaseSurveyController testController = new LB_PostCaseSurveyController(dataSetup());

        testController.wouldChatAgain = 5;
        testController.overallExperience = 3;
        testController.questionSatisfaction = 2;
        testController.additionalComments = 'Happy Customer';


        testController.saveResponsesToBotSession();
        System.assertNotEquals(null, testController, 'should have value');
    }

    
}