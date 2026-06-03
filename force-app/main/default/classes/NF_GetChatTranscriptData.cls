public with sharing class NF_GetChatTranscriptData {

    @AuraEnabled
    public static List<LiveChatTranscript> getChatTranscriptData(String recordId){
        return [SELECT Id, Body FROM LiveChatTranscript WHERE Id = :recordId];
    }
}