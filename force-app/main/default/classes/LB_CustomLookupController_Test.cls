/***************************************************************
Interface Name : LB_CustomLookupController_Test
CreatedDate : 14-Dec-21
Description :  Test class for LB_SocialPostQuickUpdateController
Created By : Poojitha Korrapati

Revision History

Date Name Story Number Description
Pooja | DP-46651  - Tests classs for LB_CustomLookupController

***************************************************************/

@IsTest
public with sharing class LB_CustomLookupController_Test {
    
    @IsTest
    static void testLookupMethod(){
        
        string recordTypeId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Store').getRecordTypeId();
        
        test.startTest();
        Account  Store = new Account ();
        Store.Name  = 'Test Store';
        Store.Phone = '9990000000';
        Store.SAP_Store__c ='7887' ;
        Store.BillingCity = 'DUblin';
        Store.BillingCountry ='US' ;
        Store.BillingPostalCode = '43017';
        Store.BillingStreet = 'Test Drive';
        Store.BillingState = 'Ohio';
        Store.RecordTypeId = recordTypeId;
        insert Store;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = Store.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        LB_CustomLookupController.fetchRecords('test', 'test','Test Store','Store');
        test.stopTest();
    }
    
    
    
    @IsTest
    static void testfetchAccountMethod(){
        
        string recordTypeId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Store').getRecordTypeId();
        string recordTypeFranchiseId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
        
        test.startTest();
        Account  Store = new Account ();
        Store.Name  = 'Test Store';
        Store.Phone = '9990000000';
        Store.SAP_Store__c ='7887' ;
        Store.BillingCity = 'DUblin';
        Store.BillingCountry ='US' ;
        Store.BillingPostalCode = '43017';
        Store.BillingStreet = 'Test Drive';
        Store.BillingState = 'Ohio';
        Store.RecordTypeId = recordTypeId;
        insert Store;
        
        Account  franchise = new Account ();
        franchise.Name  = 'Test Franchise';
        franchise.Phone = '9990000001';
        franchise.SAP_Store__c ='7817' ;
        franchise.BillingCity = 'DUblin';
        franchise.BillingCountry ='US' ;
        franchise.BillingPostalCode = '43017';
        franchise.BillingStreet = 'Test Drive';
        franchise.BillingState = 'Ohio';
        franchise.RecordTypeId = recordTypeFranchiseId;
        insert franchise;
        
        
        Case aCase = new Case();
        aCase.Subject = 'test this';
        aCase.store__c = Store.Id;
        aCase.franchise__c = franchise.Id;
        insert aCase;
        
        LB_CustomLookupController.fetchAccount(aCase.Id);
        
        LB_CustomLookupController.updateDeleteCase(Store.id,aCase.id, 'Store',  false) ;
        LB_CustomLookupController.updateDeleteCase(Store.id,aCase.id, 'Store',  true) ;
        
        LB_CustomLookupController.updateDeleteCase(Franchise.id,aCase.id, 'Franchise',  false) ;
        LB_CustomLookupController.updateDeleteCase(Franchise.id,aCase.id, 'Franchise',  true) ;
        
        
        test.stopTest();
    }
    
    
}