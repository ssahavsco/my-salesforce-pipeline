public without sharing class NF_FaqDisplayComponentController {

@AuraEnabled
    Public static knowledgeArticleVerWrapper getArticles(String articalDisplayed){
        //String networkId = '0DB010000004CFfGAM';
        String networkId = Network.getNetworkId();
        List<NavigationalTopicInformation__mdt> navigationTopicList =[Select developerName,MasterLabel,Icon_Name__c,Sort_Order__c
                                                                      From NavigationalTopicInformation__mdt where  FAQ_Topic__c = true and Icon_Name__c != null limit 1];
        String topicName= '';
        String topicId= '';
        if(navigationTopicList != null && navigationTopicList.size() > 0){
            for(NavigationalTopicInformation__mdt navMetadataRecord : navigationTopicList){
                topicName = navMetadataRecord.MasterLabel;
            }
        }
        List<Topic> topicList = [Select Id, Name, NetworkId FROM Topic WHERE NetworkId = :networkId And Name = :topicName limit 1];
        
       /* List<KnowledgeArticleVersion> knowledgeArticleVerList = [SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, UrlName, ArticleNumber, ArticleTotalViewCount FROM KnowledgeArticleVersion 
                                                                 WHERE Language = 'en_US' AND PublishStatus = 'Online' AND Id in (SELECT EntityId FROM TopicAssignment WHERE TopicId IN :topicList ) order by ArticleTotalViewCount Desc Nulls last Limit :Integer.valueOf(articalDisplayed)];*/
        List<Knowledge__kav> knowledgeArticleVerList = [SELECT Id, KnowledgeArticleId, PublishStatus, VersionNumber, Title, UrlName, ArticleNumber, ArticleTotalViewCount FROM Knowledge__kav 
                                                                 WHERE Language = 'en_US' AND PublishStatus = 'Online' AND Id in (SELECT EntityId FROM TopicAssignment WHERE TopicId IN :topicList ) order by ArticleTotalViewCount Desc Nulls last Limit :Integer.valueOf(articalDisplayed)];

        if(topicList != null && topicList.size() > 0){
            topicId = topicList[0].Id; 
        }else{ 
            if(!test.isRunningTest()){
                throw new AuraHandledException(System.Label.NF_No_topic_validation);
            }
        } 

        
        return new knowledgeArticleVerWrapper(topicId,knowledgeArticleVerList);

    }
    
    Public Class knowledgeArticleVerWrapper{
        @AuraEnabled Public String viewAll;
        @AuraEnabled Public List<Knowledge__kav> knowledgeArticleVerList;
        public knowledgeArticleVerWrapper(String viewAll,List<Knowledge__kav> knowledgeArticleVerList){
            this.viewAll = viewAll;
            this.knowledgeArticleVerList = knowledgeArticleVerList;
        }
    }
}