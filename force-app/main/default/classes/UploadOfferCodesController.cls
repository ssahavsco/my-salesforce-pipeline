public class UploadOfferCodesController {

    @AuraEnabled
    public static Id processInputFile(String csvContent, Boolean isChecked, Boolean isInternational) {
        Id jobId;
        Integer count=0;
        Integer totalCount = 0;
        try{
            //Logic to delete the existing records
            if(isChecked){
                jobId = Database.executeBatch(new UploadOfferCodesBatch(false));
                return jobId;
            }
            
            //Logic to insert the new records
            List<String> csvData = csvContent.split('\n');            
            List<Coupon_Offer__c> newOfferCodeList = new List<Coupon_Offer__c>();
            
            for (String csvLine : csvData) {
                System.debug('CSV '+csvLine);
                String offerCode = csvLine.trim();
                if(count != 0){
                    Coupon_Offer__c offerCodeObj = new Coupon_Offer__c();
                    offerCodeObj.Coupon_Offer_Code__c = offerCode;
                    offerCodeObj.Is_International__c = isInternational;
                    newOfferCodeList.add(offerCodeObj);
                }
                count++;
                totalCount++;
                System.debug('Offer Code ' +newOfferCodeList);
                if(count == 10001 || totalCount == csvData.size()){
                    jobId = Database.executeBatch(new UploadOfferCodesBatch(newOfferCodeList, false));
                    newOfferCodeList.clear();
                    count = 1;
                }
            }
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