/*************************************************************************************
 * Created By - Himanshu - 09/29 [ CCS-166 ]
 * 
 * 
**************************************************************************************/
@IsTest
public class GetCustomerInfoByHashedCIDControllerTest {
    
    static testMethod void successMethod(){
        Test.startTest();
        String csvContent = 'HashedId'+'\n'+'5be2e4470e08b00a0ba7253009c39339f9fb16df'+'\n'+'4649e9a8257a6e7c6bf3bacc15270dddf1163247';
        Id jobId = GetCustomerInfoByHashedCIDController.processInputFile(csvContent,'hmishra@victoria.com');
        System.AssertNotEquals(null, jobId,'Job Id');
        List<AsyncApexJob> jobDetails = GetCustomerInfoByHashedCIDController.getJobDetails(jobId);
        System.AssertNotEquals(null, jobDetails);
        Test.stopTest();    
    }
    
    static testMethod void failureMethod(){
        Test.startTest();
        String csvContent = '';
        try{
            Id jobId = GetCustomerInfoByHashedCIDController.processInputFile(csvContent,'hmishra@victoria.com');
            List<AsyncApexJob> jobDetails = GetCustomerInfoByHashedCIDController.getJobDetails('testId');
            List<AsyncApexJob> emptyList = new List<AsyncApexJob>();
            System.AssertEquals(emptyList, jobDetails);
        } catch(Exception e){}
        Test.stopTest();
    }
}