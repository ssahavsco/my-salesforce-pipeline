@IsTest
public class NF_contactOptionsModelControllerTest {

    public static knowledge__kav getKnowledgeArticle(String title,String Summary,String Urlname){
         knowledge__kav newArticle = new knowledge__kav(Title=title,summary=Summary,urlname=Urlname);
         return newArticle;
    } 

    
    static testMethod void MakeArticle() {
        knowledge__kav newArticle = getKnowledgeArticle('test','xyz','xyz');
        insert newArticle;
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        String articleId = obj1.KnowledgeArticleId;
        
        KbManagement.PublishingService.publishArticle(articleId, true);
        Test.startTest();
        	knowledge__kav newArticle1 =NF_contactOptionsModelController.fetchModalArticle('xyz');
        	system.assertNotEquals(newArticle1, null);
        Test.StopTest();

    }
}