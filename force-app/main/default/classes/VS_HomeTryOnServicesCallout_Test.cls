/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for VS_HomeTryOnServicesCallout_Test.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Pooja 
* @version        1.0
────────────────────────────────────────────────────────────────────────
* @changes
* * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class VS_HomeTryOnServicesCallout_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }
    
    @isTest
    static void getHTODashBoardDetailsValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('getHTODashBoardDetails', 'valid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.getHTODashBoardDetails(customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void getHTODashBoardDetailsInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('getHTODashBoardDetails', 'Invalid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.getHTODashBoardDetails(customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void extendKeepReturnBoxValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('extendKeepReturnBox', 'valid'));
        Test.startTest();
        String skip_frequency ='1';
        String box_id ='123';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.extendKeepReturnBox(customerEmailId,box_id);
        Test.stopTest();
    }
    
    @isTest
    static void extendKeepReturnBoxInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('extendKeepReturnBox', 'Invalid'));
        Test.startTest();
        String skip_frequency ='1';
        String box_id ='123';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.extendKeepReturnBox(customerEmailId,box_id);
        Test.stopTest();
    }
    
    
    @isTest
    static void markBoxAsDeliveredValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('markBoxAsDelivered', 'valid'));
        Test.startTest();
         String box_id ='123';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.markBoxAsDelivered(customerEmailId,box_id);
        Test.stopTest();
    }
    
    @isTest
    static void markBoxAsDeliveredInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('markBoxAsDelivered', 'Invalid'));
        Test.startTest();
         String box_id ='123';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.markBoxAsDelivered(customerEmailId,box_id);
        Test.stopTest();
    }
    
    @isTest
    static void udpateBoxFrequencyValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('udpateBoxFrequency', 'valid'));
        Test.startTest();
         String box_frequency ='monthly';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.udpateBoxFrequency(box_frequency,customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void udpateBoxFrequencyInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('udpateBoxFrequency', 'Invalid'));
        Test.startTest();
        String box_frequency ='monthly';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.udpateBoxFrequency(box_frequency,customerEmailId);
        Test.stopTest();
    }

    @isTest
    static void skipBoxValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('skipBox', 'valid'));
        Test.startTest();
        Integer month =1;
        Integer year =2023;
        String source='simon';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.skipBox(month,year,source,customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void skipBoxInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('skipBox', 'Invalid'));
        Test.startTest();
        Integer month =1;
        Integer year =2023;
        String source='simon';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.skipBox(month,year,source,customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void pauseSubscriptionValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('pauseSubscription', 'valid'));
        Test.startTest();
        String pause_frequency ='2';
         String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.pauseSubscription(pause_frequency,customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void pauseSubscriptionInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('pauseSubscription', 'Invalid'));
        Test.startTest();
		String pause_frequency ='2';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.pauseSubscription(pause_frequency,customerEmailId);
        Test.stopTest();
    }
    
    @isTest
    static void unSubscriptionValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('unSubscription', 'valid'));
        Test.startTest();
        String reason_text ='XYZ';
        String unsubscribe_reason = 'Other';
        String source ='Simon';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.unSubscription(customerEmailId,reason_text,unsubscribe_reason,source);
        Test.stopTest();
    }
    
    @isTest
    static void unSubscriptionInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('unSubscription', 'Invalid'));
        Test.startTest();
        String reason_text ='XYZ';
        String unsubscribe_reason = 'Other';
        String source ='Simon';
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.unSubscription(customerEmailId,reason_text,unsubscribe_reason,source);
        Test.stopTest();
    }
    
    @isTest
    static void resumeSubscritionValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('resumeSubscrition', 'valid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.resumeSubscrition(customerEmailId);
        Test.stopTest();
    }
    
        @isTest
    static void resumeSubscritionInvalid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('resumeSubscrition', 'Invalid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.resumeSubscrition(customerEmailId);
        Test.stopTest();
    } 
    @isTest
    static void getBoxStatusSettings(){
        Test.startTest();
		List<HTO_Box_Status_Setting__mdt> lsthtodetails =VS_HomeTryOnServicesCallout.getBoxStatusSettings();
        Test.stopTest();
    }
    @isTest
    static void getOrderhistoryByCustomerIdValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('getOrderhistoryByCustomerId', 'Valid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.getOrderhistoryByCustomerId(customerEmailId);
        Test.stopTest();
    }
    @isTest
    static void getOrderhistoryByCustomerIdInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('getOrderhistoryByCustomerId', ''));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.getOrderhistoryByCustomerId(customerEmailId);
        Test.stopTest();
    }
    @isTest
    static void boxHistoryByEmailValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('boxHistoryByEmail', 'Valid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.boxHistoryByEmail(customerEmailId);
        Test.stopTest();
    }
    @isTest
    static void boxHistoryByEmailInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('boxHistoryByEmail', ''));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        VS_HomeTryOnServicesCallout.boxHistoryByEmail(customerEmailId);
        Test.stopTest();
    }
    @isTest
    static void boxDetailsByEmailValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('boxHistoryByEmail', 'Valid'));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        String orderId ='T100092';
        VS_HomeTryOnServicesCallout.boxDetailsByEmail(customerEmailId,orderId);
        Test.stopTest();
    }
    @isTest
    static void boxDetailsByEmailInValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('boxHistoryByEmail', ''));
        Test.startTest();
        String customerEmailId ='test@salesforc.ecom';
        String orderId ='T100092';
        VS_HomeTryOnServicesCallout.boxDetailsByEmail(customerEmailId,orderId);
        Test.stopTest();
    }
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){
        
        Home_Try_On_Authentication__c authsettings =new Home_Try_On_Authentication__c(Name='Sandbox');
        //insert authsettings;
        Home_Try_On_Authentication__c authsettingsOne=new Home_Try_On_Authentication__c(Name='Production');
        //insert authsettingsOne;
        authSettings.Base_Url__c ='https://apitest.victoriassecret.com';
        authSettings.Client_Secret__c ='1tZSZyNkE9UY07azaZopgWoQkyc2ourSl==';
        authSettings.Client_Id__c = '1tZSZyNkE9UY07azaZopgWoQkyc2ourSlPJmOqFx_g==';
        authSettings.Grant_Type__c ='client_credentials ';
        authSettings.Time_Out__c = 7200;
        insert authSettings;
        
        authsettingsOne.Base_Url__c ='https://apitest.victoriassecret.com';
        authsettingsOne.Client_Secret__c ='1tZSZyNkE9UY07azaZopgWoQkyc2ourSl==';
        authsettingsOne.Client_Id__c = '1tZSZyNkE9UY07azaZopgWoQkyc2ourSlPJmOqFx_g==';
        authsettingsOne.Grant_Type__c ='client_credentials ';
        authsettingsOne.Time_Out__c = 7200;
        insert authsettingsOne;
        
        
    } 
    
    
}