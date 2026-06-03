/***************************************************************
Interface Name : LB_PostCaseSurveyController
CreatedDate : 01-MAY-21
Description :  
Created By : Sumit Saha

Revision History

Date Name Story Number Description
* TODO: 05/01/2021 Sumit S |     |  DP-xxxxx  - Custom Controller for Case close survey
* TODO: 07/08/2021 Pooja S |LK-01|  DP-44716  - Default survey to 0 on page loaf
* TODo: 03/07/2024 Himanshu |    |  CCS-330   - Added a new question
***************************************************************/


public class LB_PostCaseSurveyController {
    
    // Post-chat survey items, to be thrown into Transcript object
    public Integer questionSatisfaction {get;set;}
    public Integer overallExperience {get;set;}
    public Integer wouldChatAgain {get;set;}
    public String additionalComments {get;set;}
    
    private String chatDetails;
    public Boolean isChatTransferred {get;set;}
    public String buttonId{get;set;}
    public String selectedvalue{get;set;}
    
    public Boolean insufficientUserInput {get;set;}
    public Boolean formCompleted {get;set;}
    
    private String caseId;
    
    public LB_PostCaseSurveyController() {
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        formCompleted = false;
        insufficientUserInput = false;
        //DP-44716- LK-01
        questionSatisfaction = 5;
        overallExperience = 5;
        wouldChatAgain = 5;
        //LK-01
        // isChatTransferred = true;
    }
    
    public LB_PostCaseSurveyController(String caseId) {
        this.caseId = caseId;
        formCompleted = false;
        insufficientUserInput = false;
    }
    
    public List<Selectoption> getItemsList(){
      List<SelectOption> options = new List<SelectOption>(); 
      List<Schema.Picklistentry> fieldResult = SurveyResult__c.Was_CC_able_to_resolve_your_issue__c.getDescribe().getPicklistValues();
      options.add(new SelectOption('Select', '-- Select -- '));
      for(Schema.PicklistEntry f : fieldResult) {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
      }
      return options;
    }
    
    public void saveResponsesToBotSession() {
        
       
        Map<string,List<Case> > caseDetails = new Map<string,List<Case> >{'CaseDetails' => [Select Id, Owner.Username from case where Id =: caseId]};
        List<AggregateResult>  countOfSurvey =  [SELECT count(Id) FROM SurveyResult__c where Case__c =: caseId];
        
        System.debug(LoggingLevel.DEBUG,'Count:  '  + countOfSurvey[0].get('expr0'));
        System.debug(LoggingLevel.DEBUG,'If Case exists:  '  + caseDetails.get('CaseDetails'));        
        System.debug(LoggingLevel.DEBUG,'Question Satisfaction: ' + questionSatisfaction);
        System.debug(LoggingLevel.DEBUG,'Overall Experience: ' + overallExperience);
        System.debug(LoggingLevel.DEBUG,'Would Chat Again: ' + wouldChatAgain);
        System.debug(LoggingLevel.DEBUG,'Additional Comments: ' + additionalComments);
        System.debug(LoggingLevel.DEBUG,'Items ' + selectedvalue);
        
        if (questionSatisfaction == null || overallExperience == null || wouldChatAgain == null || questionSatisfaction == 0 || overallExperience == 0 || wouldChatAgain == 0 || selectedvalue == 'Select') {
            insufficientUserInput = true;
            return;
        }
        
        insufficientUserInput = false;
        
        if(!caseDetails.get('CaseDetails').isEmpty())
        {
            if((Integer) countOfSurvey[0].get('expr0') == 0 && insufficientUserInput == false)
            {
                SurveyResult__c survey  = new SurveyResult__c();
                survey.Chat_Satisfaction__c = questionSatisfaction;
                survey.Overall_Experience__c = overallExperience;
                survey.Would_Recommend_VS__c = wouldChatAgain;
                survey.PostChat_Comments__c = additionalComments;
                survey.Chat_Type__c  = null;
                survey.Case__c = caseId;
                survey.OwnerId = (ID) caseDetails.get('CaseDetails')[0].get('OwnerId');
                survey.Was_CC_able_to_resolve_your_issue__c = selectedvalue;
                
                insert survey;                
            }
            
        }
        else{
            return;
        }
        
        // Stop rendering the page
        formCompleted = true;
    }
}