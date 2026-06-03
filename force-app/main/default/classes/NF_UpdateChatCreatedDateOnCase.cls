global class NF_UpdateChatCreatedDateOnCase implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,CaseId from LiveChatTranscript WHERE caseId!=null and case.Offer_Code__c !=null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<LiveChatTranscript> liveChatList){
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> cList = new List<Case>();
        for (LiveChatTranscript chat : liveChatList){
            if (chat.CaseId != null){
                caseIdSet.add(chat.CaseId);
            }
        }
        if (!caseIdSet.isEmpty()){
            List<Case> caseList = [SELECT Id, Chat_Created_Date__c, VOC_Comments__c, (SELECT Id, CreatedDate
                                                                                      FROM LiveChatTranscripts
                                                                                      Order by CreatedDate
                                                                                      LIMIT 1)
                                   FROM Case
                                   WHERE Id IN:caseIdSet];
            if (!caseList.isEmpty()){
                for (Case c : caseList){
                    if (c.VOC_Comments__c != null){
                        for (LiveChatTranscript lv : c.LiveChatTranscripts){
                            c.Chat_Created_Date__c = Date.valueOf(lv.CreatedDate);
                        }
                        cList.add(c);
                    }
                }
            }
        }
        if (!cList.isEmpty()){
            update cList;
        }
    }

    global void finish(Database.BatchableContext BC){
    }

}