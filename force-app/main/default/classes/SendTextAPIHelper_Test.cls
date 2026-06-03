@isTest
private class SendTextAPIHelper_Test {
    
    @isTest
    static void testRunSendTextAPI() {
        

         ServiceIntegration__c  apiConfig = new ServiceIntegration__c ();
		apiConfig.Name  = 'SMS_Delivery_Token';
		apiConfig.Base_Url__c  = 'test@test.com';
		apiConfig.Suffix_URL__c  = 'password';
		apiConfig.Method_Name__c  = 'clientId';
		apiConfig.Token_Type__c  = 'clientSecret';
		apiConfig.Content_Type__c  = 'Test';
        insert apiConfig;
		
        
        
        // Create test data
        String firstName = 'John';
        String lastName = 'Doe';
        String phoneNumber = '1234567890';
        String shortenURL = 'https://www.example.com';
        
        // Set up ServiceIntegration__c record
        ServiceIntegration__c integration = new ServiceIntegration__c(
            Name = 'SMS_Delivery_API',
            Base_Url__c = 'https://api.example.com',
            Suffix_URL__c = '/sendText',
            Method_Name__c = 'POST',
            Token_Type__c = 'Bearer',
            Content_Type__c = 'application/json',
            Client_Id__c = 'client_id',
            Client_Secret__c = 'client_secret',
            Grant_Type__c = 'password',
            Token_Expiry_Minutes__c = 60,
            Time_out__c = 30000
        );
        insert integration;
        
        
         // Set up ServiceIntegration__c record
        ServiceIntegration__c integration1 = new ServiceIntegration__c(
            Name = 'SMS_Delivery_Token',
            Base_Url__c = 'https://api.example.com',
            Suffix_URL__c = '/sendText',
            Method_Name__c = 'POST',
            Token_Type__c = 'Bearer',
            Content_Type__c = 'application/json',
            Client_Id__c = 'client_id',
            Client_Secret__c = 'client_secret',
            Grant_Type__c = 'password',
            Token_Expiry_Minutes__c = 60,
            Time_out__c = 30000
        );
        insert integration1 ;
        
        
        // Start test
        Test.startTest();
                 Test.setMock(  HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess() );

        String errorMessage = SendTextAPIHelper.runSendTextAPI(firstName, lastName, phoneNumber, shortenURL);
        
         
        errorMessage = SendTextAPIHelper.runSendTextAPI(firstName, lastName, phoneNumber, shortenURL);

        Test.stopTest();
        
        // Assertions
        // Depending on the behavior of your service, you may need additional assertions
        System.assertNotEquals(SendTextAPIHelper.ERROR_MESSAGE_SEND_TEXT, errorMessage);
    }
    
    
    // Add more test methods as needed to cover other methods and scenarios in the SendTextAPIHelper class
}