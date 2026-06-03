/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for Get Customer Info By Hashed Id component.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Himanshu Mishra  <hmishra@victoria.com>
* @version        1.1
* @created        2023-09-20
* @Jira Number    CCS-166
* ──────────────────────────────────────────────────────────────────────────────────────────────────
**/
public class GetCustomerInfoByHashedCIDController {
    
    @AuraEnabled
    public static Id processInputFile(String csvContent, String userEmail) {
        Id jobId;
        try{
            List<String> csvData = csvContent.split('\n');
            List<String> hashedIdList = new List<String>();
            for (String csvLine : csvData) {
                hashedIdList.add(csvLine.trim());
            }
            hashedIdList.remove(0);  //To remove header row
            jobId = Database.executeBatch(new GetCustomerInfoByHashedCIDBatch(hashedIdList,userEmail), 200);
        } catch(Exception err){
            logger.error('Error while parsing CSV '+err);
            logger.saveLog();
            throw new AuraHandledException(err.getMessage());
        }
        return jobId;
    }
    
    @AuraEnabled
    public static List<AsyncApexJob> getJobDetails(String jobId){
        try {
            List<AsyncApexJob> asyncJobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems,
                                                NumberOfErrors FROM AsyncApexJob where Id =: jobId ];
            return asyncJobList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}