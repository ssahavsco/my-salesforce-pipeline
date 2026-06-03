/***************************************************************
Interface Name : TestExecuteUser
CreatedDate : 10-Mar-20
*? Description : The purpose is to validate the BatchInactiveUser class
* Created By : Sumit Saha

*Revision History

Date Name Story Number Description
* 16-Mar-21 - OCOM-7851  - Develop the process of dormant users
***************************************************************/

@istest
public class BatchInactiveUserTest {

    @istest
    /**
     * @description ~ to adjust the  created date in order to validate the BatchInactiveUser class
     * @author Sumit Saha
     */

    static void batchInactiveUser(){

       List<User> listOfTestUser = TestDataFactoryUser.createUser(5);
       System.assertEquals( 5,listOfTestUser.size(), 'Number of Inserted Users');
       
       // Adjusting the User Created date to satisfy the Batch condition
        for (Integer i = 0; i < listOfTestUser.size(); i++) {
            Test.setCreatedDate(listOfTestUser[i].Id, DateTime.newInstance(2020,06,12));
        }

       // Custom setting "Inactive_User_Config__c" needs these values before calling the batch class
       Insert new Inactive_User_Config__c(Name='InactiveUser',Email__c='ssaha@lb.com', ExclusionProfileId__c='00e3h000000ljQWAAY,00e3h000000ljQXAAY,00e3h000000lmXoAAI,00e3h000000lmtzAAA,00e3h000001EpqQAAS,00e3h000001EpqRAAS,00e3h000001EpqcAAC', Retention_Days__c = '180');
       
       test.startTest();
        Database.executeBatch(new BatchInactiveUser());
       test.stopTest();
        
    }
    
}