/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Batch class to create Picklist Structure in custom settigs for Case - Type and SUbtype - One Type Run 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Pooja  <lkorrapati@lb.com>
* @modifiedBy     Pooja  <lkorrapati@lb.com>
* @maintainedBy   Pooja  <lkorrapati@lb.com>
* @version        1.0
* @created        2021-10-23
* @modified       2021-10-23
* @jiraNumber     DP-37102
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Pooja  <lkorrapati@lb.com>
*
* First version of class
*
Revision History 
-------
VERSION  AUTHOR                 DATE                 TICKET REFERENCE/ NO.           DETAIL                      

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class BatchCreateEnhancedPicklistInCustomSet implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    Public Boolean isSuccess=false;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Get all the record types for Case object
        return Database.getQueryLocator(
            [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case']
        );
    }
    
    public void execute(Database.BatchableContext bc, List<RecordType> scope) {
        // Deleting all the existing Enhanced Picklist Value and create everything from scratch
        List<Enhanced_Picklist__c> custSetdeleteLst = new List<Enhanced_Picklist__c>(
            [SELECT Id FROM Enhanced_Picklist__c]
        );
        Integer counter = 0;
        List<Enhanced_Picklist__c> custSetToInsertLst = new List<Enhanced_Picklist__c>();
        
        // Loop each record type for Case to get the JSON from API call and then convert it into the custom settings format
        for (RecordType recType : scope) {
            // Get Values from custom settings for API Callout
            RTPL_Settings__c settings = RTPL_Settings__c.getInstance(
                UserInfo.getUserId()
            );
            String recordTypeId = recType.Id;
            String sobjectName = 'Case';
            String recordTypeName = Schema.getGlobalDescribe()
                .get('Case')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(recordTypeId)
                .getName();
            
            // HTTP Callout to Salesforce Enhanced Picklist
            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:' +
                settings.Named_Credential__c +
                '/services/data/v' +
                settings.Api_Version__c +
                '/ui-api/object-info/' +
                sobjectName +
                '/picklist-values/' +
                recordTypeId
            );
            req.setMethod('GET');
            logger.info('Endpoint: ' + req.getEndpoint());
            HttpResponse res = new Http().send(req);
            system.debug('Response Status: ' + res.getStatus());
            system.debug('Response Body: ' + res.getBody());
            if(res.getStatusCode() == 200){
                isSuccess = true;
                // Deserialize JSON response Body
                RTPL_PicklistValues pl = (RTPL_PicklistValues) JSON.deserialize(
                    res.getBody(),
                    RTPL_PicklistValues.class
                );
                System.debug(JSON.serialize(pl));
                system.debug(pl);
                system.debug(pl.picklistFieldValues.get('Sub_Type__c'));
                
                Map<String, Integer> typeWithIndex = pl.picklistFieldValues.get(
                    'Sub_Type__c'
                )
                    .controllerValues;
                Map<Integer, String> indexWithType = new Map<Integer, String>();
                Map<String, String> typeWithAPIValueMap = new Map<String, String>();
                
                // Create Map for Type label with API Name
                for (
                    RTPL_PicklistValues.PicklistValue type : pl.picklistFieldValues.get(
                        'Type'
                    )
                    .values
                ) {
                    if (type.value != 'Auto-Closed Case') {
                        typeWithAPIValueMap.put(type.value, type.label);
                    }
                }
                
                for (String type : typeWithIndex.keySet()) {
                    system.debug('Type: ' + type);
                    system.debug('Type Index: ' + typeWithIndex.get(type));
                    indexWithType.put(typeWithIndex.get(type), type);
                }
                system.debug('Index With Type Map: ' + indexWithType);
                
                // SubType Map creation
                Map<String, List<Integer>> subTypeWithIndexMap = new Map<String, List<Integer>>();
                Map<String, String> subTypeWithAPIValueMap = new Map<String, String>();
                
                for (
                    RTPL_PicklistValues.PicklistValue c : pl.picklistFieldValues.get(
                        'Sub_Type__c'
                    )
                    .values
                ) {
                    if (c.value != 'Auto-Closed Case') {
                        subTypeWithIndexMap.put(c.value, c.validFor);
                        subTypeWithAPIValueMap.put(c.value, c.label);
                    }
                }
                system.debug('SubType with Index Map: ' + subTypeWithIndexMap);
                
                // Loop through each subtype and insert into custom setting
                for (String subType : subTypeWithIndexMap.keySet()) {
                    system.debug('SubType: ' + subType);
                    system.debug('SubType Index List: ' + subTypeWithIndexMap.get(subType));
                    
                    for (Integer index : subTypeWithIndexMap.get(subType)) {
                        Enhanced_Picklist__c custSet = new Enhanced_Picklist__c();
                        custSet.Record_Type_Name__c = recordTypeName;
                        custSet.Object_Name__c = sobjectName;
                        custSet.Dependent_field_value__c = subType;
                        custSet.Dependent_Field_API_Value__c = subTypeWithAPIValueMap.get(
                            subType
                        );
                        custSet.Dependent_field_API_Name__c = 'Sub_Type__c';
                        custSet.Controlling_field_Value__c = indexWithType.get(
                            Integer.valueOf(index)
                        );
                        custSet.Controlling_Field_API_Value__c = typeWithAPIValueMap.get(
                            indexWithType.get(Integer.valueOf(index))
                        );
                        custSet.Controlling_field_API_Name__c = 'Type';
                        custSet.Name = String.valueOf(counter);
                        counter++;
                        custSetToInsertLst.add(custSet);
                    }
                }
                
                // NEW: Handle the relationship for 'Lost_Package_Details__c'
                
                Map<String, List<Integer>> codeDetailsWithIndexMap = new Map<String, List<Integer>>();
                Map<String, String> codeDetailsWithAPIValueMap = new Map<String, String>();
                
                for (
                    RTPL_PicklistValues.PicklistValue codeDetail : pl.picklistFieldValues.get(
                        'Lost_Package_Details__c'
                    )
                    .values
                ) {
                    codeDetailsWithIndexMap.put(codeDetail.value, codeDetail.validFor);
                    codeDetailsWithAPIValueMap.put(codeDetail.value, codeDetail.label);
                }
                
                for (String codeDetail : codeDetailsWithIndexMap.keySet()) {
                    for (Integer index : codeDetailsWithIndexMap.get(codeDetail)) {
                        Enhanced_Picklist__c custSet = new Enhanced_Picklist__c();
                        custSet.Record_Type_Name__c = recordTypeName;
                        custSet.Object_Name__c = sobjectName;
                        custSet.Dependent_field_value__c = codeDetail;
                        custSet.Dependent_Field_API_Value__c = codeDetailsWithAPIValueMap.get(
                            codeDetail
                        );
                        custSet.Dependent_field_API_Name__c = 'Lost_Package_Details__c'; // New field
                        custSet.Controlling_field_Value__c = indexWithType.get(
                            Integer.valueOf(index)
                        );
                        custSet.Controlling_Field_API_Value__c = typeWithAPIValueMap.get(
                            indexWithType.get(Integer.valueOf(index))
                        );
                        custSet.Controlling_field_API_Name__c = 'Type';
                        custSet.Name = String.valueOf(counter);
                        counter++;
                        custSetToInsertLst.add(custSet);
                    }
                }
                
            }
        }
        
        
        if(isSuccess && custSetdeleteLst !=null && custSetdeleteLst.size()>0){
            delete custSetdeleteLst;
        }
        
        // Insert custom setting records
        if(custSetToInsertLst !=null && custSetToInsertLst.size()>0){
            insert custSetToInsertLst;
        }
        
        
    }
    
    public void finish(Database.BatchableContext bc) {
        // Optional finish method
    }
}