@isTest
public with sharing class AvpCustomerCareBatch_Test {
    static testmethod void test() {
        User u2 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName = 'last2',
                Email = 'test@test.com',
                Username = 'test@test.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );

        

        System.runAs(u2){
            Case cse = new Case();
            insert cse;
            
            Case_Resolution__c resolution = new Case_Resolution__c();
            resolution.Case_Resolution_Type__c = 'Check Refund Request (US)';
            resolution.Approval_Date_Time__c = System.today().addDays(-1);
            resolution.Related_Case__c = cse.Id;
            insert resolution;
        }

        Test.startTest();

        AvpCustomerCareBatch batch = new AvpCustomerCareBatch(); 
        Database.executeBatch(batch, 2000);
          
        String jobId = System.schedule('testBasicScheduledApex', '0 30 2 ? * TUE *',new AvpCustomerCareBatchSchedule());
        Test.stopTest();
    }
}