public with sharing class GraceTrainOptionsSpec {
    
    public class Input{

        @InvocableVariable
        public GraceTrainOptions.Output option;
        @InvocableVariable
        public String existingEvaluation;
        @InvocableVariable
        public String existingQuestionID;
        
    }

    public class Output{
        @InvocableVariable(required=true)
        public String question;
        @InvocableVariable(required=true)
        public String nextAction;
        @InvocableVariable(required=true)
        public String score;
        @InvocableVariable(required=true)
        public String evaluationSummary;
        @InvocableVariable(required=true)
        public String questionId;
        @InvocableVariable(required=true)
        public String dependency;

    }

    @InvocableMethod(label='GRACE - Get Detailed Records')
    public static List<Output> getDetails(List<Input> input){
        System.debug(input);
        Output obj = new Output();
        List<Output> output = new List<Output>();
        obj.question = input[0].option.question;
        // obj.nextAction = input[0].option.nextAction;
        obj.score = input[0].option.score;
        obj.evaluationSummary = String.isEmpty(input[0].existingEvaluation) ? ( !String.isEmpty(input[0].option.evaluationSummary) ? input[0].option.evaluationSummary : '' )  : ( input[0].existingEvaluation + '\n\n' +  ( !String.isEmpty(input[0].option.evaluationSummary) ? input[0].option.evaluationSummary : '' )) ;
        obj.questionId =  String.isEmpty(input[0].existingQuestionID) ? input[0].option.questionID : input[0].existingQuestionID + ',' + input[0].option.questionID;
        obj.dependency = input[0].option.dependency;
        obj.nextAction =  input[0].option.hasDependency == false ? input[0].option.nextAction : getNextAction( String.valueOf(obj.questionId),  String.valueOf( input[0].option.nextAction));
        output.add(obj);
        System.debug( output[0]);
        return output;
    }


    public static String getNextAction(String selectedOptions, String nextAction){

        List< String> listselectedOptions = selectedOptions.split(',');
        List<Training_Question__c> tq = [SELECT Id,Name, Next_Action__c,  Dependency__c from Training_Question__c where Set_Name__c =: nextAction];
        String action;

        for (Training_Question__c index : tq) {
                if(!String.isEmpty(index.Dependency__c)){
                    List<String> listDependency = index.Dependency__c.split(',');
                    Integer approve = 0;
                    Integer counter = 0;

                        while(counter< listDependency.size()){
                            if(listselectedOptions.contains (listDependency[counter])){
                                System.debug(listDependency[counter]);
                                approve++;
                            }
                            counter++;  
                        }

                        If(listDependency.size() == approve){
                            System.debug( 'Dependency mactched ' + index.Next_Action__c);
                            action = String.valueOf(index.Next_Action__c);
                            break;
                        }
                        else{
                            System.debug( 'Dependency doesnt meet :: Next Action :: END' );
                            action = 'END';
                        }
                }
                else{
                    System.debug( 'Without Dependency :: END ');
                    action = 'END';
                }

        }

        return action;

          
    }


}