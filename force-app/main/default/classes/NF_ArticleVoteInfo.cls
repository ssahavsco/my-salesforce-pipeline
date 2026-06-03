/* ******************************************************************************************************************
 * Program Name : NF_ArticleVoteInfo
 * Description : Controller class for Aura --NF_ArticleVoteInformation. contains methods for saving Article upvote and dounvote and view count Info
 * created By : Sunny Yadav
 * Modification log : 
 * ------------------------------------------------------------------------------------------------------------------
 * RequirementId       JiraId              Developer                   Date               Description
 * ------------------------------------------------------------------------------------------------------------------
 * 					 DP-39228,DP-39229    Sunny Yadav				22-03-2021			Articles Helpfullness votes and views update
 * 					 DP-40153			 Sunny Yadav				16-04-2021			    Header/Commnets update in class
 * 					 DP-41214			 Manishi				 	05-05-2021			    Added time zone changes to the record filtering soql.
 * 					 DP-41214			 Chayan				 		05-07-2021			    Removed duplication of views & vote records
 * ******************************************************************************************************************/
public without sharing class NF_ArticleVoteInfo {
    
    @AuraEnabled
    public static Articles_views_and_votes_today__c updateArticleVotes(String articleUrlName,String liked,String disliked,String commentVal){
        //*** DP-39228,DP-39229 STARTS
        //Create and update like and dislike count and comment as per date
        try{
            Datetime todayDateTime = System.now().addHours(-7); 
            System.debug('todayDateTime>>>'+todayDateTime);
            Date currentDate = todayDateTime.date();
            List<Articles_views_and_votes_today__c> knowledgeVoteList =  new List<Articles_views_and_votes_today__c>();
            String correctArticleName=articleUrlName.SubStringBefore('?');
            /* DP-41214 starts*/
            /* changes to soql filter criteria */
            List<Knowledge__kav> knowledgeArticleList = [
                SELECT Id, PublishStatus, Title,ArticleNumber, UrlName, KnowledgeArticleId
                FROM Knowledge__kav 
                WHERE UrlName = :correctArticleName AND PublishStatus = 'Online' 
                LIMIT 1
            ];
            System.debug('knowledgeArticleList---'+knowledgeArticleList);
            if(knowledgeArticleList != null && !knowledgeArticleList.isEmpty()){
                List<Articles_views_and_votes_today__c> views = [
                    SELECT Id,CreatedDate, Total_downvotes__c,Total_Upvotes__c,Article__c
                    FROM Articles_views_and_votes_today__c
                    WHERE Article__r.KnowledgeArticleId =: knowledgeArticleList[0].KnowledgeArticleId
                    AND Article__r.URLName =: correctArticleName
                    ORDER BY CreatedDate DESC LIMIT 1
                ];
                System.debug('views---'+views);
                if(views != null && !views.isEmpty()){
                    Articles_views_and_votes_today__c knowledgeVoteRec = views[0];
                    DateTime createdDateTimeGMT = knowledgeVoteRec.CreatedDate.addHours(-7);
                    Date createdDateGMT = createdDateTimeGMT.date();
                     /* added condition to check the created date with the system date for DP-41214 */
                    if(createdDateGMT == currentDate) {
                        Boolean dislikeFlag = ((knowledgeVoteRec.Total_downvotes__c+Integer.valueOf(disliked))==0 || (knowledgeVoteRec.Total_downvotes__c+Integer.valueOf(disliked)) > 0) ? true : false;
                        Boolean likeFlag = ((knowledgeVoteRec.Total_Upvotes__c+Integer.valueOf(liked))==0 || (knowledgeVoteRec.Total_Upvotes__c+Integer.valueOf(liked)) > 0) ? true : false;
                        knowledgeVoteRec.Total_downvotes__c = (knowledgeVoteRec.Total_downvotes__c  !=null && Integer.valueOf(disliked) != 0 && dislikeFlag) ? knowledgeVoteRec.Total_downvotes__c + Integer.valueOf(disliked) : knowledgeVoteRec.Total_downvotes__c;
                        knowledgeVoteRec.Total_Upvotes__c = (knowledgeVoteRec.Total_Upvotes__c  !=null && Integer.valueOf(liked) != 0 && likeFlag) ? knowledgeVoteRec.Total_Upvotes__c + Integer.valueOf(liked) : knowledgeVoteRec.Total_Upvotes__c;
                        knowledgeVoteList.add(knowledgeVoteRec);
                    }
                }
            }/* DP-41214 ends*/
            else{
                throw new AuraHandledException(System.Label.NF_No_article_validation);
            }
            
            if(knowledgeVoteList.isEmpty()){
                Articles_views_and_votes_today__c knowVoteRec = new Articles_views_and_votes_today__c(Article__c=knowledgeArticleList[0].Id);
                knowVoteRec.Total_downvotes__c =  (Integer.valueOf(disliked) != 0 && Integer.valueOf(disliked) > 0) ?  Integer.valueOf(disliked) : 0;
                knowVoteRec.Total_Upvotes__c = (Integer.valueOf(liked) != 0 && Integer.valueOf(liked) > 0) ?  Integer.valueOf(liked) : 0;
                knowledgeVoteList.add(knowVoteRec);
            }
            
            upsert knowledgeVoteList;
            
            if(String.isNotBlank(commentVal)){
                Knowledge_Article_Comment__c kaComment = new Knowledge_Article_Comment__c(Articles_views_and_votes_today__c=knowledgeVoteList[0].Id,Comment__c=commentVal);
                INSERT kaComment;
            }
            
            return knowledgeVoteList[0];
            
        }catch(Exception e){
            throw new AuraHandledException(e.getLineNumber()+' '+e.getMessage()+ ' '+e.getCause());
        }
        //*** DP-39228,DP-39229 ENDS
    }
    
    @AuraEnabled
    public static Articles_views_and_votes_today__c updateArticleViews(String articleUrlName){
        //Update Articles view count on daily basis against every Knowledge Article
		//*** DP-39228,DP-39229 STARTS
        Datetime todayDateTime = System.now().addHours(-7);
        Date currentDate = todayDateTime.date();
        System.debug('articleUrlName---'+articleUrlName);
        String correctArticleName=articleUrlName.SubStringBefore('?');

        List<Articles_views_and_votes_today__c> KAViewList = new List<Articles_views_and_votes_today__c>();
        
        /* DP-41214 starts*/
        /* changes to soql filter criteria */
        List<Knowledge__kav> knowledgeArticleList = [
            SELECT Id, KnowledgeArticleId FROM Knowledge__kav
            WHERE UrlName = :correctArticleName AND PublishStatus = 'Online'
            LIMIT 1
        ];
        System.debug('knowledgeArticleList---'+knowledgeArticleList);
        if(knowledgeArticleList == null || knowledgeArticleList.isEmpty()){
            return null;
        }
        
        List<Articles_views_and_votes_today__c> views = [
            SELECT Id, Name, View_Count__c, Article__c, CreatedDate, Total_upvotes__c, Total_Downvotes__c
            FROM Articles_views_and_votes_today__c
            WHERE Article__r.KnowledgeArticleId =: knowledgeArticleList[0].KnowledgeArticleId
            AND Article__r.URLName =: correctArticleName
            ORDER BY CreatedDate DESC LIMIT 1
        ];
        System.debug('views---'+views);
        if(views != null && !views.isEmpty()){
            Articles_views_and_votes_today__c knowledgeVoteRec = views[0];
            DateTime createdDateTimeGMT = knowledgeVoteRec.CreatedDate.addHours(-7);
            Date createdDateGMT = createdDateTimeGMT.date();
            /* added condition to check the created date with the system date for DP-41214 */
            if(createdDateGMT == currentDate) {
                Decimal count = (knowledgeVoteRec.View_Count__c != null && knowledgeVoteRec.View_Count__c > 0) ? knowledgeVoteRec.View_Count__c : 0;
                knowledgeVoteRec.View_Count__c = count + 1;
                KAViewList.add(knowledgeVoteRec);
            }
        }
        if(KAViewList.isEmpty()) {
            KAViewList.add(new Articles_views_and_votes_today__c(Article__c = knowledgeArticleList[0].Id,View_Count__c=1,Total_downvotes__c=0,Total_Upvotes__c=0 ));
        }
        /* DP-41214 ends*/
        System.debug('KAViewList---'+KAViewList);
        upsert KAViewList;
        return KAViewList[0];
        //*** DP-39228,DP-39229 ENDS
    }
}