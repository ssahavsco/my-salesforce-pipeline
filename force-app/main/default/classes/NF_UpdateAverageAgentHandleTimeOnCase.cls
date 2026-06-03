global class NF_UpdateAverageAgentHandleTimeOnCase implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String closedStatus='Closed';
        String query = 'SELECT Id,ebotdata__Case__c,ebotdata__Agent_Handle_Time__c FROM ebotdata__Bot_Session__c where ebotdata__Case__c!=null  and ebotdata__Case__r.Status!=:closedStatus and ebotdata__Case__r.Id!=null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ebotdata__Bot_Session__c> botSessionList){
        List<Case> caseListToUpdate = new List<Case>();
        for (AggregateResult ag : [SELECT ebotdata__Case__c, AVG(ebotdata__Agent_Handle_Time__c)avg
                                   FROM ebotdata__Bot_Session__c
                                   WHERE Id IN:botSessionList AND ebotdata__Case__c != null
                                   GROUP BY ebotdata__Case__c]){
            Case cs = new Case();
            cs.Id = (Id) ag.get('ebotdata__Case__c');
            cs.Average_Agent_Handle_Time__c = (Decimal) ag.get('avg');
            caseListToUpdate.add(cs);

        }
        if (!caseListToUpdate.isEmpty()){
            update caseListToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC){
    }

}