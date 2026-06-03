/****************************************************************************************************************
* Program Name         : NF_ChatTranscriptDataFixBatch
* Description          : Batch Class for live chat transcripts to populate Actual_Tab_Close_Time__c field.
* Version              : 1.1
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   _          		DP-51067      1.1       Manishi      23 Dec,2021       Batch Class for live chat transcripts to populate
																			Actual_Tab_Close_Time__c field.
	-				DP-51067	  1.2		Manishi		14 Jan,2022			Fix to change the where condition.
    _				DP-65478	  1.3		Himanshu	29 March,2023		Fix to update the Custom chat end time
    _				DP-91108	  1.4		Himanshu	21 April,2025		Replace LiveChatTranscript with MessagingSession
*     
*****************************************************************************************************************/
public without sharing class NF_ChatTranscriptDataFixBatch implements Database.Batchable<SObject> {
  private String query = 'Select Id, Custom_Chat_End_Time__c, Actual_Tab_Close_Time__c, StartTime FROM MessagingSession WHERE Actual_Tab_Close_Time__c = NULL AND StartTime <= :todays AND StartTime >= :twoDaysAgo';
  private Integer numHrs;

  public NF_ChatTranscriptDataFixBatch() {
    numHrs = 1;
  }

  public NF_ChatTranscriptDataFixBatch(String queryString) {
    query = queryString;
    numHrs = 0;
  }

  public NF_ChatTranscriptDataFixBatch(Integer numberOfHoursBefore) {
    numHrs = numberOfHoursBefore;
  }

  public NF_ChatTranscriptDataFixBatch(
    String queryString,
    Integer numberOfHoursBefore
  ) {
    numHrs = numberOfHoursBefore;
    query = queryString;
  }

  // start method
  public Database.QueryLocator start(Database.BatchableContext bc) {
    DateTime todays = System.Now().addDays(-1);
    DateTime twoDaysAgo = System.Now().addDays(-3);
    return Database.getQueryLocator(query);
  }

  //execute method
  public void execute(Database.BatchableContext bc, List<sObject> scope) {
    try {
        for(SObject record : scope){
      	  MessagingSession msgSession = (MessagingSession) record;
          if (msgSession.Custom_Chat_End_Time__c == null) {
            msgSession.Custom_Chat_End_Time__c = msgSession.StartTime.addHours(
              numHrs
            );
          }
          msgSession.Actual_Tab_Close_Time__c = msgSession.Custom_Chat_End_Time__c.addHours(
            numHrs
          );
        }
        // Add more instanceof blocks for other object types if needed
      Database.update(scope, false);
    } catch (Exception e) {
      System.debug('Exception caught>>>' + e.getStackTraceString());
    }
  }

  //do nothing in finish
  public void finish(Database.BatchableContext BC) {
  }
}