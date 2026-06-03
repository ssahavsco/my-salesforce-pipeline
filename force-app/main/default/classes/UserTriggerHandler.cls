/***************************************************************
Interface Name : UserTriggerHandler
CreatedDate : 01-Aug-21
*! Description : to determine the public group based on associate level selection 
* Created By : Sumit Saha

*Revision History

Date Name Story Number Description
* TODO: 01/08/2021 Sumit Saha |  DP-41457/ OCOM-8039  - Create Security for News Feed Records
***************************************************************/

public with sharing class UserTriggerHandler extends NF_TriggerHandler {

    public static Boolean triggerDisabled = false;

    /**
     * @description isDisabled ~ Checks to see if the trigger has been disabled either by custom setting or by running code
     * @author Author Sumit Saha
     */

    public override Boolean isDisabled() {
        TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance('UserTriggerHandler');
        if(triggerSettings != null){
            if(triggerSettings.IsDisabled__c){
                triggerDisabled = true;
            }
        }
        return triggerDisabled;
    }

    public override void afterInsert(Map<Id, sObject> newMap){

        Map<Id,User> newuser = ( Map<Id,User>) newMap;
        Set<ID> setUserId = new Set<Id>();

        for (User key : newuser.values()) {
            setUserId.add((Id) key.get('Id'));
        }

        insertGroup(setUserId);

    }


    public override void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){

        Map<Id,User> newuser = ( Map<Id,User>) newMap;
        Map<Id,User> olduser = ( Map<Id,User>) oldMap;

        Set<ID> setUserId = new Set<Id>();

       deleteFromGroup(newuser,olduser);
      
        for (User key : newuser.values()) {
            setUserId.add((Id) key.get('Id'));
        }

      insertGroup(setUserId);
    }

    /**
     * @description deleteFromGroup method will remove the users from existing groups
     * @author Sumit Saha
     */
    public static void deleteFromGroup(Map<Id,User> newuser, Map<Id,User> olduser){

        Set<ID> setGroupId = new Set<Id>();
        Set<ID> setUserId = new Set<Id>();

        System.debug(newuser.size());

        Map<String,Associate_Level_Map__mdt> associateLevelMap = Associate_Level_Map__mdt.getall();
        Group[] allGroups = [SELECT Id, DeveloperName from Group ];
        
            for (User key : newuser.values()) {
                      
                    if (key.get('Associate_Level__c') != olduser.get(key.Id).Associate_Level__c) {
                        
                        /* determine the group name after comparing with custom metedata */
                        for (Associate_Level_Map__mdt str : associateLevelMap.values()) {
                            if (olduser.get(key.Id).Associate_Level__c == str.get('ASSOCIATE_LEVEL_FIELD__c')) {
 
                                for (Group gr : allGroups) {
                                    if (gr.DeveloperName == str.get('Group_Name__c')) {
                                        System.debug('Group Id:' + gr.Id);
                                        setGroupId.add(gr.Id);
                                        setUserId.add((Id) key.get('Id'));
                                    }
                                }
                            }
                        }                        
                    }    
                setUserId.add((Id) key.get('Id'));                                     
            }

        List<GroupMember> listGroupMembers  = [ SELECT Id from GroupMember where UserOrGroupID in :setUserId and GroupId  in :setGroupId ];
        
            if (listGroupMembers.size() > 0) {
                try {
                    delete listGroupMembers;
                } catch (DmlException e) {
                    System.debug(e.getMessage());
                }
                
            }
    }

    /**
     * @description insertGroup method will insert the users based on their associate level selection
     * @author Sumit Saha
     */
    @future
    public static void insertGroup( Set<Id> setUserId){

        List<User> usr  = [SELECT Id, Name, Associate_Level__c from User where Id in :setUserId];

        Map<String,Associate_Level_Map__mdt> associateLevelMap = Associate_Level_Map__mdt.getall();

        List<GroupMember> listGroupMembers = new List<GroupMember>();

        Group[] allGroups = [SELECT Id, DeveloperName from Group ];

        for (User user : usr) {

            if (user.Associate_Level__c != null) {
                                        
                /* determine the group name after comparing with custom metedata */
                for (Associate_Level_Map__mdt str : associateLevelMap.values()) {
                    if (user.Associate_Level__c == str.get('ASSOCIATE_LEVEL_FIELD__c')) {
                        
                        GroupMember gm = new GroupMember();
    
                        for (Group grp : allGroups) {
                            if (grp.DeveloperName == str.get('Group_Name__c')) {
                                gm.GroupId = grp.Id;
                                gm.UserOrGroupId = user.Id;
                                listGroupMembers.add(gm);
                            }
                        }
                    }
                }
            }
        }

        Database.SaveResult[] srList = Database.insert(listGroupMembers, false);
       
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {                
                System.debug('Successfully Inserted --> GroupMember.Id ' + sr.getId());
            }
            else {                             
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.'  );                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(' fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}