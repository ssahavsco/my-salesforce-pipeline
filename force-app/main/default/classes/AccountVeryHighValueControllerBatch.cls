public class AccountVeryHighValueControllerBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private Set<String> emails;
    
    public AccountVeryHighValueControllerBatch(List<String> emailList) {
        emails = new Set<String>(emailList);
        System.debug('Email set size' + emails.size());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Non_High_Value__c FROM Account WHERE Non_High_Value__c = FALSE AND PersonEmail IN :emails LIMIT 10000]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        System.debug('Batch processing scope size: ' + scope.size());
        for (Account acc : scope) {
            acc.Non_High_Value__c = true;
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        List<Account> remainingAccounts = [SELECT Id, Non_High_Value__c FROM Account WHERE Non_High_Value__c = FALSE AND PersonEmail IN :emails LIMIT 50000];
        if(remainingAccounts.size() > 0) {
            List<String> emailList = new List<String>(emails);
            Database.executeBatch(new AccountVeryHighValueControllerBatch(emailList), 2000);
        }
    }

}