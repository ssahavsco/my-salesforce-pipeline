/***********************************************************************************************************************
*Interface Name : HarassingNumberController
CreatedDate : 29-Apr-22
*? Description : A controller class to handle for automatic block based on ANI number 
*? Written By: Sumit Saha | ssaha@lb.com

*Revision History
Date Name Story Number Description
* * 03/10/2021 Sumit S | DP-55354 - Digital Phone: Associates have the ability to flag a contact as Harassing
************************************************************************************************************************/


public with sharing class HarassingNumberController {

    @InvocableMethod(label='Harassing number controller' description='Harassing number controller' category='Harassing')
    public static void creaateOrUpdateRecords(List<WrapperCaller> callRecord){
        
        System.debug(LoggingLevel.Debug, callRecord);

        Harassing_Number__c[] isAvailable = [SELECT Id, Count__c, Block_Type__c, Block__c, Allow_List__c from Harassing_Number__c where Phone__c  =: callRecord.get(0).phoneNumber ];

        Harassing_Number__c caller = new Harassing_Number__c();
            
            if(!isAvailable.isEmpty()){
                caller.Id = isAvailable[0].Id;
            }
            
            caller.Phone__c = callRecord.get(0).phoneNumber ;
            caller.Case_Number__c = callRecord.get(0).caseNumber ;
            caller.Comments__c = callRecord.get(0).userComments;
            caller.Count__c = isAvailable.isEmpty() ? 1 : isAvailable[0].Count__c + 1  ;
            caller.Block__c = caller.Count__c > 2 && isAvailable[0].Allow_List__c != true ? true : !isAvailable.isEmpty() ? isAvailable[0].Block__c : false;
            caller.Reason__c = callRecord.get(0).reason;
            caller.Block_Type__c = caller.Count__c > 2 && isAvailable[0].Allow_List__c != true && isAvailable[0].Block_Type__c == null ? 'Automatic' : !isAvailable.isEmpty() ? isAvailable[0].Block_Type__c : null;
            
        	try{
                upsert caller ;
            } catch(Exception e){
                System.debug(e.getMessage());
            }

    }
    
    public class WrapperCaller{

        @InvocableVariable(label='record for phone number' description='phone number' required=true)
        public String phoneNumber;

        @InvocableVariable(label='record for case number' description='case number' required=true)
        public String caseNumber;

        @InvocableVariable(label='record for associate comments' description='associate comments' required=false)
        public String userComments;

        @InvocableVariable(label='record for reason' description='reason' required=false)  
        public String reason;

    }
}