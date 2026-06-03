public without sharing class CaseCarrierFixBatch implements Database.Batchable<SObject> {
    private String query = 'Select Id, Carrier__c, Carrier_Code__c From Case Where Carrier__c != null limit 20000';
	
    // start method
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
	
    //execute method
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        try{
            List<Case> cases = (List<Case>) scope;
            System.debug('Size '+cases.size());
    
            for(Case caseRecord : cases) {
                caseRecord.Carrier_Code__c = caseRecord.Carrier__c;
            }
            Database.update(cases, false);
        } catch(Exception e) {
            System.debug('Exception caught>>>'+ e.getStackTraceString());
        }
        
    }
	
    //do nothing in finish
    public void finish(Database.BatchableContext BC){
        
    }

}