/**
 * @description VSCCS_ArticleViewInfo description
 * @author Sumit Saha
 * @description    this is to update the view count of Internal Articles. CCS-1038
 */

@IsTest
public with sharing class VSCCS_ArticleViewInfoTest {
  @IsTest
  public static void increamentViewCountTest() {
    Long timestampMs = System.currentTimeMillis();

    String title = 'Title' + timestampMs;
    String Summary = 'Summary' + timestampMs;
    String UrlName = 'UrlName' + timestampMs;

    Knowledge__kav newArticle = new Knowledge__kav(
      Title = title,
      Summary = Summary,
      UrlName = UrlName
    );
    insert newArticle;

    Articles_views_and_votes_today__c article = new Articles_views_and_votes_today__c(
      Article__c = newArticle.Id
    );

    Test.startTest();
    VSCCS_ArticleViewInfo.increamentViewCount(Article.Id);
    VSCCS_ArticleViewInfo.increamentViewCount(null);
    VSCCS_ArticleViewInfo.increamentViewCount('001000000000000AAA');
    Test.stopTest();
  }
}