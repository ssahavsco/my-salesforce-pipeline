/** Created by sumit saha
 * date: 28-sep-23
 */
@isTest
public with sharing class GraceTrainCustomerResponseTest {
    @istest 
    public static void getCustomerResponseTest(){
        Training_Question__c tq = new Training_Question__c();
        tq.Questions__c = 'How can I help you? ';
        tq.Next_Action__c = 'TestSet002';
        tq.Score__c = 1.0;
        tq.Evaluation__c = 'You are good';
        tq.Dependency__c =  'Test001';
        tq.hasDependency__c =  false;
        tq.Set_Name__c = 'TestSet001';

        insert tq;

        GraceTrainCustomerResponse.Input i = new GraceTrainCustomerResponse.Input();
        i.setName = 'TestSet001';
        i.existingQuestionID = 'Test001';
        List<GraceTrainCustomerResponse.Input> input = new List<GraceTrainCustomerResponse.Input> ();
        input.add(i);
        GraceTrainCustomerResponse.getCustomerResponse(input);

    }
}