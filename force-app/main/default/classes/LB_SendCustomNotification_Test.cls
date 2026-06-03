/*******************************************************************
Class Name  : LB_SendCustomNotification_Test
Author      : Pooja (LB)
Date        : June 30th 2021
Description : Test clas for RecordViewCounterController
JIRA        : OCOM-8032

Revision History : 

*************************************************************************/
@isTest
public class LB_SendCustomNotification_Test {
    
    static testMethod  void testMethodtwo() {
        News_feed__c news = new News_feed__c();
        news.Name = 'Test News';
        news.Published_Dates__c = system.today();
         news.Departments__c = 'Email';
        Insert news;
        
        Group grp = new Group ();
        grp.Name = 'Email';
        Insert grp;
        
        List<id> recordIds  = new List<Id>();
        recordIds.add(news.id);
        LB_SendCustomNotification.newsFeedNotification(recordIds);
        
    }
    
}