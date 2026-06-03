@IsTest
public class SystemToolsFeedBackControllerTest {

    @TestSetup
    static void setup() {
        // Create test data for Knowledge__kav
        Knowledge__kav testArticle1 = new Knowledge__kav(
            Title = 'Test Article 1',
            Summary = 'This is the summary for Test Article 1',
            URLName='TestArticle'
        );
        insert testArticle1;
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: testArticle1.Id];

		KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);

    }

    @IsTest
    static void testSearchKnowledgeArticles() {
        // Test the method with a title search string
        Test.startTest();
        List<Knowledge__kav> results = SystemToolsFeedBackController.searchKnowledgeArticles('Test Article 1');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected to find 1 article with the specified title.');
        System.assertEquals('Test Article 1', results[0].Title, 'The title should match the search string.');
    }
}