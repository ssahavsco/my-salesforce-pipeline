/***************************************************************
Interface Name : BatchProcessAccountPhoneSearch_Test
CreatedDate : 10-Mar-20
*? Description : The purpose is to validate the BatchInactiveUser class
* Created By : Sumit Saha

*Revision History

Date Name Story Number Description
* 16-Mar-21 - OCOM-7851  - Develop the process of dormant users
***************************************************************/

@istest
public class BatchProcessAccountPhoneSearch_Test {

    @istest
    /**
     * @description ~ to adjust the  created date in order to validate the BatchInactiveUser class
     * @author Sumit Saha
     */

    static void phoneSearchTestOne(){

       List<Account> listOfTestaccount = TestDataFactoryUser.createAccount(2, true , 'Person Account');
       System.assertEquals( 2,listOfTestaccount.size(), 'Number of Inserted Users');
       listOfTestaccount[0].Phone_Search__c = 'Test';
       listOfTestaccount[0].Phone = '99988898989';
        update listOfTestaccount[0];
       test.startTest();
        Database.executeBatch(new BatchProcessAccountPhoneSearch());
       test.stopTest();
        
    }
    
}