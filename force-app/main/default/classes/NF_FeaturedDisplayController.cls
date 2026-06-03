/* ******************************************************************************************************************
 * Program Name : NF_FeaturedDisplayController
 * Description : Controller class for "NF_FeatureArticleDisplay Aura Component"
 * created By : Sunny Yadav
 * Created Date : 26-03-2021
 * Modification log : 
 * * ------------------------------------------------------------------------------------------------------------------
 * RequirementId       JiraId              Developer                   Date					 Description
 * ------------------------------------------------------------------------------------------------------------------
 * 					  DP-39230		     Sunny Yadav				 01-04-2021				Display Fetured Articles on community home page
 * 					  DP-40153			 Sunny Yadav				16-04-2021			    Header/Commnets update in class
 * ******************************************************************************************************************/
public class NF_FeaturedDisplayController {

    @AuraEnabled
    Public static knowledgeArticleVerWrapper getArticles(String articalDisplayed){
        
       //Method to get the relevent Knowledge Articles based on topic name where Fetured articles is true
       
        String networkId = Network.getNetworkId();
       
         
       /*List<Knowledge__kav> knowledgeArticleVerList = [SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, UrlName, ArticleNumber,Sort_Order__c, ArticleTotalViewCount FROM Knowledge__kav //recordType.name = :recordTypeName
                                                                 WHERE Language = 'en_US' AND PublishStatus = 'Online' AND Id in (SELECT EntityId FROM TopicAssignment WHERE TopicId IN :topicList ) order by Sort_Order__c Asc Nulls last Limit :Integer.valueOf(articalDisplayed)];*/
        List<Knowledge__kav> knowledgeArticleVerList = [SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, UrlName, ArticleNumber,Sort_Order__c, ArticleTotalViewCount FROM Knowledge__kav 
                                                                 WHERE Language = 'en_US' AND PublishStatus = 'Online' AND  Featured_Articles__c = true order by Sort_Order__c Asc Nulls last Limit :Integer.valueOf(articalDisplayed)];
        
         
        
        return new knowledgeArticleVerWrapper(knowledgeArticleVerList);

    }
    // Wrapper class to return Toipc Id and Featured Knowledge article List 
    Public Class knowledgeArticleVerWrapper{
        @AuraEnabled Public List<Knowledge__kav> knowledgeArticleVerList;
        public knowledgeArticleVerWrapper(List<Knowledge__kav> knowledgeArticleVerList){
            this.knowledgeArticleVerList = knowledgeArticleVerList; 
        }
    }
}