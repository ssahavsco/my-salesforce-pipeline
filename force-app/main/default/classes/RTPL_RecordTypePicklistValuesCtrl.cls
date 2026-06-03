/**
 * Copyright 2018 OpFocus, Inc
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 /**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller to support the RTPL component 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Bill Johnson  <bill.johnson@neuraflash.com>
* @modifiedBy     Bill Johnson  <bill.johnson@neuraflash.com>
* @maintainedBy   Bill Johnson  <bill.johnson@neuraflash.com>
* @version        1.0
* @created        2021-04-08
* @modified       2021-04-08
* @jiraNumber     DP-37102
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Bill Johnson  <bill.johnson@neuraflash.com>
*
* First version of class
*
Revision History 
-------
VERSION  AUTHOR                 DATE                 TICKET REFERENCE/ NO.           DETAIL                      
PK_01       Pooja                10/22/2021                 DP-36414                    Remove API for Case Enhanced Picklist and manage it in custom settings             
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class RTPL_RecordTypePicklistValuesCtrl {

    static RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());

    /**
     * callout to user interface api to get picklist values for given record type
     * @param  sobjectName    [sobject api name]
     * @param  recordTypeId   [record type id]
     * @param  recordTypeName [record type name]
     * @return                [description]
     */
   
  
     @AuraEnabled
    public static String getPicklistValues(String sobjectName, String recordTypeId, String recordTypeName){

        system.debug('++++++++++++++'+sobjectName);
        system.debug('++++++++++++++'+recordTypeId);
        system.debug('++++++++++++++'+recordTypeName);


        try{
            HttpRequest req = new HttpRequest();

            // if recordtypeid is null, use recordtype name to get the id
            if(recordTypeId == null){
                if(recordTypeName == null){
                    throw new RecordTypeValuesCtrlException('Record Type Name is required is Record Type Id is not supplied');
                }
                try{
                    recordTypeId = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                }
                catch(Exception re){
                    throw new RecordTypeValuesCtrlException('Record Type Name ' + recordTypeName + ' is invalid for SObject ' + sobjectName);
                }
            }
            //PK_01
            recordTypeName = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            
            Map<string,String> typeWithAPIValueMap = new Map<string,String> ();
            Map<String,string> subTypeWithAPIValueMap = new Map<String,string>();
             
            Map<String,boolean> picklstTypeWithNameMap = new Map<String,boolean> ();
            picklstTypeWithNameMap.put('Type',true);
            picklstTypeWithNameMap.put('Sub_Type__c',false);
                       
            //Get all the custom settings records based on the record Type Name 
            set<Enhanced_Picklist__c> casePickListType = new set< Enhanced_Picklist__c >([Select Id,name,Dependent_Field_API_Value__c, Controlling_Field_API_Value__c,Dependent_field_value__c,Controlling_field_Value__c  from Enhanced_Picklist__c where Object_Name__c= 'Case' AND Record_Type_Name__c =: recordTypeName AND Controlling_field_API_Name__c='Type' order BY Controlling_field_Value__c ASC ]);
            set<Enhanced_Picklist__c> casePickListSubType = new set< Enhanced_Picklist__c >([Select Id,name,Dependent_Field_API_Value__c, Controlling_Field_API_Value__c,Dependent_field_value__c,Controlling_field_Value__c  from Enhanced_Picklist__c where Object_Name__c= 'Case' AND Record_Type_Name__c =: recordTypeName AND Dependent_field_API_Name__c='Sub_Type__c' order BY Dependent_field_value__c ASC ]);            
            
            
            
            Map<String,integer> typeWithIndex = new Map<String,integer> ();
            system.debug('casePickListType'+casePickListType.size());
            
            // To Create SUBTYPE Values with Index mapping to TYPE  Data for JSON  
            Map<String,List<Integer>> subTypeWithIndexListMap = new Map<String,List<Integer>>();
            Integer typeIndex =0;
            for(Enhanced_Picklist__c type : casePickListType ){
                if(!typeWithIndex.containsKey(type.Controlling_field_Value__c)){
                    typeWithIndex.put(type.Controlling_field_Value__c,typeIndex);
                    typeIndex++;
                }
                 if(!typeWithAPIValueMap.containsKey(type.Controlling_Field_Value__c)){
                    typeWithAPIValueMap.put(type.Controlling_Field_Value__c,type.Controlling_Field_API_Value__c);
                 }
              }
            
            List<Integer> indexList = new List<Integer>();
            
             // To Create TYPE Values with Index  Data for JSON  
              for(Enhanced_Picklist__c type : casePickListSubType ){
                if(!subTypeWithIndexListMap.containsKey(type.Dependent_field_value__c)){
                    subTypeWithIndexListMap.put(type.Dependent_field_value__c,new List<Integer>{});
                 }
                 subTypeWithIndexListMap.get(type.Dependent_field_value__c).add( typeWithIndex.get(type.Controlling_field_Value__c));
                  if(!subTypeWithAPIValueMap.containsKey(type.Dependent_field_value__c)){
                    subTypeWithAPIValueMap.put(type.Dependent_field_value__c,type.Dependent_Field_API_Value__c);
                 }
            }
           
            system.debug('picklstTypeWithNameMap'+picklstTypeWithNameMap);
            system.debug('typeWithIndex'+typeWithIndex);
            system.debug('subTypeWithIndexListMap'+subTypeWithIndexListMap);
            system.debug('typeWithAPIValueMap'+typeWithAPIValueMap);
            system.debug('subTypeWithAPIValueMap'+subTypeWithAPIValueMap);
            
            //Construct JSON string based on the data created with custom Settings records. 
            string constructedJson = JsonForEnhancedPicklist.JSONContactsMethod(picklstTypeWithNameMap,typeWithIndex,subTypeWithIndexListMap,typeWithAPIValueMap,subTypeWithAPIValueMap );
           
            system.debug('constructedJson'+constructedJson);

           //Return the constructed string to them flow
            return constructedJson;
           //PK_01
         }
        catch(Exception e){
            if(!Test.isRunningTest()) throw new AuraHandledException(e.getMessage());
            else throw e;
        }
    }  
    
  
    /*
    @AuraEnabled
    public static String getPicklistValues(String sobjectName, String recordTypeId, String recordTypeName){
        try{
            HttpRequest req = new HttpRequest();

            // if recordtypeid is null, use recordtype name to get the id
            if(recordTypeId == null){
                if(recordTypeName == null){
                    throw new RecordTypeValuesCtrlException('Record Type Name is required is Record Type Id is not supplied');
                }
                try{
                    recordTypeId = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                }
                catch(Exception re){
                    throw new RecordTypeValuesCtrlException('Record Type Name ' + recordTypeName + ' is invalid for SObject ' + sobjectName);
                }
            }a

            req.setEndpoint('callout:' + settings.Named_Credential__c + '/services/data/v' + settings.Api_Version__c + '/ui-api/object-info/' + sobjectName + '/picklist-values/' + recordTypeId);
            req.setMethod('GET');

            HttpResponse res = new Http().send(req);
            for(String h : res.getHeaderKeys()){
                System.debug(h + ' => ' + res.getHeader(h));
            }
            RTPL_PicklistValues pl = (RTPL_PicklistValues) JSON.deserialize(res.getBody(), RTPL_PicklistValues.class);
            System.debug(JSON.serialize(pl));
 
            return JSON.serialize(pl);
        }
        catch(Exception e){
            if(!Test.isRunningTest()) throw new AuraHandledException(e.getMessage());
            else throw e;
        }
    }

 */
    public class RecordTypeValuesCtrlException extends Exception{}
}