/** Created by Sumit Saha 
 *  10-Oct-2023
 */
public with sharing class GraceCCSDef {
    public class Input{
        @InvocableVariable(required=true)
        public String selectedMenu;
    }
    public class Output{
        @InvocableVariable(required=true)
        public String topicName;
        @InvocableVariable(required=true)
        public String dialougeName;
        @InvocableVariable(required=true)
        public String description;
    }

    @InvocableMethod(label='GRACE - Get CCS Defination')
    public static List<Output> getCCSDefination(List<Input> input){
        String selectedMenu = input[0].selectedMenu;
        List<Output> output = new List<Output>();
        try {
            Grace_CCS_Def__mdt	ccs = [Select Topic_Name__c, Selected_Menu_Option__c, Description__c, Dialogue_Name__c from Grace_CCS_Def__mdt where Selected_Menu_Option__c =: selectedMenu ];
            Output obj = new Output();
            obj.topicName =  String.valueOf(ccs.Topic_Name__c);
            obj.dialougeName = String.valueOf(ccs.Dialogue_Name__c);
            obj.description = String.valueOf(ccs.Description__c);
        
            List<String> lineBreak = new  List<String>(obj.description.split('\n'));
            output.add(obj);

        } catch (Exception e) {
            Logger.error('GraceCCSDef :: ' + e.getMessage());
        }
        
        return output;
    }
}