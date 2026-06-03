/*
***********************************************************************************************************
* Program Name      : VS_CustomerCasesCount
* Description       : Helper class to count number of cases for a Customer(Account)
* Version           : 1.1
* Modification Log  : 07/07/2022
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-56353    1.1         Sharath Vadla      07/07/2022      Creating helper class to rollup cases count to Customer.
*
***********************************************************************************************************
*/
public with sharing class VS_CustomerCasesCount {
    // Count number of cases from a list of cases which are not closed
    // for insert,delete and undelete
    public static void countCustomerCases(List<Case> caseList) {
        Set<id> accountIds = new Set<id>();
        List<Account> listOfCustomers = new List<Account>();
        For(Case thisCase : caseList){   
            if(thisCase.AccountId != null){
                accountIds.add(thisCase.accountId);          
            }     
        }
        if(!accountIds.isEmpty()){
            List<Account> customerList = [SELECT Id,Case_Count__c, (SELECT Id FROM Cases WHERE Status != 'Closed' AND CreatedDate = LAST_N_DAYS:5) FROM Account WHERE Id IN :accountIds];
            For(Account thisCustomer : customerList){
                if(thisCustomer.Cases.size()>0){
                    thisCustomer.Case_Count__c = thisCustomer.Cases.size(); 
                    listOfCustomers.add(thisCustomer);
                }
            }
            if(listOfCustomers.size()>0)
                update listOfCustomers; 
        }            
    }  

    //Rollup number of cases to Customer when the Status is updated with Closed status
    public static void countUpdatedCustomerCases(List<Case> newCaseList, Map<Id,sObject> oldMap){
        Set<id> accountIds = new Set<id>();
        List<Account> listOfCustomers = new List<Account>();
        For(Case thisCase : newCaseList){   
            if(thisCase.AccountId != null){
                accountIds.add(thisCase.accountId);         
            }
            Case oldCase = (Case)oldMap.get(thisCase.Id);
            if(thisCase.AccountId != oldCase.AccountId){
                accountIds.add(oldCase.AccountId);  
            }   
        }    
        
        if(!accountIds.isEmpty()){
            List<Account> customerList = [SELECT Id,Case_Count__c, (SELECT Id FROM Cases WHERE Status != 'Closed' AND CreatedDate = LAST_N_DAYS:5) FROM Account WHERE Id IN :accountIds];
            For(Account thisCustomer : customerList){
                if(thisCustomer.Cases.size()>0){
                    thisCustomer.Case_Count__c = thisCustomer.Cases.size(); 
                    listOfCustomers.add(thisCustomer);
                }
            }
            if(listOfCustomers.size()>0)
                update listOfCustomers; 
        }
    }
}