/** Created by sumit saha
 * date: 28-sep-23
 */
@isTest
public with sharing class GraceTrainOptionsSpecTest {
    @isTest
    public static void getDetails(){
        Training_Question__c tq = new Training_Question__c();
        tq.Questions__c = 'How can I help you? ';
        tq.Next_Action__c = 'Test002';
        tq.Score__c = 1.0;
        tq.Evaluation__c = 'You are good';
        tq.Dependency__c =  'Test001';
        tq.hasDependency__c =  false;
        tq.Set_Name__c = 'TestSet001';

        tq.Questions__c = 'How can I help you? ';
        tq.Next_Action__c = 'Test003';
        tq.Score__c = 1.0;
        tq.Evaluation__c = 'You are good';
        tq.Dependency__c =  'Test001';
        tq.hasDependency__c =  false;
        tq.Set_Name__c = 'Test002';

        insert tq;

        GraceTrainOptionsSpec.Input iSpec = new GraceTrainOptionsSpec.Input();
        GraceTrainOptions.Output out = new GraceTrainOptions.Output();
        iSpec.existingEvaluation = 'Test';
        iSpec.existingQuestionID = 'Test001, Test002';

        out.dependency =  'Test001';
        out.evaluationSummary = 'You are good';
        out.hasDependency = true;
        out.nextAction = 'Test002';
        out.question = 'How can I help you? ';
        out.questionID = 'Test002';
        out.score = '2';
        out.sequence = '1';

        iSpec.option = out;
        List<GraceTrainOptionsSpec.Input> listsepc = new  List<GraceTrainOptionsSpec.Input>();
        listsepc.add(iSpec);

        GraceTrainOptionsSpec.getDetails(listsepc);
    }
}