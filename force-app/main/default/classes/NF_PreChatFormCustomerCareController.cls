/*****************************************************************************************************@@
Class Name     :  NF_PreChatFormCustomerCareController
Purpose        :  Controller class for NF_CustomerCare_PreChatForm component
			   : used to check the agent availability and business hours at pre-chat form.
			   : creates Direct_Live_Chat_Unavailable_Request__c object to track chat turned away from live chat.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       mcasella               9/11/2020           Original Version            
2.		 Tara  					4/22/2021			Modified for enhancement	DP-39114, DP-40210
@Testsuite:  {NF_ConsoleEventsHandlerControllerTest}                                       
*********************************************************************************************************/

public without sharing class NF_PreChatFormCustomerCareController {
    @AuraEnabled
    public static returnWrapper checkAgentAvailable(String userEmail, String pageUrl){
        // metadata check
        Einstein_Bot_Dialog_Configuration__mdt[] configs = [SELECT Label, Live_Chat_Available__c,Display_Custom_Messsage__c FROM Einstein_Bot_Dialog_Configuration__mdt WHERE Label = 'Customer Care' LIMIT 1];
		returnWrapper returnWrap = new returnWrapper();
        returnWrap.showCustomMessage = 'false';
        //only disable chat if we find a valid config, otherwise check availablity
        if(configs.size() > 0 && configs[0].Display_Custom_Messsage__c == true){
            returnWrap.showCustomMessage = 'true';
            returnWrap.customMessage = System.Label.NF_ChatNotAvailable;
        }
        Boolean isConnectedToChat;
        String reasonToUnconnect;
        /* check business hours */
        List<NF_CheckBussinessHoursChatAvailability.Input> BhInputs = new List<NF_CheckBussinessHoursChatAvailability.Input>();
        NF_CheckBussinessHoursChatAvailability.Input inpB = new NF_CheckBussinessHoursChatAvailability.Input();
        inpB.chatKey = '';
        BhInputs.add(inpB);
        List<NF_CheckBussinessHoursChatAvailability.Output> outBH = NF_CheckBussinessHoursChatAvailability.getBussinessHoursChatToggle(BhInputs);
        isConnectedToChat = outBH[0].isWithinBusinessHoursOn;
        
        if(!isConnectedToChat){
            reasonToUnconnect =  'Closed';
        }

        if(isConnectedToChat){

            // agent available check
            List<NF_AgentAvailabilityCheck.Input> inputs = new List<NF_AgentAvailabilityCheck.Input>();
            NF_AgentAvailabilityCheck.Input inp = new NF_AgentAvailabilityCheck.Input();
            inp.sChatButtonDeveloperName = 'Customer_Care_Associates';
            inp.sChatDeploymentDeveloperName = 'Customer_Care';
            inputs.add(inp);
            List<NF_AgentAvailabilityCheck.Output> out = NF_AgentAvailabilityCheck.checkAgentAvailability(inputs);

            isConnectedToChat = out[0].bAgentAvailability;
            reasonToUnconnect =  'Unavailable';
        }

        /** DP-39114 starts **/
		/** Create record of Live Chats Turned Away if chat not started starts **/
        if(!isConnectedToChat){
            Direct_Live_Chat_Unavailable_Request__c liveChatNotStarted = new Direct_Live_Chat_Unavailable_Request__c ();
            liveChatNotStarted.Email__c = userEmail;
            liveChatNotStarted.Reason__c = reasonToUnconnect;
            liveChatNotStarted.Page_Url__c = pageUrl;
            insert liveCHatNotStarted;
        }
        /** DP-39114 end **/
        
        if(isConnectedToChat){
            returnWrap.isConnectToChat = 'true';
        }else{returnWrap.isConnectToChat = 'false';} 
        
        return returnWrap;
    }

    //method added by Rishabh to check or create Contact and map it to transcript id
    @AuraEnabled
    public static ResponseWrapper checkContact(String firstName, String lastName, String email){
        System.debug('inside chechContact');
        System.debug('firstName'+firstName);
        System.debug('lastName'+lastName);
        System.debug('email'+email);
        ResponseWrapper resp = new ResponseWrapper();
        try {
            resp.status=true;
            resp.errormessage='';
            resp.data='';
            String fullName = firstName+' '+lastName;
            Boolean cidPresent = false;
            List<Contact> conList = [SELECT Id,
                                            Account.CID__c,
                                            AccountId 
                                            FROM Contact 
                                            WHERE Name=:fullName 
                                            AND Email=:email 
                                            ORDER BY Account.LastModifiedDate DESC] ;
            if(conList.size()>1){
                for(Contact con : conList){
                    if(con.AccountId!=null && con.Account.CID__c !=null){
                        cidPresent=true;
                        resp.data=con.Id;
                        break;
                    }
                }
                if(!cidPresent){
                    resp.data=conList[0].Id;
                }
            }
            
        } catch (Exception e) {
            resp.status=false;
            resp.data='';
            resp.errormessage=e.getMessage();
        }
        return resp;
    }
    
    public class returnWrapper{
        @AuraEnabled public string showCustomMessage;
        @AuraEnabled public string isConnectToChat;
        @AuraEnabled public string customMessage;
    }
}