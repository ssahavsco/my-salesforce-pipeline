/**************************************************************************************************************************
* Program Name         : VS_AdverseCaseToSAPPLM_API
* Description          : Invocable class to used in flow(Push_Adverse_Beauty_Data_to_SAP)
* Version              : 1.0
* Modification Log     : 04 September, 2024
*--------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*--------------------------------------------------------------------------------------------------------------------------
*  CCS-527       1.0       Himanshu Mishra       09/04/2024        Initial commit   
* 
***************************************************************************************************************************/

public class VS_AdverseCaseToSAPPLM_API {
    
    @InvocableMethod(label='Push Adverse Beauty Data to SAP' description='Push Adverse Beauty Data to SAP')
	public static List<FlowOutput> pushCaseToSAP(List<FlowInput> flowInputList)
    {
         return VS_AdverseCaseToSAPPLM_APIHandler.processRecords(flowInputList[0]);
    }
    
    public class FlowInput {
      	@InvocableVariable
        public String articleNo;
        @InvocableVariable
        public DateTime adverseEventDate;
        @InvocableVariable
        public String sfCaseNumber;
        @InvocableVariable
        public String eventType;
        @InvocableVariable
        public String beautyAdverseReactionSurvey;
        @InvocableVariable
        public String recordId;
    }
    public class FlowOutput{
      	@InvocableVariable
        public Integer apiResponseStatusCode;
        @InvocableVariable
        public Boolean isSuccess;
        @InvocableVariable
        public String errorMessage;
    }
}