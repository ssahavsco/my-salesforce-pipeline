/****************************************************************************************************************
* Program Name         : NF_PublicGroupManagerController
* Description          : Controller class for the nf_PublicGroupManager lwc
* Version              : 1.1
* Modification Log     : 12 May, 2021
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer           Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-41622         1.1    Chayan Batabyal     05/12/2021       Controller class for the nf_PublicGroupManager lwc
                                                                                It helps to manage the permission set group assigment
                                                                                as per the different groups the user resides in.
*
*****************************************************************************************************************/
public without sharing class NF_PublicGroupManagerController {
    public static Map<String, List<String>> psgToGroupMapping;
    public static Map<String, Set<Id>> groupToUsers;
    public static SaveChangesWrapper details;
    public static Set<String> associatedPermissionSetGroups = new Set<String>();

    /**
    * @description Fetches all the public groups and other needed configurations from the metadata
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    * @return ResponseWrapper
    **/
    @AuraEnabled
    public static ResponseWrapper fetchAllPublicGroupsAndConfigurations(){
        ResponseWrapper wrap = new ResponseWrapper();
        NF_Public_Group_Manager_Configuration__mdt meta = fetchMetaRecord(
            LABEL.NF_PUBLIC_GROUP_CONFIGURATION_TO_SHOW
        );

        String query = meta.Public_Group_Full_Query__c;
        wrap.publicGroupList = (List<Group>)Database.query(query);

        Map<Id, Group> groupMap = new Map<Id, Group>(wrap.publicGroupList);
        Map<String, List<String>> publicGroupToQueueNames = new Map<String, List<String>>();
        for(GroupMember eachQueueMember: [
            SELECT Group.Name, UserOrGroupId
            FROM GroupMember where Group.Type = 'Queue'
            AND UserOrGroupId IN : groupMap.keySet()
        ]){
            if(!publicGroupToQueueNames.containsKey(eachQueueMember.UserOrGroupId)){
                publicGroupToQueueNames.put(eachQueueMember.UserOrGroupId, new List<String>());
            }
            publicGroupToQueueNames.get(eachQueueMember.UserOrGroupId).add(eachQueueMember.Group.Name);
        }

        wrap.meta = meta;
        wrap.publicGroupToQueueNames = publicGroupToQueueNames;
        wrap.isSuccess = true;
        return wrap;
    }

    /**
    * @description Returns the metadata record for the supplied developerName
    * @author cbatabyal@contractor.lb.com | 05-24-2021
    * @param developerName
    * @return NF_Public_Group_Manager_Configuration__mdt
    **/
    @TestVisible
    private static NF_Public_Group_Manager_Configuration__mdt fetchMetaRecord(String developerName){
        return [
            SELECT Datatable_Column_Structure__c, Filter_Configuration__c,
            Public_Group_Full_Query__c, User_Full_Query__c,
            Profile_Names_For_User_Addition__c, Enable_Only_Active_Users_For_Addition__c,
            Enable_Profile_Filter_For_Users_Addition__c, Datatable_Minimum_Height__c,
            Success_Message__c, Error_Message__c
            FROM NF_Public_Group_Manager_Configuration__mdt
            WHERE DeveloperName =: developerName
            LIMIT 1
        ];
    }

    /**
    * @description Fetches the transferrable users that needs to be displayed on the tab
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    * @param groupId
    * @return ResponseWrapper
    **/
    @AuraEnabled
    public static ResponseWrapper fetchUserDetailsForAGroup(String groupId){
        ResponseWrapper wrap = new ResponseWrapper();

        NF_Public_Group_Manager_Configuration__mdt meta = fetchMetaRecord(
            LABEL.NF_PUBLIC_GROUP_CONFIGURATION_TO_SHOW
        );
        Map<String, List<User>> userMapForAdditionOrRemoval = new Map<String, List<User>>{
            groupId => new List<User>(), 'others' => new List<User>()
        };
        Set<String> profileNamesForAdditionToGroups = new Set<String>(
            meta.Profile_Names_For_User_Addition__c.split(',')
        );
        List<User> userList = (List<User>)Database.query(meta.User_Full_Query__c);
        Map<Id, User> allUserMap = new Map<Id, User>(userList);
        Set<Id> groupMembers = getDirectUsersOfGroup(
            new List<String>{groupId}, new List<String>()
        ).get(groupId);

        for(User eachUser : userList){
            if(groupMembers != null && groupMembers.contains(eachUser.Id)){
                userMapForAdditionOrRemoval.get(groupId).add(eachUser);
            }
            else if((
                (
                    meta.Enable_Only_Active_Users_For_Addition__c &&
                    allUserMap.get(eachUser.Id).IsActive
                ) || !meta.Enable_Only_Active_Users_For_Addition__c
            ) && (
                (
                    meta.Enable_Profile_Filter_For_Users_Addition__c &&
                    profileNamesForAdditionToGroups.contains(
                        allUserMap.get(eachUser.Id).Profile.Name
                    )
                ) || !meta.Enable_Profile_Filter_For_Users_Addition__c
            )){
                userMapForAdditionOrRemoval.get('others').add(eachUser);
            }
        }

        wrap.userMapForAdditionOrRemoval = userMapForAdditionOrRemoval;
        wrap.isSuccess = true;
        return wrap;
    }

    /**
    * @description Fetches the users that are a direct user of the group
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    * @param groupIds
    * @param groupNames
    * @return Map<String, Set<Id>>
    **/
    @TestVisible
    private static Map<String, Set<Id>> getDirectUsersOfGroup(
        List<String> groupIds, List<String> groupNames
    ){
        Map<String, Set<Id>> groupMap = new Map<String, Set<Id>>();

        for(GroupMember eachGroupMember : [
            SELECT GroupId, Group.Name, UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN : groupIds
            OR Group.Name IN : groupNames
        ]){
            if(!groupMap.containsKey(eachGroupMember.GroupId)){
                groupMap.put(eachGroupMember.GroupId, new Set<Id>());
            }
            if(!groupMap.containsKey(eachGroupMember.Group.Name)){
                groupMap.put(eachGroupMember.Group.Name, new Set<Id>());
            }
            if(String.valueOf(eachGroupMember.UserOrGroupId).startsWith('005')){
                groupMap.get(eachGroupMember.GroupId).add(eachGroupMember.UserOrGroupId);
                groupMap.get(eachGroupMember.Group.Name).add(eachGroupMember.UserOrGroupId);
            }
        }
        return groupMap;
    }

    /**
    * @description Trasfers selected users in/out of the group and
    * un/assigns the related permission set group by looking into the metadata
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    * @param detailsToSave
    * @return ResponseWrapper
    **/
    @AuraEnabled
    public static ResponseWrapper saveChanges(Object detailsToSave){
        ResponseWrapper wrap = new ResponseWrapper();

        try{
            psgToGroupMapping = new Map<String, List<String>>();

            details = (SaveChangesWrapper)JSON.deserialize(
                String.valueOf(detailsToSave), SaveChangesWrapper.class
            );

            for(NF_Public_Group_Mapping__mdt eachMapping : [
                SELECT MasterLabel, Permission_Set_Group__r.MasterLabel
                FROM NF_Public_Group_Mapping__mdt
                WHERE MasterLabel =: details.groupName
            ]){
                associatedPermissionSetGroups.add(
                    eachMapping.Permission_Set_Group__r.MasterLabel
                );
            }

            if(details.removedUsers != null && !details.removedUsers.isEmpty()){
                manageUserAndPSGRemoval();
            }

            if(details.addedUsers != null && !details.addedUsers.isEmpty()){
                manageUserAndPSGAddition();
            }

            wrap.toastMessage = details.meta.Success_Message__c.replace('[GROUP_NAME]', details.groupName);
            wrap.isSuccess = true;
        }
        catch(Exception ex){
            String errorMessage = ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
            System.debug('Exception Occured : ' + errorMessage);
            wrap.errorMessage = errorMessage;
        }
        return wrap;
    }

    /**
    * @description Manages the removal of users from the public group
    * and deletion of their Permission Set Group Assignments.
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    **/
    @TestVisible
    private static void manageUserAndPSGRemoval(){
        Set<String> publicGroupNames = new Set<String>();
        List<PermissionSetAssignment> assignmentsToDelete =
            new List<PermissionSetAssignment>();

        if(details.removedUsers != null && !details.removedUsers.isEmpty()){
            for(NF_Permission_Set_Group__mdt eachPSGMeta : [
                SELECT MasterLabel, (
                    SELECT MasterLabel
                    FROM Public_Group_Mappings__r
                )
                FROM NF_Permission_Set_Group__mdt
                WHERE MasterLabel IN : associatedPermissionSetGroups
            ]){
                if(
                    eachPSGMeta.Public_Group_Mappings__r != null &&
                    eachPSGMeta.Public_Group_Mappings__r.size() > 0
                ){
                    psgToGroupMapping.put(eachPSGMeta.MasterLabel, new List<String>());
                    for(
                        NF_Public_Group_Mapping__mdt eachGroup :
                        eachPSGMeta.Public_Group_Mappings__r
                    ){
                        psgToGroupMapping.get(eachPSGMeta.MasterLabel)
                        .add(eachGroup.MasterLabel);
                    }
                    publicGroupNames.addAll(psgToGroupMapping.get(eachPSGMeta.MasterLabel));
                }
            }

            groupToUsers = getDirectUsersOfGroup(
                new List<String>(), new List<String>(publicGroupNames)
            );

            for(PermissionSetAssignment eachAssignment : [
                SELECT AssigneeId, PermissionSetGroup.DeveloperName, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE PermissionSetGroup.DeveloperName IN : associatedPermissionSetGroups
                AND
                AssigneeId IN : details.removedUsers
            ]){
                if(checkForPSADeletion(
                    eachAssignment.AssigneeId, eachAssignment.PermissionSetGroup.DeveloperName
                )){
                    assignmentsToDelete.add(eachAssignment);
                }
            }

            if(!assignmentsToDelete.isEmpty()){
                delete assignmentsToDelete;
            }

            delete [
                SELECT Id FROM GroupMember
                WHERE UserOrGroupId IN : details.removedUsers
                AND GroupId =: details.groupId
            ];
        }
    }

    /**
    * @description Manages the addition of users from the public group
    * and assignment of the associated Permission Set Groups.
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    **/
    @TestVisible
    private static void manageUserAndPSGAddition(){
        List<GroupMember> membersToInsert = new List<GroupMember>();
        List<PermissionSetAssignment> assignmentsToInsert =
            new List<PermissionSetAssignment>();

        if(associatedPermissionSetGroups != null && !associatedPermissionSetGroups.isEmpty()){
            for(PermissionSetGroup eachPSG : [
                SELECT Id
                FROM PermissionSetGroup
                WHERE DeveloperName IN : associatedPermissionSetGroups
            ]){
                for(String eachUserId : details.addedUsers){
                    assignmentsToInsert.add(new PermissionSetAssignment(
                        AssigneeId = eachUserId,
                        PermissionSetGroupId = eachPSG.Id
                    ));
                }
            }
        }

        if(!assignmentsToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(assignmentsToInsert, false);

            if(srList != null && !srList.isEmpty()){
                for(Database.SaveResult eachResult : srList){
                    if(!eachResult.isSuccess()){
                        for(Database.Error err : eachResult.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ' : ' + err.getMessage());
                        }
                    }
                }
            }
        }

        for(String eachUserId : details.addedUsers){
            membersToInsert.add(new GroupMember(
                UserOrGroupId = eachUserId,
                GroupId = details.groupId
            ));
        }
        insert membersToInsert;
    }

    /**
    * @description Checks if the PSG Assignments is only through a single public group
    * or there are other public groups under the particular PSG. PSG assignment is deleted
    * only if the user is not a member of any other public group under that particular PSG.
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    * @param userIdToCheck
    * @param permissionGroupName
    * @return Boolean
    **/
    @TestVisible
    private static Boolean checkForPSADeletion(String userIdToCheck, String permissionGroupName){
        List<String> publicGroupsUnderPSG = psgToGroupMapping.get(permissionGroupName);

        if(publicGroupsUnderPSG != null && !publicGroupsUnderPSG.isEmpty()){
            for(String eachGroup : publicGroupsUnderPSG){
                if(
                    groupToUsers != null && groupToUsers.containsKey(eachGroup) &&
                    groupToUsers.get(eachGroup) != null && !groupToUsers.get(eachGroup).isEmpty()
                ){
                    for(Id eachUserId : groupToUsers.get(eachGroup)){
                        if(eachUserId == userIdToCheck && eachGroup != details.groupName){
                            return false;
                        }
                    }
                }
            }
        }
        return true;
    }

    public class SaveChangesWrapper{
        public String groupId;
        public String groupName;
        public List<String> removedUsers;
        public List<String> addedUsers;
        public NF_Public_Group_Manager_Configuration__mdt meta;
    }

    public class ResponseWrapper{
        @AuraEnabled
        public Boolean isSuccess = false;

        @AuraEnabled
        public String toastMessage;

        @AuraEnabled
        public String errorMessage;

        @AuraEnabled
        public List<Group> publicGroupList = new List<Group>();

        @AuraEnabled
        public Map<String, List<User>> userMapForAdditionOrRemoval = new Map<String, List<User>>();

        @AuraEnabled
        public NF_Public_Group_Manager_Configuration__mdt meta;

        @AuraEnabled
        public Map<String, List<String>> publicGroupToQueueNames;
    }
}