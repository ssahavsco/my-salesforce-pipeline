/***************************************************************
Interface Name : LB_SocialPostQuickUpdateController
CreatedDate : 21-Nov-21
Description :  
Created By : Poojitha Korrapati

Revision History

Date Name Story Number Description
Pooja | DP-46651  - Social-Ability to label and add sentiment in the current list view

***************************************************************/

public class LB_SocialPostQuickUpdateController {
    //Input Variables
    public class Input{
        @InvocableVariable(required=true)
        public String recordIds;
        
        @InvocableVariable(required=true)
        public string selectedSentiment;
    }
    
    
    //Method to handle labels lookup search
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
      
   
    
    @AuraEnabled //get Account Industry Picklist Values
    public static Map<String, String> getPickList(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = SocialPost.Sentiment.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            if(p.getLabel() == 'Positive' || p.getLabel() == 'Negative'){
                options.put(p.getValue(), p.getLabel());
            }
        }
        return options;
    }
    
    //Method to update Social Post sentiment picklist and Insert Lables
    @AuraEnabled
    public static void submit(List<sObject> labels, string selectedSentiment, string recordIds, boolean isIgnore) {
        
        
        system.debug('labels'+labels);
        system.debug('selectedSentiment'+selectedSentiment);
        system.debug('recordIds'+recordIds);
        system.debug('isIgnore'+isIgnore);
        
        List<Post_Label__c> postLabelToInsert = new    List<Post_Label__c>();
        List<SocialPost> socialPostToUpdate = new    List<SocialPost>();
        List<SocialPost> socialPostIgnoreToUpdate = new    List<SocialPost>();
        List<id> recordIdLst = recordIds.split(',');
        
        //Loop Social Post selected when flow initiation
        For(SocialPost socPost: [Select Id,Name,Sentiment  from SocialPost where Id In : recordIdLst]){
            
            If(selectedSentiment != null && selectedSentiment != ''){
                SocialPost socialPost = new SocialPost();
                
                system.debug('selectedSentiment_______'+selectedSentiment);
                socialPost.id = socPost.id;
                socialPost.Sentiment = selectedSentiment;
                socialPostToUpdate.add(socialPost);
            }
            
            
            If(isIgnore){
                SocialPost socialPost = new SocialPost();
                
                socialPost.id = socPost.id;
                socialPost.ReviewedStatus = 'Ignore';
                socialPostIgnoreToUpdate.add(socialPost);
            }
            
            
            //Loop Social Labels selected by user and Insert Post_labels
            For(scs_Social_Label__c  socLab: [Select Id,Name from scs_Social_Label__c  where Id In: labels]){
                Post_Label__c postLabel = new Post_Label__c();
                postLabel.Post__c   = socPost.Id;
                postLabel.scs_Label__c   = socLab.Id;
                postLabel.Name   = socLab.Name;
                postLabelToInsert.add(postLabel);
            }
            
        }
        system.debug('socialPostToUpdate********'+socialPostToUpdate);
        
        //Update Social Post with Sentiment
        If(!socialPostToUpdate.isEmpty()){
            Update socialPostToUpdate;
        }
        
         
        //Update Social Post with Sentiment
        If(!socialPostIgnoreToUpdate.isEmpty()){
            Update socialPostIgnoreToUpdate;
        }
        
        system.debug('postLabelToInsert********'+postLabelToInsert);
        
        //Insert Post Label 
        If(!postLabelToInsert.isEmpty()){
            insert postLabelToInsert;
        }
        
        
    }
    
     
    
}