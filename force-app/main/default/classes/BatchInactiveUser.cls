/***************************************************************
Interface Name : BatchInactiveUser
CreatedDate : 10-Mar-20
*! Description : To mark false the users havent logged in last 180 days
*!               Days are configurable through Custom settings 
* Created By : Sumit Saha

*Revision History

Date Name Story Number Description
* TODO: 03/10/2021 Sumit S |  OCOM-7851  - Develop the process of dormant users
***************************************************************/

/**
 *! Execute => Database.executeBatch(new BatchInactiveUser());
 */


public class BatchInactiveUser implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    Boolean isSuccess = true;
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchInactiveUser(),20);
    }
    
    List<User> listOfInactiveUsers = new List<User>();
    
    String htmlBody  =  '<table border="1" style="border-collapse: collapse"><caption> *** List of Users *** </caption><tr><th>Id</th><th>User Name</th><th> Name</th><th>Last Login Date</th><th>Active</th><th>Profile type</th></tr>';
    
    static Map<String, Inactive_User_Config__c> inactiveUserConfig = Inactive_User_Config__c.getAll();

    String email = String.valueOf( inactiveUserConfig.get('InactiveUser').get('Email__c') );
    Integer retentionDays = Integer.valueOf( inactiveUserConfig.get('InactiveUser').get('Retention_Days__c') );
    String exclusionProfileId = String.valueOf( inactiveUserConfig.get('InactiveUser').get('ExclusionProfileId__c') );

    Date processDate = System.today().addDays(-retentionDays);
    

    public Database.QueryLocator start(Database.BatchableContext bc){
        
        // pulling the eligible users through SOQL
        return Database.getQueryLocator([
        SELECT Id,Name,LastLogindate,UserName,Email,ProfileId,Profile.Name, CreatedDate 
            FROM User 
        WHERE 
            IsActive = True 
            AND ( LastLogindate <=: processDate OR LastLogindate = null ) 
            AND CreatedDate <=: processDate 
            AND ProfileId NOT IN :exclusionProfileId.split(',')
            AND Profile.Name <> null
            AND PermanentUser__c <> true
            ]);
    }
    

    public void execute(Database.BatchableContext bc, List<User> record){

        // Marking them False and creating email body 
        for (User usr : record) {
            usr.IsActive = false;
            listOfInactiveUsers.add(usr);
            
            htmlBody += '<tr><th>'+usr.Id+'</th><th>'+usr.UserName+'</th><th>'+usr.Name+'</th><th>'+usr.LastLoginDate+'</th><th>'+usr.IsActive+'</th><th>'+usr.profile.Name+'</th></tr>';
        }
        
        // DML ~ marking the list of users as False
        if (listOfInactiveUsers.size()>0) {
            try {
                update listOfInactiveUsers;    
            } catch (DmlException e) {
                System.debug(e.getMessage());
                isSuccess = false;
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
        System.debug( listOfInactiveUsers.size() + ' records processed ' );
        System.debug( 'Job Id: '+ bc.getJobId());
        
        // sending the email notification
        If(isSuccess && listOfInactiveUsers.size()>0){
            sendMail( email, listOfInactiveUsers.size() + ' users have been marked as Inactive | JobId: ' + bc.getJobId(), htmlBody);
        }         
    }
    

    private void sendMail(String address, String subject, String body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     
        mail.setToAddresses(address.split(','));
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        Boolean sendResult = true;
        
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        
    }
}