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
public class UploadOfferCodesBatchTest {
    static testMethod void successMethod(){
        Test.startTest();
        List<Coupon_Offer__c> offerCodeList = new List<Coupon_Offer__c>();
        Coupon_Offer__c offerCodeObj = new Coupon_Offer__c();
        offerCodeObj.Coupon_Offer_Code__c = 'RCE1201101LLJQRSNDV';
        offerCodeList.add(offerCodeObj);
        
        Coupon_Offer__c offerCodeObj2 = new Coupon_Offer__c();
        offerCodeObj2.Coupon_Offer_Code__c = 'RCE1201101LLJQRVFDV';
        offerCodeList.add(offerCodeObj2);
        
        UploadOfferCodesBatch cb = New UploadOfferCodesBatch(offerCodeList, false);
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,offerCodeList);
        cb.Finish(null);
        
        //Id batchJobId = Database.executeBatch(new UploadOfferCodesBatch(offerCodeList,false), 200);        
        //System.AssertNotEquals(null, batchJobId,'Job Id');
        Test.stopTest();    
    }
    
    static testMethod void testDelete(){
        Test.startTest();        
        List<Coupon_Offer__c> couponCodeList = [SELECT Id FROM Coupon_Offer__c limit 3];
        //Id batchJobId = Database.executeBatch(new UploadOfferCodesBatch(true), 200); 
        UploadOfferCodesBatch cb = New UploadOfferCodesBatch(true);

        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,couponCodeList);
        cb.Finish(null);
        //System.AssertNotEquals(null, batchJobId,'Job Id');
        Test.stopTest();    
    }

}