/*****************************************************************************************************
Class Name     :  VSCCS_PostChatSurveyController
Purpose        :  Controller class for VSCCS_PostChatSurvey VF page
               :  CSAT data will be stored in a custom object 'Survey Results'
               :  Post chat survey will be displayed only for chats that have been transferred 

History:
-------
VERSION  AUTHOR                 DATE                 DETAIL                      TICKET REFERENCE/ NO.
1.       Himanshu Mishra        03/21/2025           Original Version      		 MIAW Migration
@Testsuite:  {VSCCS_PostChatSurveyControllerTest}                                       
*********************************************************************************************************/
public without sharing class VSCCS_PostChatSurveyController {
  // Post-chat survey items, to be thrown into Transcript object
  public Integer questionSatisfaction { get; set; }
  public Integer overallExperience { get; set; }
  public Integer wouldChatAgain { get; set; }
  public String additionalComments { get; set; }

  public Boolean insufficientUserInput { get; set; }
  public Boolean formCompleted { get; set; }
  public Boolean isChatTransferred { get; set; }
  public String selectedvalue { get; set; }
  public String languageCode { get; set; }

  @TestVisible
  private String routableId;

  public List<Selectoption> getItemsList() {
    String selectPicklist;
    List<SelectOption> options = new List<SelectOption>();
    List<Schema.Picklistentry> fieldResult = SurveyResult__c.Was_CC_able_to_resolve_your_issue__c.getDescribe()
      .getPicklistValues();

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
    for (Schema.PicklistEntry f : fieldResult) {
      options.add(new SelectOption(f.getValue(), f.getLabel()));
    }
    return options;
  }

  public VSCCS_PostChatSurveyController() {
    questionSatisfaction = 0;
    overallExperience = 0;
    wouldChatAgain = 0;
    isChatTransferred = false;

    routableId = ApexPages.currentPage().getParameters().get('routableId');
    MessagingSession[] msgSession = [
      SELECT Language_Code__c, AgentType, Customer_Inactivity_End_Time__c
      FROM MessagingSession
      WHERE Id = :routableId
    ];
    languageCode = msgSession.size() > 0
      ? msgSession[0].Language_Code__c
      : 'en_US';

    if (
      msgSession.size() > 0 &&
      msgSession[0].AgentType != 'Bot' &&
      msgSession[0].Customer_Inactivity_End_Time__c == null
    ) {
      isChatTransferred = true;
    } else {
      isChatTransferred = false;
    }
    logger.info(
      'Msg Session ' + msgSession + ' isChatTransferred ' + isChatTransferred
    );
    logger.saveLog();
    formCompleted = false;
    insufficientUserInput = false;
  }

  public VSCCS_PostChatSurveyController(String routableId) {
    this.routableId = routableId;
    formCompleted = false;
    insufficientUserInput = false;
    MessagingSession[] msgSession = [
      SELECT Language_Code__c, AgentType, Customer_Inactivity_End_Time__c
      FROM MessagingSession
      WHERE Id = :routableId
    ];
    if (
      msgSession.size() > 0 &&
      msgSession[0].AgentType != 'Bot' &&
      msgSession[0].Customer_Inactivity_End_Time__c == null
    ) {
      isChatTransferred = true;
    } else {
      isChatTransferred = false;
    }
    logger.info(
      'Msg Session2 ' + msgSession + ' isChatTransferred ' + isChatTransferred
    );
    logger.saveLog();
  }

  public void saveResponsesToMessagingInsight() {
    logger.info(
      'comments' + ApexPages.CurrentPage().getParameters().get('param1')
    );
    logger.info('Question Satisfaction: ' + questionSatisfaction);
    logger.info('Overall Experience: ' + overallExperience);
    logger.info('Would Chat Again: ' + wouldChatAgain);
    logger.info('Additional Comments: ' + additionalComments);
    additionalComments = ApexPages.CurrentPage().getParameters().get('param1');

    if (
      questionSatisfaction == 0 ||
      overallExperience == 0 ||
      wouldChatAgain == 0
    ) {
      insufficientUserInput = true;
      return;
    }

    logger.info(
      'Saving responses to Messaging Insight with routableId : ' + routableId
    );
    insufficientUserInput = false;

    Messaging_Insight__c[] insightToUpdate = [
      SELECT
        Id,
        Messaging_Session__c,
        Chat_Satisfaction__c,
        Overall_Experience__c,
        Would_Recommend_VS__c,
        PostChat_Comments__c,
        Was_CC_able_to_resolve_your_issue__c
      FROM Messaging_Insight__c
      WHERE Messaging_Session__c = :routableId
      LIMIT 1
    ];

    if (insightToUpdate.size() > 0 && insufficientUserInput == false) {
      logger.info('Messaging Insight found, updating');
      insightToUpdate[0].Chat_Satisfaction__c = questionSatisfaction;
      insightToUpdate[0].Overall_Experience__c = overallExperience;
      insightToUpdate[0].Would_Recommend_VS__c = wouldChatAgain;
      insightToUpdate[0].PostChat_Comments__c = additionalComments;
      insightToUpdate[0].Was_CC_able_to_resolve_your_issue__c = selectedvalue;

      update insightToUpdate[0];
    }

    MessagingSession[] msgSession = [
      SELECT Id, AgentType, (SELECT id FROM Survey_Results__r)
      FROM MessagingSession
      WHERE Id = :routableId
      LIMIT 1
    ];

    /* save responses to the Survey Result object */
    if (!msgSession.isEmpty() && msgSession[0].Survey_Results__r.isEmpty()) {
      logger.info('Messaging Session found, creating survey');
      SurveyResult__c survey = new SurveyResult__c();
      survey.Messaging_Session__c = msgSession[0].Id;
      survey.Chat_Satisfaction__c = questionSatisfaction;
      survey.Overall_Experience__c = overallExperience;
      survey.Would_Recommend_VS__c = wouldChatAgain;
      survey.PostChat_Comments__c = additionalComments;
      survey.Chat_Type__c = msgSession[0].AgentType == 'Bot'
        ? 'Bot'
        : 'Associate';
      survey.Was_CC_able_to_resolve_your_issue__c = selectedvalue;
      insert survey;
    }
    logger.saveLog();
    // Stop rendering the page
    formCompleted = true;
  }
}