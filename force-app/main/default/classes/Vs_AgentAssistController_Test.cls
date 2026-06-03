@IsTest
public with sharing class Vs_AgentAssistController_Test {
    
    @IsTest
    static void testMethodOne(){
       Vs_AgentAssistController.checkAccess();

    }
    
    
     @IsTest
    static void testMethodTwo(){
       
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
 
        insert user;
         
        PermissionSetAssignment paAss = new PermissionSetAssignment();
        paAss.PermissionSetId = [SELECT Id  FROM PermissionSet WHERE  Name = 'Grant_Access_to_Five9_Agent_Assist'].Id;
        paAss.AssigneeId = user.Id;
        insert paAss;
        

 
 
        system.runAs(user){
                Vs_AgentAssistController.checkAccess();
        } 
                    
                 
                     
      

    }
}