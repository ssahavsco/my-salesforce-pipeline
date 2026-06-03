/* ******************************************************************************************************************
 * Program Name : NF_CustomArticleDetailController
 * Description : Controller class for "NF_CustomArticleDetail Aura Component".Gets the Knowlwdge article content and displays on the articles detail page.
 * created By : Sunny Yadav
 * Modification log : 
 *  * ------------------------------------------------------------------------------------------------------------------
 * RequirementId       JiraId              Developer                   Date				 Description
 * ------------------------------------------------------------------------------------------------------------------
 * 					 DP-36278				Sunny Yadav				26-03-2021			Custom Article and related topics display and Support for Click to call 
 * 					 DP-40162				Sunny Yadav				16-04-2021			Header/Commnets update in class
 * 					 DP-41265				manishi					07-05-2021			Community articles are redirecting to force.com site.
 * ******************************************************************************************************************/
public class NF_CustomArticleDetailController {

    @AuraEnabled
    public static ArticleDetailInfo getArticleInfo(String KnowledgeArticleId){
        
        //Method to fetch the knowledge article and its related topics based on passed knowledge article Id
        Knowledge__kav eachArticle = new Knowledge__kav();
        ArticleDetailInfo articleInfo = new ArticleDetailInfo();
        List<TopicAssignment> listOfTopicAssignment = new List<TopicAssignment>();
        List<TopicDetails> topicDetailList = new List<TopicDetails>();
        /* modified formatting DP-41265 */
        List<Knowledge__kav>  articleRec = [SELECT Id,urlname,Answer__c 
                                            FROM Knowledge__kav 
                                            WHERE Id  = :KnowledgeArticleId 
                                            AND PublishStatus = 'Online' Limit 1];
        
        if(articleRec.isEmpty()){
            throw new AuraHandledException(System.label.NF_VS_community_contact_model_no_article_validation);  
        }else{
            eachArticle = articleRec[0];
            System.debug(KnowledgeArticleId);
            listOfTopicAssignment = [SELECT Id,TopicId,Topic.Name FROM TopicAssignment WHERE EntityId =:KnowledgeArticleId Limit 50000 ];
            
            for(TopicAssignment topicAssign :listOfTopicAssignment){
                TopicDetails topic = new TopicDetails();
                topic.topicId = topicAssign.TopicId;
                topic.topicName =topicAssign.Topic.Name ;
                topicDetailList.add(topic);
            }
        }
        articleInfo.knowledgeArticle = eachArticle;
        articleInfo.topicsList = topicDetailList;
        return articleInfo;
    }
	//Wrapper class to return topic List and knowledge article
    public class ArticleDetailInfo{

        @AuraEnabled
        public Knowledge__kav knowledgeArticle;
        @AuraEnabled
        public List<TopicDetails> topicsList;
    }
    public class TopicDetails{
        @AuraEnabled
        public String topicName;
        @AuraEnabled
        public String topicId;
    }
}