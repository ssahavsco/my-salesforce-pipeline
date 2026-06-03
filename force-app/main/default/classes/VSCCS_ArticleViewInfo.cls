/**
 * @description VSCCS_ArticleViewInfo description
 * @author Sumit Saha
 * @description    this is to update the view count of Internal Articles. CCS-1038
 */

public with sharing class VSCCS_ArticleViewInfo {
  public VSCCS_ArticleViewInfo() {
  }
  @AuraEnabled
  public static void increamentViewCount(Id articleId) {
    try {
      List<Articles_views_and_votes_today__c> article = [
        SELECT
          Id,
          CreatedDate,
          Article__c,
          Total_Downvotes__c,
          Total_upvotes__c,
          View_Count__c,
          Record_Type__c
        FROM Articles_views_and_votes_today__c
        WHERE Article__c = :articleId AND CreatedDate = today
      ];

      if (article.size() > 0) {
        article[0].View_Count__c = (article[0].View_Count__c == null)
          ? 1
          : article[0].View_Count__c + 1;
        update article;
      } else if (article.size() == 0) {
        Articles_views_and_votes_today__c c = new Articles_views_and_votes_today__c();
        c.Article__c = articleId;
        c.View_Count__c = 1;
        c.Record_Type__c = 'Internal';
        insert c;
      }
    } catch (Exception e) {
      Logger.error(e.getMessage()).addTag('VSCCS_ArticleViewInfo');
      Logger.saveLog();
    }
  }
}