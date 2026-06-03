/*
***********************************************************************************************************
* Program Name      : NF_GetHoldPaymentResponse
* Description       : returns metadata record for the given holdType
* Version           : 1.1
* Creation Log  	: 25-08-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-39921    1.1         Ravikant Kedia      25-08-2021      returns metadata record for the given holdType.
* REQ_02            CCS-622     1.2         Himanshu Mishra     02-09-2024      Updated code to fetch chatbot message by passing language code
***********************************************************************************************************
*/
public with sharing class NF_GetHoldPaymentResponse {

    @TestVisible
    private static List<Hold_Payment_Status_Responses__mdt> hpsrMDTList{
        get{
            if( hpsrMDTList == null ){
                hpsrMDTList = Hold_Payment_Status_Responses__mdt.getAll().values();
            }
            return hpsrMDTList;
        }
        set;
        
        
    }
    
    //method will return the metadata record (includes Message for Associate and message to display on chatbot) based on the hold type. 
    @InvocableMethod(Label ='Neuraflash - Get Hold Payment Response' description='Return MDT record for given holdType')
    public static List<ChatBotOutput> returnPaymentStatusResponse( List<ChatBotInput> holdTypeList ) {
        List<ChatBotOutput> cboList = new List<ChatBotOutput>();
        ChatBotOutput cbo = new ChatBotOutput();
        for( Hold_Payment_Status_Responses__mdt hpsrMDT : hpsrMDTList ){
            String holdTypeStr = holdTypeList[0].holdType+ '_' + holdTypeList[0].languageCode;
            if( hpsrMDT.Hold_Type__c == holdTypeStr ){
                cbo.holdTypeId                = hpsrMDT.Hold_Type_Id__c;
                if(String.isNotBlank(hpsrMDT.Hold_Payment_ChatBot_Responses__c)) {
                    if(!Test.isRunningTest()) {
                        //Hold_Payment_ChatBot_Responses__mdt hpcrMDT = Hold_Payment_ChatBot_Responses__mdt.getInstance(hpsrMDT.Hold_Payment_ChatBot_Responses__c);
                    	//cbo.chatBotResponseToCustomer = hpcrMDT.ChatBot_Response_To_Customer__c;
                        logger.info('Hold Type '+holdTypeStr);
                        String hold_Payment_Status_Response = hpsrMDT.Hold_Payment_ChatBot_Responses__c;
                        logger.info('hold_Payment_Status_Response '+hold_Payment_Status_Response);
                        Hold_Payment_ChatBot_Responses__mdt hpcrMDT = [Select ChatBot_Response_To_Customer__c From Hold_Payment_ChatBot_Responses__mdt where Id =: hold_Payment_Status_Response];
                    	cbo.chatBotResponseToCustomer = hpcrMDT.ChatBot_Response_To_Customer__c;
                    }
                    
                }
                logger.saveLog();
                cbo.messageForAssociate       = hpsrMDT.Message_for_Associate__c;
                cboList.add( cbo );
                break;
            }
        }
        return cboList;
    }

    // Wrpper class for Input
    public class ChatBotInput{
        @InvocableVariable(required=false) public String holdType;
        @InvocableVariable(required=false) public String languageCode;
    }

    // Wrpper class for Output
    public class ChatBotOutput{
        @InvocableVariable public Decimal holdTypeId;
        @InvocableVariable public String chatBotResponseToCustomer;
        @InvocableVariable public String messageForAssociate;
    }
}