/**
 * @description : puring the records from ArticlesViewsAndVotesToday
 * @author Sumit Saha
 */

@isTest
public with sharing class VSCCS_ArticlesViewsAndVotesPurgeTest {
  @isTest(SeeAllData=true)
  static void testBatchPurge() {
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

    Test.startTest();
    VSCCS_ArticlesViewsAndVotesTodayPurge batch = new VSCCS_ArticlesViewsAndVotesTodayPurge();
    Database.executeBatch(batch);
    Test.stopTest();
  }
}