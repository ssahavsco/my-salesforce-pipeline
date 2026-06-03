/*******************************************************************
Class Name  : LB_SendCustomNotification 
Author      : Pooja (LB)
Date        : June 26th 2021
Description : Send Custom Notification to Public Groups
JIRA        : OCOM-8032

Revision History : 

*************************************************************************/
public class LB_SendCustomNotification {
    
    
    /*******************************************************************************
* Method        : newsFeedNotification (InvocableMethod)
* Description   : Send news Feed Notification to Department Public Groups
* Date          : July 3rd 2021
* Developer     : Pooja (LB)
* JIRA          : OCOM-8032
*******************************************************************************/
    @InvocableMethod(label='LB - Send News Feed Notification')
    public static void newsFeedNotification(List<id> recordIds){
        
        system.debug('****** recordIds'+recordIds);
        try{
            
            List<News_Feed__c> newsFeedLst = new List<News_Feed__c>();
            newsFeedLst = [Select Id,Name,Departments__c from News_Feed__c Where Id IN: recordIds];
            
            // Get all the Department Names in the set
            set<String> setDepartmentNames = new set<String>();
            For(News_Feed__c news : newsFeedLst){
                List<String> tmpString = new List<String>();
                tmpString.addAll(news.Departments__c.split(';')); 
                setDepartmentNames.addAll(tmpString);           
            }
            
            // Get public group records and create a map to store Group Name and Id
            List<Group> grpLst = new List<Group>([Select Id,Name from Group Where Name IN :setDepartmentNames]);
            Map<string,id> groupNamewithIdMap= new   Map<string,id> ();
            For(Group Gr: grpLst){
                groupNamewithIdMap.put(Gr.Name,Gr.Id);
            }
            
            // Loop News Feed record to send custom notification.
            For(News_Feed__c news : newsFeedLst){
                List<String> departmentList = new List<String>();
                departmentList.addAll(news.Departments__c.split(';')); 
                system.debug('departmentList'+departmentList);                 
                
                //Get all the Department Groups
                set<String> setUserIds = new set<String> ();
                For(string department: departmentList){
                    if(groupNamewithIdMap.containsKey(department)){
                        setUserIds.add(groupNamewithIdMap.get(department));
                    }
                }
                
                system.debug('setUserIds'+setUserIds);
                If(setUserIds != null){
                    //Send Notification to Public Groups
                    sendNotifications(news.Name,news.Id,'Breaking News!','News Feed',setUserIds);
                }
            }
        }Catch(exception e){
            System.debug('***********'+e.getLineNumber()+'***********:'+e.getMessage());
        }
    }
    
    
    
    
    /*******************************************************************************
* Method        : sendNotifications
* Description   : Generic Method to Send Custom Notifications
* Date          : July 3rd 2021
* Developer     : Pooja (LB)
* JIRA          : OCOM-8032
*******************************************************************************/
    public static void sendNotifications(String strBody, String strTargetId, String strTitle, String strNotificationName, set<String> setUserIds) {
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE CustomNotifTypeName=:strNotificationName];
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        // Custom notification type Id
        obj.setNotificationTypeId(notificationType.Id);
        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(strTargetId);
        // Notification Title
        obj.setTitle(strTitle);
        // Notification Body
        obj.setBody(strBody);
        // Actually send the notification
        try {
            // send used to send the notification, pass the set of user ids , Group or Queue member
            obj.send(setUserIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}