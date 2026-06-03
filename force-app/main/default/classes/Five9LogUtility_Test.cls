// Modified By: Sumit Saha ~ 02-27-2023

@IsTest
public with sharing class Five9LogUtility_Test {
    
    @isTest
    static void checkContactTest(){
        
        LB_Script_Settings__c  CustomSetting = new LB_Script_Settings__c();         
        CustomSetting.Name = 'Five9 Settings';        
        CustomSetting.Flow_Apex_Debug__c = true;       
        insert CustomSetting;
         
        List<Five9LogUtility.FlowRequestWrapper> inputWrpLst = new List<Five9LogUtility.FlowRequestWrapper>();
         Five9LogUtility.FlowRequestWrapper inputWrp = new Five9LogUtility.FlowRequestWrapper();
        inputWrp.ANI = '+16142862730';
        inputWrp.caseId = '500M000000DeBQzIAN';
        inputWrp.caserecord_type = 'Digital_Phone';
        inputWrp.intent_name = 'intent_name';
        inputWrp.skillName = 'UAT_VSD_BOPIS_pri';
        inputWrp.sessionId = '1C11C2377B8141638274580025A1860C';
        inputWrp.callType = 'inbound';
        inputWrp.dnis = '+18552310300';
        inputWrp.contactId = '003M000001I1lwhIAB';
        inputWrp.order_number = 'W123456789';
         
        inputWrpLst.add(inputWrp); 
        Five9LogUtility.setLogger(inputWrpLst);
    }
    
}