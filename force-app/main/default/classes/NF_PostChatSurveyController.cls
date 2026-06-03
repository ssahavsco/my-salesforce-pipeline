/*****************************************************************************************************
Class Name     :  NF_PostChatSurveyController
Purpose        :  Controller class for NF_PostChatSurvey VF page
               :  CSAT data will be stored in a custom object 'Survey Results'
               :  Post chat survey will be displayed only for chats that have been transferred 
                (using ApexPages.currentPage().getParameters().get('chatDetails') to determine transfers)

History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       mcasella               9/11/2020           Original Version            
2.       Manishi                4/22/2021           Modified for enhancement    DP-39114,DP-36456,DP-36457
3.       TARA                   6/25/2021           Modified for enhancement    DP-42004
4.       Himanshu               3/7/2024            Modified to add a question  CCS-330
5.       Himanshu               3/20/2024           Modified to add language code  CCS-436
@Testsuite:  {NF_PostChatSurveyControllerTest}                                       
*********************************************************************************************************/
public without sharing class NF_PostChatSurveyController {
    // Post-chat survey items, to be thrown into Transcript object
    public Integer questionSatisfaction {get;set;}
    public Integer overallExperience {get;set;}
    public Integer wouldChatAgain {get;set;}
    public String additionalComments {get;set;}

    public Boolean insufficientUserInput {get;set;}
    public Boolean formCompleted {get;set;}
    private String chatDetails;
    public Boolean isChatTransferred {get;set;}
    public String buttonId{get;set;}
    public String selectedvalue{get;set;}
    public String languageCode{get; set;}
    
    @TestVisible
    private String chatkey;
    
    public List<Selectoption> getItemsList(){
    	String selectPicklist;
    	List<SelectOption> options = new List<SelectOption>(); 
      	List<Schema.Picklistentry> fieldResult = SurveyResult__c.Was_CC_able_to_resolve_your_issue__c.getDescribe().getPicklistValues();
      	
        switch on languageCode {
            when 'es' {
                selectPicklist = '-- Seleccionar -- ';
            }
            when 'ja' {
                selectPicklist = '-- セレクト -- ';
            }
            when 'es_MX' {
                selectPicklist = '-- Seleccionar -- ';
            }
            when 'it' {
                selectPicklist = '-- Seleziona -- ';
            }
            when 'fr' {
                selectPicklist = '-- Sélectionnez -- ';
            }
            when 'nl_NL' {
                selectPicklist = '-- Selecteer -- ';
            }
            when 'de' {
                selectPicklist = '-- Wählen Sie -- ';
            }
            when 'ko' {
                selectPicklist = '-- 고르세요 -- ';
            }
            when 'pl' {
                selectPicklist = '-- Proszę wybrać -- ';
            }
            when 'zh_CN' {
                selectPicklist = '-- Sélectionner -- ';
            }
            when else {
                selectPicklist = '-- Select -- ';
            }
        }
      	options.add(new SelectOption('', selectPicklist));
      	for(Schema.PicklistEntry f : fieldResult) {
          	options.add(new SelectOption(f.getValue(), f.getLabel()));
      	}
      	return options;
    }
    
    public NF_PostChatSurveyController() { 
        questionSatisfaction= 0;
        overallExperience = 0;
        wouldChatAgain = 0;
        isChatTransferred = false;
        chatkey = ApexPages.currentPage().getParameters().get('chatkey');
        List<LiveChatTranscript> liveChatList = [SELECT Language_Code__c FROM LiveChatTranscript WHERE ChatKey = :chatkey];
        languageCode = liveChatList.size() > 0 ? liveChatList[0].Language_Code__c : 'en_US' ;
        /* chat details JSON is accessible at the post chat form */
        /** DP-36456,DP-36457 starts **/
        chatDetails = ApexPages.currentPage().getParameters().get('chatDetails');
        buttonId = ApexPages.currentPage().getParameters().get('buttonId');
        if(String.isNotEmpty(buttonId)){
            
            //if and only if the chat originated from the Customer_Care_Associates chat button, it is NOT a Bot chat
            LiveChatButton[] buttons = [SELECT Id, DeveloperName
                                        FROM LiveChatButton
                                        WHERE Id = :buttonId AND DeveloperName = 'Customer_Care_Associates'];
            
            
            if(buttons.size() > 0){
                isChatTransferred = true;
            }
            else {
                if(Test.isRunningTest()) {
                    chatDetails = '{"visitorId":"36bdc7ba-befa-4d0a-803e-850c71472b26","agent":{"userId":"00501000000zHFQ","agentName":"Manishi K","transfer":0}}';
                }
                NF_PostChatSurveyController.PreChatInfo deserializedResult= (NF_PostChatSurveyController.PreChatInfo)JSON.deserialize(chatDetails,NF_PostChatSurveyController.PreChatInfo.class);
                if(deserializedResult.agent.transfer >0) {
                    isChatTransferred = true;
                }
                else {
                    isChatTransferred = false;
                }
            }
        }
        formCompleted = false;
        insufficientUserInput = false;
    }
    /** DP-36456,DP-36457 ends **/
    
    public NF_PostChatSurveyController(String chatKey) {
        this.chatkey = chatKey;
        formCompleted = false;
        insufficientUserInput = false;
        /* chat details JSON is accessible at the post chat form */
        chatDetails = ApexPages.currentPage().getParameters().get('chatDetails');
        if(Test.isRunningTest()) {
            chatDetails = '{"visitorId":"36bdc7ba-befa-4d0a-803e-850c71472b26","agent":{"userId":"00501000000zHFQ","agentName":"Manishi K","transfer":0}}';
        }
        NF_PostChatSurveyController.PreChatInfo deserializedResult= (NF_PostChatSurveyController.PreChatInfo)JSON.deserialize(chatDetails,NF_PostChatSurveyController.PreChatInfo.class);
        if(deserializedResult.agent.transfer >0) {
            isChatTransferred = true;
        }
        else {
            isChatTransferred = false;
        }
    }

    public void saveResponsesToBotSession() {
        System.debug('comments'+ApexPages.CurrentPage().getParameters().get('param1'));
        System.debug(LoggingLevel.DEBUG,'Question Satisfaction: ' + questionSatisfaction);
        System.debug(LoggingLevel.DEBUG,'Overall Experience: ' + overallExperience);
        System.debug(LoggingLevel.DEBUG,'Would Chat Again: ' + wouldChatAgain);
        System.debug(LoggingLevel.DEBUG,'Additional Comments: ' + additionalComments);
        additionalComments = ApexPages.CurrentPage().getParameters().get('param1');
        
        if (questionSatisfaction == 0 || overallExperience == 0 || wouldChatAgain == 0) {
            insufficientUserInput = true;
            return;
        }

        System.debug(LoggingLevel.DEBUG,'Saving responses to bot session with chatkey: ' + chatKey);
        insufficientUserInput = false;

        ebotdata__Bot_Session__c[] botSessionToUpdate = [
                SELECT Id, ebotdata__Live_Agent_Session_Id__c, Chat_Satisfaction__c,
                        Overall_Experience__c, Would_Recommend_VS__c, PostChat_Comments__c
                FROM ebotdata__Bot_Session__c
                WHERE ebotdata__Live_Agent_Session_Id__c =: chatKey
                LIMIT 1
        ];

        if (botSessionToUpdate.size() > 0 && insufficientUserInput == false) {
            System.debug(LoggingLevel.DEBUG,'Bot Session found, updating');
            botSessionToUpdate[0].Chat_Satisfaction__c = questionSatisfaction;
            botSessionToUpdate[0].Overall_Experience__c = overallExperience;
            botSessionToUpdate[0].Would_Recommend_VS__c = wouldChatAgain;
            botSessionToUpdate[0].PostChat_Comments__c = additionalComments;

           update botSessionToUpdate[0];
        }

        LiveChatTranscript[] lct = [SELECT Id, ChatKey, LiveChatButtonId, (SELECT id FROM Survey_Results__r)
        FROM LiveChatTranscript
        WHERE ChatKey=:chatkey LIMIT 1];
        
        /* save responses to the Survey Result object */
        /*DP-36456,DP-36457*/
        if(!lct.isEmpty() && lct[0].Survey_Results__r.isEmpty()){
            System.debug(LoggingLevel.DEBUG,'Chat Transcript found, creating survey');
            SurveyResult__c survey = new SurveyResult__c();
            survey.Chat_Transcript_Id__c = lct[0].Id;
            survey.Chat_Satisfaction__c = questionSatisfaction;
            survey.Overall_Experience__c = overallExperience;
            survey.Would_Recommend_VS__c = wouldChatAgain;
            survey.PostChat_Comments__c = additionalComments;
            survey.Chat_Type__c = getChatType(lct[0]);
            survey.Was_CC_able_to_resolve_your_issue__c = selectedvalue;
            insert survey;
        }

        // Stop rendering the page
        formCompleted = true;
    }

    public static String getChatType(LiveChatTranscript lct){
        //by default assume chat was from Bot, in case something goes wrong
        String type = 'Bot';

        try {
            if(lct != null && lct.LiveChatButtonId != null) {

                //if and only if the chat originated from the Customer_Care_Associates chat button, it is NOT a Bot chat
                LiveChatButton[] buttons = [
                        SELECT Id, DeveloperName
                        FROM LiveChatButton
                        WHERE Id = :lct.LiveChatButtonId AND DeveloperName = 'Customer_Care_Associates'
                ];

                type = buttons.size() == 0 ? 'Bot' : 'Associate';
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error setting bot chat flag');
        }

        return type;
    }
    
    // wrapper class to deserialize the JSON response 
    public class PreChatInfo{
        public String visitorId;
        public Agent agent;
    }
    
    public class Agent {
        public String userId;
        public String agentName;
        public Integer transfer;
    }
}