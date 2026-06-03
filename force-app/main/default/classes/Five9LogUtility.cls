/***************************************************************
Interface Name : Five9LogUtility
CreatedDate : 09/16/2022
Description :  
Created By : Pooja Korrapati
Modified By: Sumit Saha ~ 02-27-2023

Revision History

Date Name Story Number Description
  
***************************************************************/
public class Five9LogUtility 
{
  @InvocableMethod(callout=true label='Logger for Five9')    
     public static void setLogger ( List<FlowRequestWrapper> flowInputs ){
         system.debug(flowInputs);
         Boolean isFlowDebug  = False;
         if(LB_Script_Settings__c.getAll().containsKey('Five9 Settings') == true){
            isFlowDebug = LB_Script_Settings__c.getValues('Five9 Settings').Flow_Apex_Debug__c;
         } 
         
         if(isFlowDebug){
             String message =  'caserecord_type = '+
                 flowInputs[0].caserecord_type +'; intent_name = '+
                 flowInputs[0].intent_name +'; skillName = '+
                 flowInputs[0].skillName +'; Five9 Session ID = '+
                 flowInputs[0].sessionId +'; callType = '+
                 flowInputs[0].callType +'; dnis = '+
                 flowInputs[0].dnis +'; contactId = '+
                 flowInputs[0].contactId + '; order_number = ' +
                 flowInputs[0].order_number	;	
             Logger__c logRec = new Logger__c();
             logRec.Log_Type__c = 'Process Log';
             logRec.Class_Name__c = 'Five9LogUtility';
             logRec.Record_Id__c =   flowInputs[0].caseId;
             logRec.External_Id__c = flowInputs[0].ANI ;
             logRec.Source_Method__c = 'setLogger';
             logRec.Message__c = message;
             insert logRec;          
         }
         
     }
    
    //Input Variables Wrapper
    public class FlowRequestWrapper{
        @InvocableVariable(label = 'ANI')
        public String ANI;
        
        @InvocableVariable(label = 'caseId')
        public String caseId;
        
        @InvocableVariable(label = 'contactId')
        public String contactId;
        
        @InvocableVariable(label = 'dnis')
        public String dnis;
        
        @InvocableVariable(label = 'callType')
        public String callType;
        
        @InvocableVariable(label = 'sessionId')
        public String sessionId;
        
        @InvocableVariable(label = 'skillName')
        public String skillName;
        
        @InvocableVariable(label = 'intent_name')
        public String intent_name ;
        
        @InvocableVariable(label = 'caserecord_type')
        public String caserecord_type;
        
        @InvocableVariable(label = 'order_number')
        public String order_number;
        
         
    } 
}