/***************************************************************
Interface Name : LB_CustomLookupController
CreatedDate : 02-Dec-21
Description :  
Created By : Poojitha Korrapati

Revision History

Date Name Story Number Description
Pooja | DP-46651  - Custom Lookup Field for Store Search
***************************************************************/

public with sharing class LB_CustomLookupController {
    
    
    
    //get store records based on search string
    @AuraEnabled
    public static List<storeAccountWrapper> fetchRecords(String objectName, String filterField, String searchString, String recordTypeName) {
        try {
            //,Phone,PersonMailingAddress,BillingAddress,BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,RE_Store_Number__c,PersonMailingCity, PersonMailingCountry, PersonMailingPostalCode, PersonMailingState, PersonMailingStreet
            Id recordTypeId = [select id from RecordType where SobjectType ='Account' and DeveloperName =:recordTypeName].Id;
            //String searchQuery = 'FIND \'*' + searchString + '*\' IN ALL FIELDS RETURNING  Account (Id,Name,SAP_Store__c  WHERE RecordTypeId =\''+recordTypeId+'\')';
            //[Select Id,Phone ,Email_Phone__c,SAP_Store__c ,Account.Name,PersonMailingAddress,BillingAddress,BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,RE_Store_Number__c,PersonMailingCity, PersonMailingCountry, PersonMailingPostalCode, PersonMailingState, PersonMailingStreet   from account 
                                  //where ID In: (sObject[])searchList[0]]
            //List<List <sObject>> searchList = search.query(searchQuery);
            List<storeAccountWrapper> storeLst = new List<storeAccountWrapper>();
            String searchParam = '%' + searchString + '%';
            For(account  store : [Select Id,Phone ,Email_Phone__c,SAP_Store__c ,Account.Name,PersonMailingAddress,BillingAddress,BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,RE_Store_Number__c,PersonMailingCity, PersonMailingCountry, PersonMailingPostalCode, PersonMailingState, PersonMailingStreet   from account 
                                  where RecordTypeId =: recordTypeId and (SAP_Store__c like:  searchParam or name like: searchParam)] ){
                storeAccountWrapper storeWrapper = new storeAccountWrapper();
                storeWrapper.Id = store.Id;
                storeWrapper.Name = store.Name;
                storeWrapper.PhoneEmail =  store.Email_Phone__c;
                storeWrapper.REStoreNumber = store.RE_Store_Number__c;
                storeWrapper.SAPStore = store.SAP_Store__c;
                
                List<String> lstStr = new List<String>();
                if(store.BillingStreet !=null) lstStr.add(store.BillingStreet);
                if(store.BillingCity !=null) lstStr.add(store.BillingCity);
                if(store.BillingState !=null) lstStr.add(store.BillingState);
                if(store.BillingCountry !=null) lstStr.add(store.BillingCountry);
                if(store.BillingPostalCode !=null) lstStr.add(store.BillingPostalCode);
                String finalAddress = String.join(lstStr,', ');
                
                storeWrapper.BillingAddress = finalAddress;
                storeWrapper.CustomerAddress ='Business Address';
                storeLst.add(storeWrapper);
            }
            
            return storeLst;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    //get store records based on search string
    @AuraEnabled
    public static Account updateDeleteCase(String accId, String recordId, string storeOrFranchise, boolean isRemove) {
        system.debug('isRemove'+isRemove);
        system.debug('accId'+accId);
        system.debug('recordId'+recordId);
        system.debug('storeOrFranchise'+storeOrFranchise);
        Case c = new case();
        c= [Select Id, store__c,Franchise__c from case where id=:recordId];
        
        if(storeOrFranchise == 'Store'){
            
            If(isRemove){
                c.Store__c = null; 
            }else{
                c.Store__c = accId;
            }
            
        } else if(storeOrFranchise == 'Franchise'){
            If(isRemove){
                c.Franchise__c = null; 
            }else{
                c.Franchise__c = accId;
            }
        }  
        
        Update c;
        
        If(!isRemove){
            Account acc= new Account ();
            acc= [Select Id,name,BillingAddress,RE_Store_Number__c ,SAP_Store__c,BillingCity, BillingCountry, BillingStreet, BillingState,BillingPostalCode from Account where id =: accId];
            return acc; 
        }
        
        return null;
    }
    
    
    //get store records based on search string
    @AuraEnabled
    public static storeFranchiseWrapper fetchAccount(String recordId) {
        
        Case c = new case();
        c = [Select Id,store__c,Franchise__c  from Case where id = :recordId];
        
        storeFranchiseWrapper storeFranchiseWrp = new storeFranchiseWrapper();
        If(c.Store__c != null){
            List<Account> store= [Select Id,name,BillingAddress,RE_Store_Number__c ,SAP_Store__c,BillingCity, BillingCountry, BillingStreet, BillingState,BillingPostalCode  from Account where id =: c.Store__c];
            if(!store.isEmpty()){
                storeFranchiseWrp.store = store[0]; 
            }
        }
        if(c.Franchise__c != null){
            List<Account> franchise = [Select Id,name,BillingAddress,RE_Store_Number__c ,SAP_Store__c,BillingCity, BillingCountry, BillingStreet, BillingState,BillingPostalCode  from Account where id =: c.Franchise__c];
            if(!franchise.isEmpty()){
                storeFranchiseWrp.Franchise = franchise[0]; 
            } 
        }
        system.debug('storeFranchiseWrp'+storeFranchiseWrp);
        If(storeFranchiseWrp != null){
            return storeFranchiseWrp;
        }
        
        return null;
    }
    
    // Wrapper CLass to get  store or franchise records for UI display
    Public class storeFranchiseWrapper{
        
        @AuraEnabled
        public account Store;
        @AuraEnabled
        public account Franchise;
    }
    
    
    // Wrapper CLass for Account records for UI display
    Public class storeAccountWrapper{
        
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string PhoneEmail;
        @AuraEnabled
        public string REStoreNumber;
        @AuraEnabled
        public string SAPStore;
        @AuraEnabled
        public string BillingAddress;
        @AuraEnabled
        public string CustomerAddress;
        @AuraEnabled
        public string id;
        
    }
    
}