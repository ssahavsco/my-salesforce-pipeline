/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Offer Code Utility class 	[ CCS-216 ]
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Himanshu Mishra  <hmishra@victoria.com>
* @version        1.0
* @created        01/11/2024
* @modified       01/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest
public class UploadOfferCodesControllerTest {
    static testMethod void testInsert(){
        Test.startTest();
        String csvContent = 'CouponCode'+'\n'+'RCE1201101LLJQRSNDV'+'\n'+'RCE1201101LLJQRVFDV';
        Id jobId = UploadOfferCodesController.processInputFile(csvContent,false,false);
        System.AssertNotEquals(null, jobId,'Job Id');
        List<AsyncApexJob> jobDetails = UploadOfferCodesController.getJobDetails(jobId);
        System.AssertNotEquals(null, jobDetails);
        Test.stopTest();    
    }

    static testMethod void testDelete(){
        Test.startTest();
        String csvContent = '';
        Id jobId = UploadOfferCodesController.processInputFile(csvContent,true,true);
        System.AssertNotEquals(null, jobId,'Job Id');
        List<AsyncApexJob> jobDetails = UploadOfferCodesController.getJobDetails(jobId);
        System.AssertNotEquals(null, jobDetails);
        Test.stopTest();    
    }
    
    static testMethod void failureMethod(){
        Test.startTest();
        String csvContent = '';
        try{
            Id jobId = UploadOfferCodesController.processInputFile(csvContent,false,true);
            List<AsyncApexJob> jobDetails = UploadOfferCodesController.getJobDetails('testId');
            List<AsyncApexJob> emptyList = new List<AsyncApexJob>();
            System.AssertEquals(emptyList, jobDetails);
        } catch(Exception e){}
        Test.stopTest();
    }

}