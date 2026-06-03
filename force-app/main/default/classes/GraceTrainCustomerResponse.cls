public with sharing class GraceTrainCustomerResponse {
    @InvocableMethod(label='GRACE - Get Customer Response')
    public static List<Output> getCustomerResponse(List<Input> input){
        
        String setName = input[0].setName;
        System.debug('Customer Response Set Name :: ' + setName);
        Training_Question__c res = [SELECT Id, Name, Questions__c, Next_Action__c from Training_Question__c where Set_Name__c =: setName ];
        Output obj = new Output();
        obj.questions = String.valueOf(res.get('Questions__c'));
        obj.nextAction = String.valueOf(res.get('Next_Action__c'));
        obj.questionId =  String.isEmpty(input[0].existingQuestionID) ?  String.valueOf(res.get('Name')) : input[0].existingQuestionID + ',' + String.valueOf(res.get('Name'))   ;

        List<Output> output = new  List<Output>();
        output.add(obj);
        System.debug(output);
        return output;
    }

    
    public class Input{
        @InvocableVariable(required=true)
        public String setName;
        @InvocableVariable(required=true)
        public String existingQuestionID;
    }
    
    public class Output{
        @InvocableVariable
        public String nextAction;
        @InvocableVariable
        public String questions;
        @InvocableVariable
        public String questionId;
        
    }
}