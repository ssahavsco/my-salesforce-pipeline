/** Created by sumit saha
 * date: 28-sep-23
 */
@isTest
public with sharing class GraceTrainOptionsTest {
    @isTest
    public static void queryQuestionsTest(){
        Training_Question__c tq = new Training_Question__c();
        tq.Questions__c = 'How can I help you? ';
        tq.Next_Action__c = 'Test002';
        tq.Score__c = 1.0;
        tq.Evaluation__c = 'You are good';
        tq.Dependency__c =  'Test001';
        tq.hasDependency__c =  false;
        tq.Set_Name__c = 'TestSet001';
        insert tq;

        GraceTrainOptions.Input i = new GraceTrainOptions.Input();
        i.setName = 'TestSet001';
        List<GraceTrainOptions.Input> input = new List<GraceTrainOptions.Input>();
        input.add(i);
        GraceTrainOptions.queryQuestions(input);

    }
}