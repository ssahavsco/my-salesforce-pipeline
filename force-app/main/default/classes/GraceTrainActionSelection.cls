public with sharing class GraceTrainActionSelection {
    public class Input{
        @InvocableVariable(required=true)
        public String selectedMenuOption;
    }
    public class Output{
        @InvocableVariable(required=true)
        public String actionName;
    }

    @InvocableMethod(label='GRACE - Get Action Name')
    public static List<Output> getActionPath(List<Input> input){
        System.debug('User has selected the option :: ' + input[0].selectedMenuOption );
        List<Grace_Train_Contact__mdt> metaData  = [Select Id, Contact_Name__c, Action_Path__c from Grace_Train_Contact__mdt ];
        List<Output> output = new  List<Output>();
        Output obj = new Output();
            for (Grace_Train_Contact__mdt index : metaData) {
                if (index.Contact_Name__c == input[0].selectedMenuOption) {
                    obj.actionName = index.Action_Path__c;
                    output.add(obj);
                }
            }
        return output;    
    }
}