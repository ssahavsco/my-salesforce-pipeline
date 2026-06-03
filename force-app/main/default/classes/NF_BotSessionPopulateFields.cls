/**
 * Created by mcasella on 9/21/20.
 */

public with sharing class NF_BotSessionPopulateFields {

    //public static void updateFields(Map<Id, ebotdata__Bot_Session__c> botSessions){
    public static void updateFields(List<ebotdata__Bot_Session__c> botSessions){
        try {
            Set<Id> liveChatTranscriptIds = new Set<Id>();
            Map<Id, LiveChatTranscript> transcripts = new Map<Id, LiveChatTranscript>();

            //For all sessions, get the corresponding transcript
            for(ebotdata__Bot_Session__c session : botSessions){
                //System.debug(LoggingLevel.DEBUG,'>>NF_BotSessionPopulateFields.updateFields: session=' + session);
                liveChatTranscriptIds.add(session.ebotdata__Live_Chat_Transcript__c);
            }

            //Retrieve all the transcripts
            transcripts = new Map<Id, LiveChatTranscript>([SELECT Id, ChatKey, Page_URL__c, JWT_Token__c
                                                           FROM LiveChatTranscript
                                                           WHERE Id IN :liveChatTranscriptIds]);
            //System.debug(LoggingLevel.DEBUG,'>>NF_BotSessionPopulateFields.updateFields: transcripts=' + transcripts);

            //Go through the sessions again, and update with the corresponding transcript fields
            for(ebotdata__Bot_Session__c session : botSessions){
                //System.debug(LoggingLevel.DEBUG,'>>NF_BotSessionPopulateFields.updateFields: session=' + session);
                if (session.ebotdata__Live_Chat_Transcript__c != null) {
                    LiveChatTranscript transcript = transcripts.get(session.ebotdata__Live_Chat_Transcript__c);

                    if (session != null && transcript != null && String.isNotEmpty(transcript.Page_URL__c)) {
                        session.ebotdata__Chat_Page__c = transcript.Page_URL__c;
                    }
                }
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR,'>>NF_BotSessionPopulateFields.updateFields: Exception=' + e.getMessage());
        }
    }
}