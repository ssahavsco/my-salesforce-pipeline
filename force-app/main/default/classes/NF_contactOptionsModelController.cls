public without sharing class NF_contactOptionsModelController {

    @AuraEnabled
    public static Knowledge__kav fetchModalArticle(String urlName){
        List<Knowledge__kav>  articleRecList = [Select Id,urlname,Answer__c,Title From Knowledge__kav Where urlName = :urlName.trim() AND PublishStatus = 'Online' Limit 1];
        if(articleRecList.size() == 0){
            throw new AuraHandledException(System.label.NF_VS_community_contact_model_no_article_validation);
        }else{
            return articleRecList[0];
        }
        
    }
}