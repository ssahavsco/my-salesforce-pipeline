public class AccountVeryHighValueController {
    
    @AuraEnabled
    public static String updateVeryHighValue(List<String> emails) {
       if(emails == null || emails.isEmpty()) return null;
       AccountVeryHighValueControllerBatch batch = new AccountVeryHighValueControllerBatch(emails);
       Id batchJobId = Database.executeBatch(batch, 200);
       return batchJobId;
   }
   
   @AuraEnabled
    public static List<AsyncApexJob> getJobDetails(String jobId){
        try {
            List<AsyncApexJob> asyncJobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob where Id =: jobId ];
            return asyncJobList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   	}

}