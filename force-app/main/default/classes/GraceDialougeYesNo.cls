/** Created by Sumit Saha 
 *  10-Oct-2023
 */

public with sharing class GraceDialougeYesNo {
    public class Input{
        @InvocableVariable(required=true)
        public String selectedMenu;
        @InvocableVariable(required=true)
        public String associateResponse;
    }
    public class Output{
        @InvocableVariable(required=true)
        public String topicName;
        @InvocableVariable(required=true)
        public String dialougeName;
        @InvocableVariable(required=true)
        public String description;
        @InvocableVariable(required=true)
        public String dialougueYesNo;
    
    }

    @InvocableMethod(label='GRACE - Get CCS Yes/No Dialougue')
    public static List<Output> getCCSDefination(List<Input> input){
        String selectedMenu = input[0].selectedMenu;
        String response = input[0].associateResponse;
        List<Output> output = new List<Output>();

        try {
            Grace_CCS_Def__mdt	ccs = [Select Topic_Name__c, Selected_Menu_Option__c, Description__c, Dialogue_Name__c, Dialogue_YES__c, Dialogue_NO__c from Grace_CCS_Def__mdt where Selected_Menu_Option__c =: selectedMenu ];
            Output obj = new Output();
            obj.topicName =  String.valueOf(ccs.Topic_Name__c);
            obj.dialougeName = String.valueOf(ccs.Dialogue_Name__c);
            obj.description = String.valueOf(ccs.Description__c);
    
                if(response == 'Yes'){
                    obj.dialougueYesNo = String.valueOf(ccs.Dialogue_YES__c);
                }
                else if (response == 'No'){
                    obj.dialougueYesNo = String.valueOf(ccs.Dialogue_NO__c);
                }
            output.add(obj);

        } catch (Exception e) {
            Logger.error('GraceCCSDef :: ' + e.getMessage());
        }
        return output;
    }
}