/***************************************************************
Interface Name : LB_SocialPostQuickUpdateController
CreatedDate : 21-Nov-21
Description :  Test class for LB_SocialPostQuickUpdateController
Created By : Poojitha Korrapati

Revision History

Date Name Story Number Description
Pooja | DP-46651  - Social-Ability to label and add sentiment in the current list view

***************************************************************/

@IsTest
public with sharing class LB_SocialPostQuickUpdateControllerTest {
    
    @IsTest
    static void testLookupMethod(){
        test.startTest();
        scs_Social_Label__c  label = new scs_Social_Label__c ();
        label.Name  = 'test';
        label.Type__c = 'Product' ;
        insert label;
        
        scs_Social_Label__c  label2 = new scs_Social_Label__c ();
        label2.Name  = 'LB';
        label2.Type__c = 'Product' ;
        insert label2;
        
        List<sObject> ExcludeitemsList = new  List<sObject>();
        ExcludeitemsList.add(label2);
        LB_SocialPostQuickUpdateController.fetchLookUpValues('test', 'scs_Social_Label__c', ExcludeitemsList);
        test.stopTest();
    }
    
    @IsTest
    static void testUpdateSocialPost(){ 
        
        SocialPost  post = new SocialPost();
        post.Name = 'Test Post';
        post.Posted = system.today();
        Insert post;
        
        
        List<LB_SocialPostQuickUpdateController.Input> inputList = new List<LB_SocialPostQuickUpdateController.Input>();
        LB_SocialPostQuickUpdateController.Input input = new LB_SocialPostQuickUpdateController.Input();
        input.recordIds = post.Id;
        input.selectedSentiment = 'Positive';
        
        inputList.add(input);
        
        test.startTest();        
        LB_SocialPostQuickUpdateController.getPickList();
        
        
        
        List<scs_Social_Label__c>  labels = new List<scs_Social_Label__c> ();
        scs_Social_Label__c  label = new scs_Social_Label__c ();
        label.Name  = 'test';
        label.Type__c = 'Product' ;
        labels.add(label) ;
        
        scs_Social_Label__c  label2 = new scs_Social_Label__c ();
        label2.Name  = 'LB';
        label2.Type__c = 'Product' ;
        labels.add(label2) ;
        
        Insert labels;
        
        
        LB_SocialPostQuickUpdateController.submit(labels, 'Positive', input.recordIds, false);
        LB_SocialPostQuickUpdateController.submit(labels, 'Negative', input.recordIds, true);
        
        test.stopTest();  
        
    }
    
}