/***************************************************************
Interface Name : BatchProcessAccountPhoneSearch
CreatedDate    : 13-July-22
*! Description : One Time batch to update the Phone Search Field
* Created By   : Pooja

*Revision History

Date Name Story Number Description
DP-55052  - One Time batch to update the Phone Search Field
***************************************************************/
 


public class BatchProcessAccountPhoneSearch implements Database.Batchable<SObject>, Database.Stateful  {
    
    Boolean isSuccess = true;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
 
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        // pulling the eligible users through SOQL
        return Database.getQueryLocator([
        SELECT Id,Name,Phone_Search__c
        FROM Account 
        WHERE ( Phone_Length__c >10 OR  Phone_Length__c < 10) AND Phone_Search__c <> NULL ]);
    }
    
    
    public void execute(Database.BatchableContext bc, List<Account> record){
        
        List<Account> accListToUpdate = new   List<Account>();
        
        
        // Marking them False and creating email body 
        for (Account acc : record) {
            account a = new account();
            a.Phone_Search_reset__c = False;
            a.id = acc.id;
            accListToUpdate.add(a);
        }
        System.debug('accListToUpdate'+accListToUpdate);
        // DML ~ marking the list of users as False
        if (!accListToUpdate.isempty()) {
            Database.SaveResult [] updateResults = Database.update(accListToUpdate, false);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    
}