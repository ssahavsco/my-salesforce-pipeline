/*************************************************************************************
 * Created By - Himanshu - 09/29 [ CCS-166 ]
**************************************************************************************/
@IsTest
public class GetCustomerInfoByHashedCIDBatchTest {
    static testMethod void successMethod(){
        Test.startTest();
        List<String> hashedIdList = new List<String>();
        hashedIdList.add('5be2e4470e08b00a0ba7253009c39339f9fb16df');
        hashedIdList.add('4649e9a8257a6e7c6bf3bacc15270dddf1163247');
        Id batchJobId = Database.executeBatch(new GetCustomerInfoByHashedCIDBatch(hashedIdList,'hmishra@victoria.com'), 200);        
        System.AssertNotEquals(null, batchJobId,'Job Id');
        Test.stopTest();    
    }
}