public with sharing class GraceTrainOptions {

    @InvocableMethod(label='GRACE - Get Train Questions')
    public static List<List<Output>> queryQuestions(List<Input> input){
        
        String selectedOption = input[0].setName;
        System.debug(selectedOption);
        List<Training_Question__c> optionList = new List<Training_Question__c>();
        optionList = [SELECT Id, Name,  Sequence__c, Questions__c, hasDependency__c, Dependency__c, Next_Action__c, Score__c, Set_Name__c , Evaluation__c from Training_Question__c where Set_Name__c =: selectedOption order by Sequence__c ] ;

        List<Output> output = new List<Output>();

        if (optionList.size() > 0) {
            for (Training_Question__c tq : optionList) {
                Output o = new output();
                o.questionID = String.valueOf(tq.get('Name'));
                o.question = String.valueOf(tq.get('Questions__c'));
                o.nextAction = String.valueOf(tq.get('Next_Action__c'));
                o.score = String.valueOf(tq.get('Score__c'));
                o.evaluationSummary = String.valueOf(tq.get('Evaluation__c'));
                o.dependency = String.valueOf(tq.get('Dependency__c'));
                o.hasDependency =  Boolean.valueOf(tq.get('hasDependency__c'));
                output.add(o);
            }
        }
        
        List<List<Output>> options = new List<List<Output>>();
        options.add(output);
        System.debug(options);
        return options;
    }
    

    public class Input{
        @InvocableVariable(required=true)
        public String setName;
    }
    
    public class Output{
        @InvocableVariable(required=true)
        public String question;
        @InvocableVariable(required=true)
        public String nextAction;
        @InvocableVariable(required=true)
        public String score;
        @InvocableVariable(required=true)
        public String sequence;
        @InvocableVariable(required=true)
        public String questionID;
        @InvocableVariable(required=true)
        public String evaluationSummary;
        @InvocableVariable(required=true)
        public String dependency;
        @InvocableVariable(required=true)
        public Boolean hasDependency;
    }

}