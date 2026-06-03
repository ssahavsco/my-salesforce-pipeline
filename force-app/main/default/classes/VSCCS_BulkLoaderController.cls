/**************************************************************************************************************************
* Program Name         : VSCCS_BulkLoaderController
* Description          : Controller class to for Bulk data loader
* Version              : 1.0
* Modification Log     : 11 December, 2025
*--------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*--------------------------------------------------------------------------------------------------------------------------
*  CCS-1413      1.0       Himanshu Mishra        12/11/2025       Initial commit 
* 
***************************************************************************************************************************/

public with sharing class VSCCS_BulkLoaderController {
	public RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());
    
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectList() {
        List<String> objectNames = new List<String>();
        
        // Get all objects' descriptions
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        // Loop through the map and filter the objects that are creatable
        for (Schema.SObjectType sObjectType : globalDescribe.values()) {
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            if (describeResult.isCreateable()) {
                objectNames.add(describeResult.getName());
            }
        }
        
        // Sort the list alphabetically
        objectNames.sort();
        
        return objectNames;
    }
    
    @AuraEnabled
    public static String processCSV(String contentDocId, String objectName, String operation, String externalId) {
        //069WB000001eqaPYAQ , 
        ContentVersion file = [SELECT Title, VersionData FROM ContentVersion WHERE IsLatest = TRUE and ContentDocumentId =: contentDocId];
        //ContentVersion file = [SELECT Title, VersionData FROM ContentVersion WHERE IsLatest = TRUE and ContentDocumentId='069WB000001jYEfYAM'];
        //System.debug('out1 '+file.VersionData);
        //String bodyBase64 = EncodingUtil.base64Decode(EncodingUtil.base64Encode(file.VersionData)).toString();
        Blob fileData = file.VersionData;
        Map<String, Object> createJobDetails = createJob(objectName, operation, externalId);
        logger.info('Job '+createJobDetails);
        String jobId = String.valueOf(createJobDetails.get('id'));
        if(!String.isBlank(jobId)){
            uploadJobData(jobId, fileData);
            /*Integer uploadJobStatusCode = 201;
            logger.info('Job Upload Status '+uploadJobStatusCode);
            if(uploadJobStatusCode == 201){
                Map<String, Object> closeJobDetails = closeJob(jobId, 'UploadComplete');
                logger.info('Job Close'+closeJobDetails);
                //SFCallout.getJobStatus(jobId,false);
            }*/
        }
        logger.saveLog();
        return jobId; 
    }
    
    public static Map<String, Object> createJob(String objectName, String operation, String externalId){
        RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());
        
        HttpRequest req = new HttpRequest();
        JobRequestWrapper reqWrap = new JobRequestWrapper();
        reqWrap.objectName = objectName;
        reqWrap.operation = operation;
        reqWrap.contentType = 'CSV';
        reqWrap.lineEnding = 'CRLF';
        if(operation == 'upsert'){
            reqWrap.externalIdFieldName = externalId;
        }
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:' + settings.Named_Credential__c + '/services/data/v60.0'  + '/jobs/ingest');
        String requestBody = JSON.serialize( reqWrap );
        String body = '{ "object": "'+objectName+'", "operation": "'+operation+'", "contentType": "CSV", "lineEnding" : "CRLF" }';
        req.setBody(body);
        req.setMethod('POST');
        
        HttpResponse res = new Http().send(req);
        System.debug(res);
        
        Map<String, Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        
        return response;
    }
    @future(callout=true)
    public static void uploadJobData(String jobId, Blob bodyBase64){
        RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','text/csv');
        req.setHeader('Accept-Charset', 'UTF-8');
        req.setEndpoint('callout:' + settings.Named_Credential__c + '/services/data/v60.0' + '/jobs/ingest/'+jobId+'/batches');
        req.setBodyAsBlob(bodyBase64);
        req.setMethod('PUT');
        
        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 201) closeJob(jobId, 'UploadComplete');
    }
    
    //public static Map<String, Object> closeJob(String jobId, String state){
    public static void closeJob(String jobId, String state){
        RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setEndpoint('callout:' + settings.Named_Credential__c + '/services/data/v60.0' + '/jobs/ingest/'+jobId);
        req.setBody('{ "state":"'+state+'" }');
        req.setMethod('PATCH');
        
        HttpResponse res = new Http().send(req);
        /*Map<String, Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        return response;*/
    }
    
    @AuraEnabled
    public static Map<String,Object> getJobStatus(String jobId){
        // Default: use Ingest API job status (for CSV operations)
        RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());
        String successContentVersionId = '';
        String failedContentVersionId = '';
        String timeStamp = DateTime.now().format('yyyyMMddHHmm');
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + settings.Named_Credential__c + '/services/data/v60.0' + '/jobs/ingest/'+jobId);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        Map<String, Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(response.get('state') == 'JobComplete'){
            // Fetch results as ZIP (base64), save as ContentVersion .zip, and return public download URLs
            /*String successRespBase64 = getResult(jobId , 'successfulResults');
            String failedRespBase64 = getResult(jobId , 'failedResults');
            successContentVersionId = saveResult(successRespBase64, 'success', timeStamp);
            failedContentVersionId = saveResult(failedRespBase64, 'error', timeStamp);
            response.put('downloadSuccessRecords', successContentVersionId);
            response.put('downloadFailedRecords', failedContentVersionId);*/
        }
        logger.saveLog();
        return response;
    }
    
    public static String getResult(String jobId, String resultType){
        RTPL_Settings__c settings = RTPL_Settings__c.getInstance(UserInfo.getUserId());
        HttpRequest req = new HttpRequest();
        // Request ZIP instead of CSV to avoid large response body limits
        req.setHeader('Accept', 'application/zip');
        req.setEndpoint('callout:' + settings.Named_Credential__c + '/services/data/v60.0' + '/jobs/ingest/'+jobId+'/'+resultType);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        // Return as Base64 so we can persist via Blob.valueOf safely
        return EncodingUtil.base64Encode(res.getBodyAsBlob());
    }
    
    public static String saveResult(String respBase64, String resultType, String timeStamp){
        // respBase64 is base64 of ZIP blob
        Blob fileContent = EncodingUtil.base64Decode(respBase64);
        String fileName = resultType + '' + timeStamp;
        ContentVersion conVersion = new ContentVersion();
        conVersion.Title = fileName;
        conVersion.PathOnClient = fileName +'.zip';
        conVersion.VersionData = fileContent;
        conVersion.IsMajorVersion = true;
        insert conVersion;
        
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.Name = fileName;
        contentDistribution.ContentVersionId = conVersion.Id;
        contentDistribution.PreferencesAllowViewInBrowser = true;
        contentDistribution.PreferencesAllowOriginalDownload = true;
        contentDistribution.PreferencesNotifyOnVisit = false;
        contentDistribution.PreferencesNotifyRndtnComplete = false;
        insert contentDistribution;

        ContentDistribution dist = [
            SELECT ContentDownloadUrl 
            FROM ContentDistribution 
            WHERE Id = :contentDistribution.Id
        ];
        return dist.ContentDownloadUrl;
    }
    
    @AuraEnabled
    public static String deleteCoupons(Boolean domestic, Boolean international){
        VSCCS_CouponDeletionBatch batch = new VSCCS_CouponDeletionBatch(domestic, international);
        // Return the AsyncApexJob Id so LWC can poll via SOQL
        Id jobId = Database.executeBatch(batch, 1000);
        return (String)jobId;
    }
        
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDeleteJobStatus(Id asyncJobId){
        // SOQL-based status for Coupon_Offer__c deletion batch
        // Returns: state, numberRecordsProcessed, numberRecordsFailed
        Map<String, Object> result = new Map<String, Object>();
        if (asyncJobId == null) {
            result.put('state', 'Unknown');
            return result;
        }
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate, ExtendedStatus
            FROM AsyncApexJob
            WHERE Id = :asyncJobId
            LIMIT 1
        ];
        // Map AsyncApexJob.Status to LWC expected states
        // Completed => JobComplete, Failed => Failed, others => InProgress variants
        String state;
        if (job.Status == 'Completed') {
            state = 'JobComplete';
        } else if (job.Status == 'Failed' || job.Status == 'Aborted') {
            state = 'Failed';
        } else {
            state = String.valueOf(job.Status);
        }
        result.put('state', state);
        result.put('numberRecordsProcessed', job.JobItemsProcessed);
        result.put('numberRecordsFailed', job.NumberOfErrors);
        // No download links for batch delete
        return result;
    }
    
    public Class JobRequestWrapper{
        String objectName;
        String operation;
        String contentType;
        String lineEnding;
        String externalIdFieldName;
    }
}