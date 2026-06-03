/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for VS_HTO_Bot_ServiceCallsTest.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Pooja 
* @version        1.0
────────────────────────────────────────────────────────────────────────
* @changes
* * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
    public class VS_HTO_Bot_ServiceCallsTest {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }
    @isTest
    static void skipBoxValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('skipBox', 'valid'));
        Test.startTest();
        Integer month =1;
        Integer year =2023;
        String source='simon';
        String customerEmailId ='test@salesforc.ecom';
        List<VS_HTO_Bot_SkipNextBox.SkipInput> skip_input = new List<VS_HTO_Bot_SkipNextBox.SkipInput>();
        VS_HTO_Bot_SkipNextBox.SkipInput skipinput = new VS_HTO_Bot_SkipNextBox.SkipInput();
        skipinput.skipMonth=1;
        skipinput.skipSource='simon';
        skipinput.skipYear=2023;
        skipinput.subscriberEmail='test@salesforc.ecom';
        skip_input.add(skipinput);
        VS_HTO_Bot_SkipNextBox.skipNextBox(skip_input);
        Test.stopTest();
    }
     @isTest
    static void skipBoxValidException(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('skipBox', 'valid'));
        Test.startTest();
        Integer month =1;
        Integer year =2023;
        String source='simon';
        String customerEmailId ='test@salesforc.ecom';
        List<VS_HTO_Bot_SkipNextBox.SkipInput> skip_input = new List<VS_HTO_Bot_SkipNextBox.SkipInput>();
        VS_HTO_Bot_SkipNextBox.skipNextBox(skip_input);
        Test.stopTest();
    }
     @isTest
    static void pauseSubscriptionValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('pauseSubscription', 'valid'));
        Test.startTest();
        VS_HTO_Bot_PauseSubscription.PauseInput pauseinput = new VS_HTO_Bot_PauseSubscription.PauseInput();
        pauseinput.pauseFrequency='2';
        pauseinput.subscriberEmail='test@salesforc.ecom';
        List<VS_HTO_Bot_PauseSubscription.PauseInput> lstpauseinput = new List<VS_HTO_Bot_PauseSubscription.PauseInput>();
        lstpauseinput.add(pauseinput);
        VS_HTO_Bot_PauseSubscription.bot_pauseSubscription(lstpauseinput);
        Test.stopTest();
        
    }
     @isTest
    static void pauseSubscriptionValidException(){
         Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('pauseSubscription', 'valid'));
        Test.startTest();
        List<VS_HTO_Bot_PauseSubscription.PauseInput> lstpauseinput = new List<VS_HTO_Bot_PauseSubscription.PauseInput>();
        VS_HTO_Bot_PauseSubscription.bot_pauseSubscription(lstpauseinput);
        Test.stopTest();
    }
     @isTest
    static void unSubscriptionValid(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('unSubscription', 'valid'));
        Test.startTest();
       	VS_HTO_Bot_CancelSubscription.CancelInput cancelinputobj = new VS_HTO_Bot_CancelSubscription.CancelInput();
        cancelinputobj.subscriberEmail ='test@salesforc.ecom';
        List<VS_HTO_Bot_CancelSubscription.CancelInput> lstcancelinput = new List<VS_HTO_Bot_CancelSubscription.CancelInput>();
        lstcancelinput.add(cancelinputobj);
        VS_HTO_Bot_CancelSubscription.bot_CancelSubscription(lstcancelinput);
        Test.stopTest();
    }
     @isTest
    static void unSubscriptionValidException(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('pauseSubscription', 'valid'));
        Test.startTest();
        List<VS_HTO_Bot_CancelSubscription.CancelInput> lstcancelinput = new List<VS_HTO_Bot_CancelSubscription.CancelInput>();
        VS_HTO_Bot_CancelSubscription.bot_CancelSubscription(lstcancelinput);
        Test.stopTest();
    }
    

    
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