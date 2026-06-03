/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for VS_HomeTryOnBotServiceCallsTest.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Pooja 
* @version        1.0
────────────────────────────────────────────────────────────────────────
* @changes
* * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class VS_HomeTryOnBotServiceCallsTest {
     @TestSetup
    static void setupData(){
        testSetupData();
    }
    @isTest
    static void invokeDashboardServiceValid(){
        ebotdata__Bot_Session__c ebotsession1 = new ebotdata__Bot_Session__c();
        ebotsession1.Is_User_HTO_Subscribed__c=true;
        ebotsession1.HTO_Box_Stance__c='';
        ebotsession1.HTO_Status_Code__c=200;
        ebotsession1.Customer_Full_Name__c='Test';
        ebotsession1.ebotdata__Live_Agent_Session_Id__c='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
    	insert ebotsession1;
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HomeTryOnBotServiceCalls.Input> inputs = new List<VS_HomeTryOnBotServiceCalls.Input>();
        VS_HomeTryOnBotServiceCalls.Input input1 = new VS_HomeTryOnBotServiceCalls.Input();
        input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.email='test@salesforc.ecom';
        inputs.add(input1);
        VS_HomeTryOnBotServiceCalls.invokeDashboardService(inputs);
        Test.stopTest();
    }
    @isTest
    static void invokeDashboardServiceInValid(){
        ebotdata__Bot_Session__c ebotsession1 = new ebotdata__Bot_Session__c();
        ebotsession1.Is_User_HTO_Subscribed__c=true;
        ebotsession1.HTO_Box_Stance__c='generic_error';
        ebotsession1.HTO_Status_Code__c=200;
        ebotsession1.Customer_Full_Name__c='Test';
        ebotsession1.ebotdata__Live_Agent_Session_Id__c='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
    	insert ebotsession1;
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceboxstanceInValid', ''));
        Test.startTest();
        List<VS_HomeTryOnBotServiceCalls.Input> inputs = new List<VS_HomeTryOnBotServiceCalls.Input>();
        VS_HomeTryOnBotServiceCalls.Input input1 = new VS_HomeTryOnBotServiceCalls.Input();
        input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.email='test@salesforc.ecom';
        inputs.add(input1);
        VS_HomeTryOnBotServiceCalls.invokeDashboardService(inputs);
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