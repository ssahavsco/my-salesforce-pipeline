/*****************************************************************************************************@@
Class Name     :  NF_ProcessCCPaymentTest
Purpose        :  Class to test NF_ProcessCCPayment class
History:
-------
VERSION  AUTHOR                   DATE                	DETAIL                      	TICKET REFERENCE/ NO.
1.       zali              	    2/14/2022            Original Version             			   	DP-49936
       
*********************************************************************************************************/
@isTest
public with sharing class NF_ProcessCCPaymentTest {
    @TestSetup
    static void makeData(){
        LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
        LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.AO_Domain__c = 'https://lmits.omni.manh.com';
        LBrandCustomS.Host__c = 'apitest.victoriassecret.com';
        LBrandCustomS.All_Logging__c = true;
        LBrandCustomS.Error_Logging__c = true;
        insert LBrandCustomS;
    }
    @isTest
    static void getPaymentLink(){
        String testOrderNumber ='W009319980';
        List<String> orderNumberList = new List<String>();
        orderNumberList.add(testOrderNumber);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_ProcessCCPaymentMockAPI());
        NF_ProcessCCPayment.getPaymentLink(orderNumberList);
        //system.assertEquals(expected, testURL)
        Test.stopTest();
    }
    @istest
    static void testException(){
        Test.startTest();
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = '12345';
        insert session;
        NF_ProcessCCPayment.chatKey = '12345';
        NF_ProcessCCPayment.parseException(new System.DmlException(), '123456');
        test.stopTest();
    }

}