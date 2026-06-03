public with sharing class NF_PersonAccountHandler{
    
    public static void ProcessPersonAccounts(List<Account> accounts){
        List<Account> personAccounts = new List<Account>();
        for(Account acc: accounts){
            if(acc.IsPersonAccount == true){
                personAccounts.add(acc);
            }
        }
        if(personAccounts.size()>0){
            NF_TriggerFactory.createAndExecuteHandler(NF_AccountTriggerHandler.class);
        }
    }

}