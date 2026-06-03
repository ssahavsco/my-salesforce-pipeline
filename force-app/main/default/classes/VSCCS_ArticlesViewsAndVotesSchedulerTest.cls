@IsTest
public with sharing class VSCCS_ArticlesViewsAndVotesSchedulerTest {
  @isTest(SeeAllData=true)
  static void testSchedulerExecutesBatch() {
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

    insert article;

    VSCCS_ArticlesViewsAndVotesScheduler scheduler = new VSCCS_ArticlesViewsAndVotesScheduler();

    Test.startTest();
    scheduler.execute(null);
    Test.stopTest();
  }
}