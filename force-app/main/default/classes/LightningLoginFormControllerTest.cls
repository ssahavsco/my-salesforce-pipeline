@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

    @IsTest
    static void testLoginWithInvalidCredentials() {
        //System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
        System.assertEquals(null, LightningLoginFormController.login('testUser', 'fakepwd', null));
    }

    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        Boolean isUsernamePasswordEnabled = LightningLoginFormController.getIsUsernamePasswordEnabled();
        //System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    

    @IsTest
    static void testIsSelfRegistrationEnabled() {
    System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    @isTest
    static void testGetForgotPasswordUrl(){
        System.assertEquals(null, LightningLoginFormController.getForgotPasswordUrl());
    }
    
    @isTest
    static void testSetExperienceId(){
        System.assertEquals('This method can be invoked only from within a community.', LightningLoginFormController.setExperienceId(''));
    }
}