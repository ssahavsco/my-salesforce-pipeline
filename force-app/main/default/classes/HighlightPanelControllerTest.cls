@IsTest
public class HighlightPanelControllerTest {
    @TestSetup
    static void createTestData() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone'
        );
        insert testCase;
    }

    @IsTest
    static void fetchFieldswithAllBlank() {
        Test.startTest();
        HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields('', '', '');
        Test.stopTest();
        System.assertEquals('Invalid Id', result.message, 'Message should be "Please provide valid inputs"');
    }

    @IsTest
    static void fetchFieldswithRecordIdBlank() {
        Test.startTest();
        HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields('', 'Case', 'HighlightPanel');
        Test.stopTest();

        System.assertEquals('Invalid Id', result.message, 'Message should be "Please provide valid inputs"');
    }

    /*@IsTest
    static void fetchFieldswithInvalidIdBlank() {
        Test.startTest();
        HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields('000000000', 'Case', 'HighlightPanel');
        Test.stopTest();

        System.assertEquals('Invalid Id', result.message, 'Message should be "Invalid Id"');
    }

    @IsTest
    static void fetchFieldswithInvalidFieldSetBlank() {
        String routableId = NF_UtilTest.createMessagingSession();
        Test.startTest();
        HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields(routableId, 'MessagingSession', 'InvalidFieldSet');
        Test.stopTest();

        System.assertEquals('Please provide valid Field Set', result.message, 'Message should be "Please provide valid Field Set"');
    }*/
    
	@IsTest
    static void fetchFieldswithFieldsSetBlank() {
        String routableId = NF_UtilTest.createMessagingSession();
        Test.startTest();
        HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields(routableId, 'MessagingSession', '');
        Test.stopTest();

        System.assertEquals('Please provide a Field Set Name', result.message, 'Message should be "Please provide valid inputs"');
    }
    
    @IsTest
    static void fetchFieldswithObjectNameBlank() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        try{
        	HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields(testCase.Id, 'Case', 'HighlightPanel');
        } catch(Exception e){ }
        Test.stopTest();
    }
    
    @IsTest
    static void fetchFieldswithValidData() {
        String routableId = NF_UtilTest.createMessagingSession();
        Test.startTest();
        HighlightPanelController.ReturnWP result = HighlightPanelController.fetchFields(routableId, 'MessagingSession', 'HighlightPanel');
        Test.stopTest();

        System.assertNotEquals(null, result.nameField, 'Name field should not be null');
    }
}