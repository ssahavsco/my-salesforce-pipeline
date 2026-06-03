/* ******************************************************************************************************************
 * Program Name : NF_ArticleVoteInfoTest
 * Description : Test class for class --NF_ArticleVoteInfo.
 * created By : Sunny Yadav
 * Modification log : 
 * ******************************************************************************************************************/
@IsTest
public with sharing class NF_ArticleVoteInfoTest {

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
        Network NetworkRec = [SELECT Name, Id, Status, Description FROM Network ORDER BY Id LIMIT 1];
        String NetworkId = (NetworkRec != null ) ? NetworkRec.Id : '';
        Topic newTopic = getTopic(NetworkId,'International1');
        insert newTopic;
        String topicID = newTopic.Id;
        insert newArticle;
        Knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id];
        String articleId = obj1.KnowledgeArticleId;
        
        KbManagement.PublishingService.publishArticle(articleId, true);
        Test.startTest();
            NF_ArticleVoteInfo.updateArticleVotes('xyz','0','1','comment');
            NF_ArticleVoteInfo.updateArticleVotes('xyz','0','1','comment');
            List<Articles_views_and_votes_today__c> votesList = [Select Id,Total_downvotes__c,Total_Upvotes__c,Article__c From Articles_views_and_votes_today__c limit 1];
        	NF_ArticleVoteInfo.updateArticleViews('xyz'); 
        	System.assertNotEquals(votesList, null, 'should not be null');
            System.assertNotEquals(votesList[0].Total_Upvotes__c, 2, 'should not be 2');
        Test.stopTest();

    }

}