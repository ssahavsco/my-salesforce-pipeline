/*******************************************************************
Class Name  : NewsFeedTriggerHandlerTest 
Author      : Sumit Saha
Date        : July 02 2021
Description : NewsFeedTriggerHandlerTest is used to validate NewsFeedTriggerHandler.cls

Revision History : 

*************************************************************************/

@isTest
public with sharing class NewsFeedTriggerHandlerTest {
    
    /**
     * @description testInsertNewsFeed to insert the News Feed
     * @author Author Sumit Saha
     * @return   returning the News Feed Id
     */
    @isTest
    static String testInsertNewsFeed()
    {
        News_Feed__c newsFeed = new  News_Feed__c();

        String str = 'ALL;ALL CCS Only;Bilingual;Chat;Email;Enterprise Correspondence;Phone-All;Phone-LiveOps Agents ONLY;Phone-VS Associates ONLY;Resolution Team;Social Media;Special Handling;VSS';
        newsFeed.Name = 'Test';
        newsFeed.Departments__c = str;
        Insert newsFeed;
        
        system.assertEquals(str, newsFeed.Departments__c, 'Passed');

        return newsFeed.id;
    }


    /**
     * @description testUpdateNewsFeed to update the News Feed
     * @author Author Sumit Saha
     */
    @isTest
    static void testUpdateNewsFeed()
    {

        News_Feed__c newsFeed = new  News_Feed__c();
        String str = 'ALL;ALL CCS Only;Bilingual;Chat;Email;Enterprise Correspondence;Phone-All;Phone-LiveOps Agents ONLY;Phone-VS Associates ONLY;Resolution Team;Social Media;Special Handling;VSS';


        newsFeed.Id = testInsertNewsFeed();
        newsFeed.Departments__c = str;
        update newsFeed;

        system.assertEquals(str, newsFeed.Departments__c, 'Passed');

    }


}