/*******************************************************************
Class Name  : NewsFeedTriggerHandler 
Author      : Sumit Saha
Date        : July 02 2021
Description : DP-41405: Create Security for News Feed Records
JIRA        : OCOM-8039

Revision History : 

*************************************************************************/

public with sharing class NewsFeedTriggerHandler extends NF_TriggerHandler {

    public static Boolean triggerDisabled = false;

    /**
     * @description isDisabled ~ Checks to see if the trigger has been disabled either by custom setting or by running code
     * @author Author Sumit Saha
     */

    public override Boolean isDisabled() {
       TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance('NewsFeedTriggerHandler');
       if(triggerSettings != null){
           if(triggerSettings.IsDisabled__c){
               triggerDisabled = true;
           }
       }
       return triggerDisabled;
   }

    /**
     * @description beforeUpdate ~ to adjust the data before updating the records
     * @author Author Sumit Saha
     */

   public override void beforeUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){

        Map<Id, News_Feed__c> mapNewsFeed = (Map<Id, News_Feed__c>) newMap;

        System.debug(mapNewsFeed.size());

        for (News_Feed__c key : mapNewsFeed.values()) {
            System.debug(key.get('Departments__c'));

            /* Everytime marking all the checkbox as False while the existing records are updated */

            key.Department_ALL__c = False;
            key.Department_Bilingual__c = False;
            key.Department_Chat__c = False;
            key.Department_Edit_Enterprise_Correspondenc__c = False;
            key.Department_Email__c = False;
            key.Department_Phone_All__c = False;
            key.Department_Phone_LiveOps_Agents_ONLY__c = False;
            key.Department_Phone_VS_Associates_ONLY__c = False;
            key.Department_Resolution_Team__c = False;
            key.Department_Social_Media__c = False;
            key.Department_Special_Handling__c = False;
            key.Department_VSS__c = False;
            key.Department_Chat_Level_A__c = False;
            key.Department_Phone_Level_A__c = False;

            if (key.get('Departments__c') != null) {

                /* Based on selected dept marking the checkbox as True */
                List<String> departName =  ((String) key.get('Departments__c')).split(';');

                    for (String str : departName) {
                        
                        switch on str {
                            when 'ALL' {
                                key.Department_ALL__c = True;
                            }
                            when 'ALL CCS Only' {
                                key.Department_ALL_CCS_Only__c = True;
                            }
                            when 'Bilingual' {
                                key.Department_Bilingual__c = True;
                            }
                            when 'Chat' {
                                key.Department_Chat__c = True;
                            }
                            when 'Enterprise Correspondence' {
                                key.Department_Edit_Enterprise_Correspondenc__c = True;
                            }
                            when 'Email' {
                                key.Department_Email__c = True;
                            }
                            when 'Phone-All' {
                                key.Department_Phone_All__c = True;
                            }
                            when 'Phone-LiveOps Agents ONLY' {
                                key.Department_Phone_LiveOps_Agents_ONLY__c = True;
                            }
                            when 'Phone-VS Associates ONLY' {
                                key.Department_Phone_VS_Associates_ONLY__c = True;
                            }
                            when 'Resolution Team' {
                                key.Department_Resolution_Team__c = True;
                            }
                            when 'Social Media' {
                                key.Department_Social_Media__c = True;
                            }
                            when 'Special Handling' {
                                key.Department_Special_Handling__c = True;
                            }
                            when 'VSS' {
                                key.Department_VSS__c = True;
                            }
                            when 'Chat-Level A' {
                                key.Department_Chat_Level_A__c = True;
                            }
                            when 'Phone-Level A' {
                                key.Department_Phone_Level_A__c = True;
                            }
                            when else {
                                System.debug('Default::' +  str);
                            }
                        }
                     }
            }                
        }

   } 

    /**
     * @description beforeUpdate ~ to adjust the data before inserting the records
     * @author Author Sumit Saha
     */

   public override void beforeInsert(List<sObject> newList ){

        List<News_Feed__c> listName = (List<News_Feed__c>) newList;

            for (News_Feed__c nf : listName) {
                System.debug(nf.get('Departments__c'));

                if (nf.get('Departments__c') != null) {

                   /* Based on selected dept marking the checkbox as True */

                    String multiPickListDept = (String) nf.get('Departments__c');
                    List<String> listDept = new List<String>(multiPickListDept.split(';'));
                    System.debug(listDept);
                    
                    for (String str : listDept) {
                        switch on str {
                            
                            when 'ALL' {
                                nf.Department_ALL__c  = True;
                            }
                            when 'ALL CCS Only' {
                                 nf.Department_ALL_CCS_Only__c  = True;
                            }
                            when 'Bilingual' {
                                 nf.Department_Bilingual__c  = True;
                            }
                            when 'Chat' {
                                 nf.Department_Chat__c  = True;
                            }
                            when 'Enterprise Correspondence' {
                                 nf.Department_Edit_Enterprise_Correspondenc__c = True;
                            }
                            when 'Email' {
                                 nf.Department_Email__c = True;
                            }
                            when 'Phone-All' {
                                nf.Department_Phone_All__c = True;
                            }
                            when 'Phone-LiveOps Agents ONLY' {
                                nf.Department_Phone_LiveOps_Agents_ONLY__c = True;
                            }
                            when 'Phone-VS Associates ONLY' {
                                nf.Department_Phone_VS_Associates_ONLY__c = True;
                            }
                            when 'Resolution Team' {
                                nf.Department_Resolution_Team__c = True;
                            }
                            when 'Social Media' {
                                nf.Department_Social_Media__c = True;
                            }
                            when 'Special Handling' {
                                nf.Department_Special_Handling__c = True;
                            }
                            when 'VSS' {
                                nf.Department_VSS__c = True;
                            }
                            when 'Chat-Level A' {
                                nf.Department_Chat_Level_A__c = True;
                            }
                            when 'Phone-Level A' {
                                nf.Department_Phone_Level_A__c = True;
                            }
                            when else {
                                System.debug('Default:: '+str);
                            }
                        }
                    }
                }               
            }
     }
}