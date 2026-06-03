@IsTest
public class NF_CustomArticleDetailControllerTest {

    public static knowledge__kav getKnowledgeArticle(String title,String Summary,String Urlname){
         knowledge__kav newArticle = new knowledge__kav(Title=title,summary=Summary,urlname=Urlname);
         return newArticle;
    } 
	public static Topic getTopic(String NetworkId,String name){
        Topic newTopic = new Topic(NetworkId = NetworkId, Name = name);//
         return newTopic;
    } 
    
    static testMethod void MakeArticle() {
        knowledge__kav newArticle = getKnowledgeArticle('test','xyz','xyz');
        insert newArticle;
        Network NetworkRec = [SELECT Name, Id, Status, Description FROM Network order by Id limit 1];
        String NetworkId = (NetworkRec != null ) ? NetworkRec.Id : '';
        Topic newTopic = getTopic(NetworkId,'International1');
        insert newTopic;
        String topicID = newTopic.Id;
        //insert newArticle;
        String articleId = newArticle.Id; 
        
        TopicAssignment Topicass = new TopicAssignment(TopicId = topicID, EntityId = articleId, NetworkId = NetworkId);
        insert Topicass;
        Knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id =: newArticle.Id]; 
        String articleId1 = obj1.KnowledgeArticleId;
        
        
        
        KbManagement.PublishingService.publishArticle(articleId1, true);
        Test.startTest();
        	NF_CustomArticleDetailController.ArticleDetailInfo newArticle1 =NF_CustomArticleDetailController.getArticleInfo(obj1.Id);
        	system.assertNotEquals(newArticle1, null); 
        Test.StopTest();

    }
}