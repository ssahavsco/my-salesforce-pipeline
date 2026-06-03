/****************************************************************************************************************
* Program Name         : NF_PublicGroupManagerControllerTest
* Description          : Test class for the NF_PublicGroupManagerController class
* Version              : 1.1
* Modification Log     : 21 May,2021
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer           Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-41622         1.1    Chayan Batabyal     21 May,2021      Test the working of the NF_PublicGroupManagerController class
*
*****************************************************************************************************************/
@isTest(seeAllData = false)
public with sharing class NF_PublicGroupManagerControllerTest {
    /**
    * @description Setup data method
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    **/
    @TestSetup
    static void makeData(){
        Map<String, List<String>> psgToGroupMapping = new Map<String, List<String>>();
        Set<String> publicGroupNames = new Set<String>();
        Group grp;

        for(NF_Public_Group_Mapping__mdt grpMapping : [
            SELECT DeveloperName, MasterLabel, Permission_Set_Group__r.MasterLabel
            FROM NF_Public_Group_Mapping__mdt
            ORDER BY Id
            LIMIT 1
        ]){
            grp = new Group(
                Name = grpMapping.MasterLabel,
                DeveloperName = grpMapping.DeveloperName
            );
        }

        List<Group> grpList = [
            SELECT Id FROM Group WHERE Name =: grp.Name
            AND DeveloperName =: grp.DeveloperName
        ];
        if(grpList == null || grpList.isEmpty()){
            insert grp;
        }
    }

    /**
    * @description Test the fetchAllPublicGroupsAndConfigurations
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    **/
    public static testMethod void fetchAllPublicGroupsAndConfigurationsTest(){
        Test.startTest();

        NF_PublicGroupManagerController.ResponseWrapper wrap =
            NF_PublicGroupManagerController.fetchAllPublicGroupsAndConfigurations();

        System.assert(
            !wrap.publicGroupList.isEmpty(), 'Public Group exists'
        );

        Test.stopTest();
    }

    /**
    * @description Test the fetchUserDetailsForAGroup
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    **/
    public static testMethod void fetchUserDetailsForAGroupTest(){
        Test.startTest();

        NF_Public_Group_Mapping__mdt meta = [
            SELECT MasterLabel
            FROM NF_Public_Group_Mapping__mdt
            ORDER BY Id
            LIMIT 1
        ];

        Group insertedGroup = [SELECT Id, Name FROM Group WHERE Name =: meta.MasterLabel LIMIT 1];

        NF_PublicGroupManagerController.ResponseWrapper wrap =
            NF_PublicGroupManagerController.fetchUserDetailsForAGroup(insertedGroup.Id);

        System.assert(
            !wrap.userMapForAdditionOrRemoval.get('others').isEmpty(), 'Users are addable'
        );

        Test.stopTest();
    }

    /**
    * @description Test the saveChangesMethod
    * @author cbatabyal@contractor.lb.com | 05-21-2021
    **/
    public static testMethod void saveChangesTest(){
        NF_PublicGroupManagerController.SaveChangesWrapper saveWrap =
            new NF_PublicGroupManagerController.SaveChangesWrapper();
        saveWrap.meta = NF_PublicGroupManagerController.fetchMetaRecord(
            LABEL.NF_PUBLIC_GROUP_CONFIGURATION_TO_SHOW
        );

        User newUser = new User(
            Alias = 'testcc',
            Email='testchayancc@lb.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = [
                Select Id
                FROM Profile
                WHERE Name =: saveWrap.meta.Profile_Names_For_User_Addition__c.split(',')[0]
                LIMIT 1
            ].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testchayancc@lb.com'
        );
        insert newUser;

        Test.startTest();

        NF_Public_Group_Mapping__mdt meta = [
            SELECT MasterLabel
            FROM NF_Public_Group_Mapping__mdt
            ORDER BY Id
            LIMIT 1
        ];

        Group insertedGroup = [SELECT Id, Name FROM Group WHERE Name =: meta.MasterLabel LIMIT 1];

        saveWrap.removedUsers = new List<String>();
        saveWrap.addedUsers = new List<String>{newUser.Id};
        saveWrap.groupId = insertedGroup.Id;
        saveWrap.groupName = insertedGroup.Name;


        NF_PublicGroupManagerController.ResponseWrapper wrap =
            NF_PublicGroupManagerController.saveChanges(JSON.serialize(saveWrap));

        System.assert(wrap.isSuccess, 'User Addition Successful.');

        saveWrap.removedUsers = new List<String>{newUser.Id};
        saveWrap.addedUsers = new List<String>();

        wrap =
            NF_PublicGroupManagerController.saveChanges(JSON.serialize(saveWrap));

        System.assert(wrap.isSuccess, 'User Removal Successful.');

        wrap =
            NF_PublicGroupManagerController.saveChanges(saveWrap);
        System.assert(!wrap.isSuccess, 'Operation Unsuccessful.');

        Test.stopTest();
    }
}