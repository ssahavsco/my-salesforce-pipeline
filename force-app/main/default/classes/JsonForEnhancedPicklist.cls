/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Class to create JSON Body for Enhanced Picklist 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Pooja  <lkorrapati@lb.com>
* @modifiedBy     Pooja  <lkorrapati@lb.com>
* @maintainedBy   Pooja  <lkorrapati@lb.com>
* @version        1.0x
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
*/public with sharing class JsonForEnhancedPicklist {
    
    
    public static string JSONContactsMethod (Map<String,boolean> picklstTypeWithNameMap, Map<String,integer> typeWithIndex,Map<String,List<Integer>> subTypeWithIndexListMap, Map<string,String> typeWithAPIValueMap,Map<String,string> subTypeWithAPIValueMap ){
        
         //PK_01
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeFieldName('picklistFieldValues');
        jsonGen.writeStartObject();
        
        For(string picklstName : picklstTypeWithNameMap.keySet()){
            
            jsonGen.writeFieldName(picklstName);
            jsonGen.writeStartObject();
            jsonGen.writeFieldName('values');
            jsonGen.writeStartArray();
            
            If(picklstName == 'Type'){
                for(string type :  typeWithIndex.keySet()){
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('value',type);
                    jsonGen.writeFieldName('validFor');
                    jsonGen.writeStartArray();
                    jsonGen.writeEndArray();
                    jsonGen.writeStringField('label',typeWithAPIValueMap.get(type));
                    jsonGen.writeStringField('attributes','');
                    jsonGen.writeEndObject();
                }
            }else if(picklstName == 'Sub_Type__c'){
                for(string subType :  subTypeWithIndexListMap.keySet()){
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('value',subType);
                    jsonGen.writeFieldName('validFor');
                    jsonGen.writeStartArray();
                    if(picklstName == 'Sub_Type__c'){
                        for(Integer indx : subTypeWithIndexListMap.get(subType)){
                            jsonGen.writeNumber(indx);
                        }
                    }
                    jsonGen.writeEndArray();
                    jsonGen.writeStringField('label',subTypeWithAPIValueMap.get(subType));
                    jsonGen.writeStringField('attributes','');
                    jsonGen.writeEndObject();
                }
            }
            
            jsonGen.writeEndArray();
            jsonGen.writeStringField('url','/services/data/v50.0/u');
            jsonGen.writeStringField('defaultValue','');
            jsonGen.writeFieldName('controllerValues');
            jsonGen.writeStartObject();
            
            if(picklstName == 'Sub_Type__c'){
                For(String type: typeWithIndex.keySet()){
                    jsonGen.writeNumberField(type,typeWithIndex.get(type));
                }
            }
            jsonGen.writeEndObject();
            jsonGen.writeEndObject();
        }
        
        jsonGen.writeEndObject();   
        jsonGen.writeEndObject();   
        
        String jsonData = jsonGen.getAsString();
        System.debug('Json Data - ' + jsonData);
        System.debug('Json Data - ' + jsonGen);
        
        return jsonData;
         //PK_01
    }
    
}