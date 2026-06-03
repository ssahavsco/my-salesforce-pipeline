@isTest
private class SendPayLinkAction_Test {
    @isTest
    static void testSendSingleEmailMethod() {
        // Create test data
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
        //EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Place_New_Order_Email_Template' LIMIT 1];
        OrgWideEmailAddress testOrgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@victoriassecret.com' LIMIT 1];
        
        // Call the method
        Test.startTest();
        String result = SendPayLinkAction.sendSingleEmailMethod(testCase.Id, 'test@example.com', 'paymentLink');
        Test.stopTest();
        
        // Verify the result
        //System.assertEquals('To secure your final order and selected products, I would appreciate it if you could complete the payment link that I just sent you via email.', result);
        System.assertEquals('To secure your final order and selected products, I would appreciate it if you could complete the payment link that I just sent you via email.Please note, when accessing the payment link form, all discounts, including Free Shipping, will show as a combined discount amount.', result);
    }
    
    @isTest
    static void testSendTextMessage() {
        
         // Create test data
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        // Call the method
        Test.startTest();
        String result = SendPayLinkAction.sendTextMessage('Test', 'User', '1234567890', 'paymentLink',testCase.Id);
        Test.stopTest();
        
        // Verify the result
        // Add assertions here if needed
        // System.assertEquals(expectedResult, result);
    }
}