/**
 * @description : puring the records from ArticlesViewsAndVotesToday
 * @author Sumit Saha
 */

global class VSCCS_ArticlesViewsAndVotesScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    Id jobId = Database.executeBatch(
      new VSCCS_ArticlesViewsAndVotesTodayPurge(),
      200
    );

    Logger.info('The Job Started :: ' + System.now().addHours(-5))
      .addTag('VSCCS_ArticlesViewsAndVotesTodayPurge::' + jobId);
    Logger.saveLog();
  }
}