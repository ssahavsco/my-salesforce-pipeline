/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for VS_HTO_ManageSubscriptionValidationTest.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Pooja 
* @version        1.0
────────────────────────────────────────────────────────────────────────
* @changes
* * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class VS_HTO_ManageSubscriptionValidationTest {
	  @TestSetup
    static void setupData(){
        testSetupData();
    }
     @isTest
    static void htoOrderSelectionValidationUpdateFrequency(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='Update Frequency';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
    @isTest
    static void htoOrderSelectionValidationSkipNextBox(){
       Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='Skip Next Box';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
    @isTest
    static void htoOrderSelectionValidationPause2Months(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='Pause 2 Months';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
    @isTest
    static void htoOrderSelectionValidationPause3Months(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='Pause 3 Months';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
    @isTest
    static void htoOrderSelectionValidationCancelSubscription(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='Cancel Subscription';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
      @isTest
    static void htoOrderSelectionValidationMore(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='More';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
     @isTest
    static void htoOrderSelectionValidationNothingSelected(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.Input input1 = new VS_HTO_ManageSubscriptionValidation.Input();
        VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu obj = new VS_HTO_ManageSubscriptionValidation.HtoSubscriptionMenu();
        obj.htoSubcriptionMenuPlaceHolder='Nothing Selected';
    	input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.htoSubscriptionMenu= obj;
        inputs.add(input1);
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
        Test.stopTest();
    }
    @isTest
    static void htoOrderSelectionValidationNothingException(){
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeDashboardServiceValid', 'valid'));
        Test.startTest();
        List<VS_HTO_ManageSubscriptionValidation.Input> inputs = new List<VS_HTO_ManageSubscriptionValidation.Input>();
        VS_HTO_ManageSubscriptionValidation.htoManageSubscriptionSelectionValidation(inputs);
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