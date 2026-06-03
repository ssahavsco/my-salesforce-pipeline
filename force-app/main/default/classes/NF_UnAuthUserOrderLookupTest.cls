/**
 * @description       : 
 * @author            : NeuraFlash - Apoorv Rajput
 * @group             : 
 * @last modified on  : 08-28-2020
 * @last modified by  : NeuraFlash - Apoorv Rajput
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   08-28-2020   NeuraFlash - Apoorv Rajput   Initial Version
**/

@isTest
public with sharing class NF_UnAuthUserOrderLookupTest {

    Integer statuscode;
   	  @testSetup public static void setup(){
        
        LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
        LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.Client_Secret__c = 'eJv4s59Hd7Y7lzIjJboqJwhTIVS4';
        LBrandCustomS.Client_ID__c = 'sfccs';
        insert LBrandCustomS;
    }
	    @isTest
    static void testpass_1(){
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        Test.startTest();
        NF_UnAuthUserOrderLookup.Input input = new NF_UnAuthUserOrderLookup.Input();
        input.chatKey = 'abc';
        input.email = 'test@neuraflash.com';
        input.phoneNumber = '5551231234';
        input.zipCode = '12345';
        input.orderId = '123';
        input.isOrderNumberPresent = false;
        List<NF_UnAuthUserOrderLookup.Output> output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});
        Test.stopTest();
        System.assertNotEquals(null, output, 'should have value');
    }
    @isTest
    static void testFailed(){
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        Test.startTest();
        NF_UnAuthUserOrderLookup.Input input = new NF_UnAuthUserOrderLookup.Input();
        input.chatKey = 'abc';
        input.email = 'test@neuraflash.com';
        input.phoneNumber = '5551231234';
        input.zipCode = '12345';
        input.orderId = '123';
        input.isOrderNumberPresent = true;
        List<NF_UnAuthUserOrderLookup.Output> output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});
        Test.stopTest();
        System.assertNotEquals(null, output, 'should have value');
    }

    @isTest
    static void validate(){
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        Test.startTest();
        //Case1
        NF_UnAuthUserOrderLookup.Input input = new NF_UnAuthUserOrderLookup.Input();
        input.chatKey = 'abc';
        input.email = 'test@neuraflash.com';
        input.phoneNumber = '5551231234';
        input.zipCode = '12345';
        input.orderId = '123';
        input.isOrderNumberPresent = true;
        List<NF_UnAuthUserOrderLookup.Output> output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});

        //Case2
        input.isOrderNumberPresent = false;
        output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});

        //case3
        input = new NF_UnAuthUserOrderLookup.Input();
        input.chatKey = 'abc';
        input.isOrderNumberPresent = true;
        output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});
        
        //case4
        input.isOrderNumberPresent = false;
        output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});
        Test.stopTest();
    }



     @IsTest
     static void testSuccess() {
         String chatKey = 'abc';
        
//         Test.setMock(HttpCalloutMock.class, new NF_UnAuthUserOrderLookupTest(200));
         Test.startTest();

         NF_UnAuthUserOrderLookup.Input input = new NF_UnAuthUserOrderLookup.Input();
         input.chatKey = chatKey;
         input.email = 'test@neuraflash.com';
         input.phoneNumber = '5551231234';
         input.zipCode = '12345';
         input.orderId = '123';
         input.isOrderNumberPresent = true;

         List<NF_UnAuthUserOrderLookup.Output> output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});

         input.isOrderNumberPresent = false;

         output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});
         Test.stopTest();
     }

    @IsTest
    static void testEmpty() {
        String chatKey = '321';

        Test.startTest();

        NF_UnAuthUserOrderLookup.Input input = new NF_UnAuthUserOrderLookup.Input();
        input.chatKey = chatKey;
        input.email = '';
        input.phoneNumber = '';
        input.zipCode = '';
        input.orderId = '';
        input.isOrderNumberPresent = false;

        List<NF_UnAuthUserOrderLookup.Output> output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});

        input.isOrderNumberPresent = false;

        output = NF_UnAuthUserOrderLookup.getOrderDetailsForUnAuthenticatedUser(new List<NF_UnAuthUserOrderLookup.Input>{input});
        Test.stopTest();
    }
}