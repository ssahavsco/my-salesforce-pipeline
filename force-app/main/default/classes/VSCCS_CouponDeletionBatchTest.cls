/****************************************************************************************************************
* Program Name         : VSCCS_CouponDeletionBatch
* Description          : Provide coverage to VSCCS_CouponDeletionBatch.
* Version              : 1.0
* Modification Log     : 12 November, 2025
*------------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*  CCS-1413      1.0       Himanshu Mishra        12/11/2025     Provide coverage to VSCCS_CouponDeletionBatch.   
*                                                                                                                                                                                                 
*****************************************************************************************************************/
@IsTest
public with sharing class VSCCS_CouponDeletionBatchTest {
    static testMethod void deleteDomesticCoupons(){
        Test.startTest();
        	List<Coupon_Offer__c> couponList = createTestRecord();
            VSCCS_CouponDeletionBatch cb = New VSCCS_CouponDeletionBatch(true, false);
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null, couponList);
            cb.Finish(null);
        Test.stopTest();
    }
    static testMethod void deleteIntlCoupons(){
        Test.startTest();
        	List<Coupon_Offer__c> couponList = createTestRecord();
            VSCCS_CouponDeletionBatch cb = New VSCCS_CouponDeletionBatch(false, true);
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null, couponList);
            cb.Finish(null);
        Test.stopTest();
    }
        
    public static List<Sobject> createTestRecord(){
        List<Coupon_Offer__c> couponList = new List<Coupon_Offer__c>();
        Coupon_Offer__c couponObj = new Coupon_Offer__c();
        couponObj.Coupon_Offer_Code__c = 'ABC';
        couponList.add(couponObj);
        
        Coupon_Offer__c couponObj2 = new Coupon_Offer__c();
        couponObj2.Coupon_Offer_Code__c = 'XYZ';
        couponObj2.Is_International__c = true;
        couponList.add(couponObj2);
        insert couponList;
        
        return [Select Id from Coupon_Offer__c];
    }
}