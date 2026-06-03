@IsTest
public  class NF_NavigationalTopicControllerTest {

    public static Knowledge__kav getKnowledgeArticle(String title,String Summary,String Urlname){
         Knowledge__kav newArticle = new Knowledge__kav(Title=title,Summary=Summary,UrlName=Urlname);
         return newArticle;
    } 

    public static Topic getTopic(String NetworkId,String name){
        Topic newTopic = new Topic(NetworkId = NetworkId, Name = name);//
         return newTopic;
    }
    @IsTest
    static void MakeArticle() {
        Knowledge__kav newArticle = getKnowledgeArticle('test','xyz','xyz');
        Network NetworkRec = [SELECT Name, Id, Status, Description FROM Network order by Id limit 1];
        String NetworkId = (NetworkRec != null ) ? NetworkRec.Id : '';
        Topic newTopic = getTopic(NetworkId,'International1');
        insert newTopic;
        String topicID = newTopic.Id;
        insert newArticle;
        String articleId = newArticle.Id; 
        //TopicAssignment Topicass = new TopicAssignment(TopicId = topicID, EntityId = teamID, NetworkId = '0DB0Y000000CablWAC');
        //insert Topicass;
        
        //KbManagement.PublishingService.publishArticle(articleId, true);
        Test.startTest();
        //List<NavigationalTopicController.NavigationalSubTopicWrapper> subWrapperList = new List<NavigationalTopicController.NavigationalSubTopicWrapper>();
        NF_NavigationalTopicController.NavigationalSubTopicWrapper wrapRec = new NF_NavigationalTopicController.NavigationalSubTopicWrapper('order','4564564554');
             List<NF_NavigationalTopicController.NavigationalTopicWrapper> NavigationalTopicWrapperList = NF_NavigationalTopicController.fetchNavigationalTopics(); 
        System.assertNotEquals(null, NavigationalTopicWrapperList, 'should have value');
        Test.stopTest();

    }
}