/****************************************************************************************************************
* Program Name         : EC_DailyCouponRequestBatch
* Description          : This batch class is used to get daily coupon request and assign it to ad-hoc queue.
* Version              : 1.1
* Modification Log     : 25 May, 2021 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId                Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   TA_01          DP-37421,DP-42073       1.1       Tara Chand             05/25/2021      This class is used to get daily coupon request and assign it to ad-hoc queue.
*                                                                                                                                   
*****************************************************************************************************************/

global with sharing class EC_DailyCouponRequestBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String csvData;

     //In start method of batch we fetch all Coupon Request - Email case resolution.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = System.today();
        List<String> caseResolutionTypeList = new List<String>{'Coupon Request - Email'};
        String query = 'SELECT Id,Related_Case__r.CaseNumber,'+
                        'Related_Case__r.Contact.FirstName,Related_Case__c,'+
                        'Processed_Date_Time__c,Related_Case__r.Contact.LastName,'+
                        'Related_Case__r.Account.ShippingStreet,Related_Case__r.Account.ShippingCity,'+
                        'Related_Case__r.Account.ShippingState,Related_Case__r.Account.ShippingPostalCode,'+
                        'Related_Case__r.Account.ShippingCountry,Case_Resolution__c.CreatedDate,Case_Resolution__c.Name '+                        
                        'FROM Case_Resolution__c WHERE Case_Resolution_Type__c IN:caseResolutionTypeList AND Processed_Date_Time__c = null';
        return Database.getQueryLocator(query);
    }

     //Process all case resolution in execute method in chunks and update Processed_Date_Time__c with now().    
    global void execute(Database.BatchableContext BC, List<Case_Resolution__c> scope) {
        if(scope.size() > 0){
            csvData = '';
            if(String.isBlank(csvData)){
                csvData += 'Case_Id,Case_Resolution_Name, Customer_First_Name, Customer_Last_Name, Customer_Add_Street_nbr, Customer_Add_Street_nme, Customer_Add_City,Customer_Add_State_cde, Customer_Add_Zip, Customer_Add_country_cde,res_dte ' + '\n';
            }
            for(Case_Resolution__c resolution : scope) {
                resolution.Processed_Date_Time__c = System.now();
                csvData+= resolution.Related_Case__r.CaseNumber;
                csvData+= ','+resolution.Name;
                csvData+= ','+resolution.Related_Case__r.Contact.FirstName;
                csvData+= ','+resolution.Related_Case__r.Contact.LastName;
                csvData+= ','+resolution.Related_Case__r.Account.ShippingStreet;
                csvData+= ','+resolution.Related_Case__r.Account.ShippingStreet;
                csvData+= ','+resolution.Related_Case__r.Account.ShippingCity;
                csvData+= ','+resolution.Related_Case__r.Account.ShippingState;
                csvData+= ','+resolution.Related_Case__r.Account.ShippingPostalCode;
                csvData+= ','+resolution.Related_Case__r.Account.ShippingCountry;
                csvData+= ','+resolution.CreatedDate+'\n';
            }
            update scope;
        }
    }
       
    //In finish method we create a csv of all the case resolution and insert it as a attachment on case.
    global void finish(Database.BatchableContext BC) {
       if(String.isNotBlank(csvData)){
            List<QueueSobject> listOfQueues = [SELECT QueueId,Queue.Name FROM QueueSobject where Queue.Name = 'Enterprise Correspondence Transfer Cases' LIMIT 1];
            String recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EC Adhoc Case').getRecordTypeId();
            if(listOfQueues.size() > 0){   
                Case cse = new Case();
                cse.recordTypeId = recordTypeID;
                cse.OwnerId = listOfQueues[0].QueueId;
                insert cse;
                Attachment att = new Attachment();
                att.ParentId = cse.id;
                att.Name= 'Daily_coupon_request_report.csv';
                att.ContentType='text/csv';
                att.Body=Blob.valueOf(csvData);
                insert att;
            }
       }
    }
}