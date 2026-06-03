public class NF_UpdateCaseClass{
    public static void updateAgentHandleTime(){
        if (Trigger.isDelete) {
            // Skip execution for delete operations
            return;
        }
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        List<ebotdata__Bot_Session__c> botSessionList = Trigger.isInsert || Trigger.isUpdate ? Trigger.New  : Trigger.Old;

        for (AggregateResult ag : [SELECT ebotdata__Case__c, AVG(Agent_Chat_Handle_Time__c)avg
                                   FROM ebotdata__Bot_Session__c
                                   WHERE Id IN:botSessionList AND ebotdata__Case__c != null
                                   GROUP BY ebotdata__Case__c]){
            Case cs = new Case();
            cs.Id = (Id) ag.get('ebotdata__Case__c');
            cs.Average_Agent_Handle_Time__c = (Decimal) ag.get('avg');
            caseListToUpdate.add(cs);

        }

        if (!caseListToUpdate.isEmpty()){
            NF_CaseTriggerDomainHandler.TriggerDisabled = true;
            update caseListToUpdate;
            NF_CaseTriggerDomainHandler.TriggerDisabled = false;

        }
    }

    //this method is used to update chat created date on case record
    //@Future
    public static void updateChatCreatedDate(String chatString,Set<Id> chatIdSet){
        List<LiveChatTranscript> chatList = (List<LiveChatTranscript>)JSON.deserialize(chatString, List<LiveChatTranscript>.class);
        Set<Id> caseIdSet = new Set<Id>();

        for (LiveChatTranscript chat : chatList){
            if (chat.CaseId != null){
                caseIdSet.add(chat.CaseId);
            }
        }
        if (!caseIdSet.isEmpty()){
            List<Case> caseList = [SELECT Id, Chat_Created_Date__c, (SELECT Id, CreatedDate, Subject__c
                                                                     FROM LiveChatTranscripts
                                                                     Order by CreatedDate
                                                                     LIMIT 1)
                                   FROM Case 
                                   WHERE Id IN:caseIdSet];
            if (!caseList.isEmpty()){
                for (Case c : caseList){
                    for (LiveChatTranscript lv : c.LiveChatTranscripts){
                        c.Chat_Created_Date__c = Date.valueOf(lv.CreatedDate);
                        c.Subject = lv.Subject__c;
                    }
                }
                NF_CaseTriggerDomainHandler.TriggerDisabled = true;
                update caseList;
                NF_CaseTriggerDomainHandler.TriggerDisabled = false;
                updateContactAndAccount(chatString);
                updateDirectAgentHandleTime(chatIdSet);
            }
        }
    }

    //this method updates contact and account on Case
    public static void updateContactAndAccount(String chatString){
        List<LiveChatTranscript> chatList = (List<LiveChatTranscript>)JSON.deserialize(chatString, List<LiveChatTranscript>.class);
        Map<Id, LiveChatTranscript> caseIdVsChatMap = new Map<Id, LiveChatTranscript>();
		system.debug('caseIdVsChatMap'+caseIdVsChatMap);
        system.debug('chatList'+chatList);
        for (LiveChatTranscript chat : chatList){
            if (chat.CaseId != null && chat.ContactId != null){
                caseIdVsChatMap.put(chat.CaseId, chat);
            }
        }
        if (caseIdVsChatMap != null && caseIdVsChatMap.size() > 0){
            List<Case> caseList = [SELECT Id, ContactId, AccountId
                                   FROM Case
                                   WHERE Id IN:caseIdVsChatMap.keySet()];
            if (!caseList.isEmpty()){
                for (Case c : caseList){
                    c.ContactId = caseIdVsChatMap.get(c.Id).ContactId;
                    c.Chat_Created_Date__c = Date.valueOf(caseIdVsChatMap.get(c.Id).CreatedDate);
                    c.Subject = caseIdVsChatMap.get(c.Id).Subject__c;
                    if (caseIdVsChatMap.get(c.Id).AccountId != null){
                        c.AccountId = caseIdVsChatMap.get(c.Id).AccountId;
                    }
                }
                NF_CaseTriggerDomainHandler.TriggerDisabled = true;
                update caseList;
                NF_CaseTriggerDomainHandler.TriggerDisabled = false;
            }
        }
    }

    //This method updates live chat agent handle time for direct chat
    public static void updateDirectAgentHandleTime(Set<Id> chatIds){
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        //List<LiveChatTranscript> chatSessionList = Trigger.isInsert || Trigger.isUpdate ? Trigger.New : Trigger.Old;
        String chatButtonId = NF_Util.getChatButtonId('Customer_Care_Associates');

        for (AggregateResult ag : [SELECT CaseId, AVG(Agent_Chat_Handle_Time__c)avg
                                   FROM LiveChatTranscript
                                   WHERE Id IN:chatIds AND CaseId != null AND LiveChatButtonId = :chatButtonId
                                   GROUP BY CaseId]){
            Case cs = new Case();
            cs.Id = (Id) ag.get('CaseId');
            cs.Live_Chat_Agent_Average_Chat_Handle_Time__c = (Decimal) ag.get('avg');
            caseListToUpdate.add(cs);

        }

        if (!caseListToUpdate.isEmpty()){
            NF_CaseTriggerDomainHandler.TriggerDisabled = true;
            update caseListToUpdate;
            NF_CaseTriggerDomainHandler.TriggerDisabled = false;

        }
    }

}