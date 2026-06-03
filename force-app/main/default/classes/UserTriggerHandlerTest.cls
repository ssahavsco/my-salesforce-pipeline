/***************************************************************
Interface Name : UserTriggerHandlerTest
CreatedDate : 01-Aug-21
Description :  
Created By : Sumit Saha

Revision History

Date Name Story Number Description
* TODO: 01/08/2021 Sumit Saha |  DP-41457/ OCOM-8039  - Create Security for News Feed Records

***************************************************************/

@isTest
public with sharing class UserTriggerHandlerTest {

    @isTest
    static string createTestUser(){

        User user = new User();
        user.ProfileId = [Select Id from Profile  where Name = 'Chat Associate'].Id;
        user.LastName = 'last';
        user.Email = 'test@test.com';
        user.Username = 'test@test.com' + System.currentTimeMillis();
        user.CompanyName = 'TEST';
        user.Title = 'title';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.UserRoleId = [Select Id from UserRole where Name = 'Customer Care Chat Associate'].Id;
        user.Associate_Level__c = 'Chat Associate';

        insert user;
        System.assertNotEquals(null, user, 'should have value');

        return (String) user.id;

    }

    @isTest
    static void updateTestUser(){

        User user = new User();

        user.Id = createTestUser();
        user.ProfileId = [Select Id from Profile  where Name = 'Chat Associate'].Id;
        user.LastName = 'last';
        user.Email = 'test@test.com';
        user.Username = 'test@test.com' + System.currentTimeMillis();
        user.CompanyName = 'TEST';
        user.Title = 'title';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.UserRoleId = [Select Id from UserRole where Name = 'Customer Care Chat Associate'].Id;
        user.Associate_Level__c = 'LiveOps Core';

        update user;

        System.assertNotEquals(null, user, 'should have value');
    }

}