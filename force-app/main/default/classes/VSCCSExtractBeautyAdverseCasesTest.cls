@isTest
public class VSCCSExtractBeautyAdverseCasesTest {

    @TestSetup
    static void setupTestData() {
        // Create test Case records with adverse reaction details
        List<Case> testCases = new List<Case>();

        // Case 1 with survey responses
        Case adverseCase1 = new Case(
            Notes__c = 'Adverse reaction noted for product A',
            Unspecified_Article__c = false, 
            Date_Time_of_Issue__c = DateTime.now().addDays(-2),
            VS_Safety_Team_Confirmed_Article__c = 'Yes',
            VS_Beauty_Adverse_Reaction_Claim_Survey__c = 'Survey Q1: Answer A<br>Survey Q2: Answer B'
        );
        testCases.add(adverseCase1);

        // Case 2 with survey responses
        Case adverseCase2 = new Case(
            Notes__c = 'Adverse reaction noted for product B',
            Unspecified_Article__c = true, 
            Date_Time_of_Issue__c = DateTime.now().addDays(-3),
            VS_Safety_Team_Confirmed_Article__c = 'No',
            VS_Beauty_Adverse_Reaction_Claim_Survey__c = 'Survey Q1: Answer X<br>Survey Q2: Answer Y'
        );
        testCases.add(adverseCase2);

        // Insert cases
        insert testCases;
    }

    @isTest
    static void testGenerateExcel_Success() {
        DateTime now = DateTime.now();
        String startDate = now.addDays(-4).format('yyyy-MM-dd');
        String endDate = now.format('yyyy-MM-dd');

        Test.startTest();
        // Generate Excel and assert output is not null
        //String result = VSCCSExtractBeautyAdverseCasesController.generateExcel(startDate, endDate);
        //System.assertNotEquals(null, result, 'Excel generation failed');
        
        // Optionally, check if survey answers are properly processed (assert based on your logic)
        // Example assertion for the CSV:
        //System.assert(result.contains('Answer A'), 'Survey answer A should be in the result');
        //System.assert(result.contains('Answer X'), 'Survey answer X should be in the result');
        Test.stopTest();
    }

    @isTest
    static void testGenerateExcel_NoRecordsFound() {
        // Prepare test data for a date range with no records
        DateTime now = DateTime.now();
        String startDate = now.addDays(-10).format('yyyy-MM-dd');
        String endDate = now.addDays(-9).format('yyyy-MM-dd');
 
        Test.startTest();
        try {
            VSCCSExtractBeautyAdverseCasesController.generateExcel(startDate, endDate);
        } catch (AuraHandledException e) {
            // Handle exception
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateExcel_ExceptionHandling() {
        // Force an exception by passing invalid date formats
        String startDate = 'invalid-date';
        String endDate = 'invalid-date';
 
        Test.startTest();
        try {
            VSCCSExtractBeautyAdverseCasesController.generateExcel(startDate, endDate);
        } catch (AuraHandledException e) {
            // Handle exception
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateExcelContent() {
        // Query test data
        List<Case> caseList = [SELECT Id, CaseNumber, Notes__c, Unspecified_Article__c, Date_Time_of_Issue__c, VS_Safety_Team_Confirmed_Article__c, VS_Beauty_Adverse_Reaction_Claim_Survey__c, Event_Type__c FROM Case WHERE Type = 'Beauty' AND Sub_Type__c = 'Adverse Reaction - Beauty'];
 
        Test.startTest();
        String csvContent = VSCCSExtractBeautyAdverseCasesController.generateExcelContent(caseList);
        Test.stopTest();
    }

    @isTest
    static void testCreatePublicLink() {
        // Prepare test data
        String csvContent = 'CaseNumber,Date Time of Issue,Safety Team Confirmed Article,Event Type,Unspecified Article,Notes,VS Beauty Adverse Reaction Claim Survey\n' +
                            '"CASE-0","2023-10-01 12:00:00","Article 0","Event 0","Yes","Test Notes 0","Survey Q1: Answer A<br>Survey Q2: Answer B"';
 
        Test.startTest();
        String result = VSCCSExtractBeautyAdverseCasesController.createPublicLink(csvContent);
        Test.stopTest();
    }
}