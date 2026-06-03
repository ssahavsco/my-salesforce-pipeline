/**
 * @description : puring the records from ArticlesViewsAndVotesToday
 * @author Sumit Saha
 */

global class VSCCS_ArticlesViewsAndVotesTodayPurge implements Database.Batchable<SObject>, Database.Stateful {
  public Integer totalToDelete = 0;
  public Integer totalDeleted = 0;

  global Database.QueryLocator start(Database.BatchableContext bc) {
    PurgeArticlesViews__c var = PurgeArticlesViews__c.getInstance();
    String days = var.Retention_Days__c;
    String queryLimit = var.Query_Limit__c;
    String query =
      'SELECT Id , CreatedDate FROM Articles_views_and_votes_today__c where CreatedDate < LAST_N_DAYS:' +
      days +
      ' order by CreatedDate desc limit ' +
      queryLimit;
    Logger.info(query)
      .addTag('VSCCS_ArticlesViewsAndVotesTodayPurge::' + bc.getJobId());
    Logger.saveLog();
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext bc,
    List<Articles_views_and_votes_today__c> scope
  ) {
    totalToDelete += scope.size();
    try {
      Database.DeleteResult[] results = Database.delete(scope, false);
      for (Database.DeleteResult dr : results) {
        if (dr.isSuccess()) {
          totalDeleted++;
        }
      }
    } catch (Exception e) {
      Logger.error('Error during batch delete: ' + e.getMessage())
        .addTag('VSCCS_ArticlesViewsAndVotesTodayPurge::' + bc.getJobId());
      Logger.saveLog();
    }
  }

  global void finish(Database.BatchableContext bc) {
    String out =
      'Total records identified to delete: ' +
      totalToDelete +
      ' Total records successfully deleted: ' +
      totalDeleted;
    Logger.info(out)
      .addTag('VSCCS_ArticlesViewsAndVotesTodayPurge::' + bc.getJobId());
    Logger.saveLog();
  }
}