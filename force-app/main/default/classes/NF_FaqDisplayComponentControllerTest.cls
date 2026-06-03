@IsTest
public class NF_FaqDisplayComponentControllerTest {


    public static knowledge__kav getKnowledgeArticle(String title,String Summary,String Urlname){
         knowledge__kav newArticle = new knowledge__kav(Title=title,summary=Summary,urlname=Urlname);
         return newArticle;
    } 

    public static topic getTopic(String NetworkId,String name){
        topic newTopic = new topic(NetworkId = NetworkId, name = name);//
         return newTopic;
    } 
    static testMethod void MakeArticle() {
        knowledge__kav newArticle = getKnowledgeArticle('test','xyz','xyz');
        Network NetworkRec = [SELECT Name, Id, Status, Description FROM Network order by id limit 1];
        String NetworkId = (NetworkRec != null ) ? NetworkRec.Id : '';
        topic newTopic = getTopic(NetworkId,'International1');
        insert newTopic;
        string topicID = newTopic.Id;
        insert newArticle;
        knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: newArticle.Id];
        String articleId = obj1.KnowledgeArticleId;
        //TopicAssignment Topicass = new TopicAssignment(TopicId = topicID, EntityId = newArticle.Id, NetworkId = '0DB0Y000000CablWAC');
        //insert Topicass;
        
        KbManagement.PublishingService.publishArticle(articleId, true);
        Test.startTest();
           NF_FaqDisplayComponentController.knowledgeArticleVerWrapper articleList = NF_FaqDisplayComponentController.getArticles('5');
        	system.assertNotEquals(articleList, null, 'should have value');
        Test.StopTest();

    }
}