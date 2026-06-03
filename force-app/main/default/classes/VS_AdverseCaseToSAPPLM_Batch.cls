/**************************************************************************************************************************
* Program Name         : VS_AdverseCaseToSAPPLM_BatchScheduler
* Description          : Batch job to re-process the failed records(due to system lock error)
* Version              : 1.0
* Modification Log     : 11 September, 2024
*--------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*--------------------------------------------------------------------------------------------------------------------------
*  CCS-644       1.0       Himanshu Mishra        09/11/2024       Initial commit.
*  CCS-1072      1.1       Himanshu Mishra        12/17/2025       Allow mulitple articles  
* 
***************************************************************************************************************************/

public class VS_AdverseCaseToSAPPLM_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    String ApexClassName = 'VS_AdverseCaseToSAPPLM_APIHandler';
    String ApexMethodName = 'processRecords';
    Datetime last60Min = Datetime.now().addMinutes(-60);
    List<String> failedArticleList = new List<String>();
    List<LogEntry__c> reprocessedLogEntryRecords = new List<LogEntry__c>();
    List<Case> reprocessedCaseRecords = new List<Case>();
    String query = 'Select Id,RecordId__c,CreatedDate,Message__c,isDataPublishedToSAP__c,SAP_Articles__c From LogEntry__c where ApexClassName__c =: ApexClassName AND ApexMethodName__c =: ApexMethodName AND isDataPublishedToSAP__c = false AND CreatedDate > '+ last60Min.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        logger.info('Scope -->' +scope);
        if(!scope.isEmpty()){
            for(LogEntry__c lst : (List<LogEntry__c>)scope){
                
                Id caseRecordId = lst.RecordId__c;
                Case caseRecord = [Select CaseNumber, Date_Time_of_Issue__c, VS_Beauty_Adverse_Reaction_Claim_Survey__c,
                Event_Type__c,Is_Record_Published_to_SAP__c From Case where Id =: caseRecordId];
                
                // Create a "failed article" row for notification context
                String failedArticle = lst.SAP_Articles__c+';'+lst.CreatedDate+';'+lst.Message__c;
                failedArticleList.add(failedArticle);
            
                VS_AdverseCaseToSAPPLM_API.FlowInput inputReq = new VS_AdverseCaseToSAPPLM_API.FlowInput();
                inputReq.articleNo                            = lst.SAP_Articles__c;
                inputReq.adverseEventDate                     = caseRecord.Date_Time_of_Issue__c;
                inputReq.sfCaseNumber                         = caseRecord.CaseNumber;
                inputReq.eventType                            = caseRecord.Event_Type__c;
                inputReq.beautyAdverseReactionSurvey          = caseRecord.VS_Beauty_Adverse_Reaction_Claim_Survey__c;
                inputReq.recordId                             = caseRecord.Id;

                // Process via handler
                List<VS_AdverseCaseToSAPPLM_API.FlowOutput> outputList = VS_AdverseCaseToSAPPLM_APIHandler.processRecords(inputReq);
                if(outputList.size() > 0 && outputList[0].isSuccess){
                    reprocessedLogEntryRecords.add(lst);
                }
            }
        }
        logger.saveLog();
    }

    public void finish(Database.BatchableContext BC) {
        logger.info('failedArticleList -->' +failedArticleList);
        logger.saveLog();
        if( failedArticleList.size() > 0 ){
            sendEmail(failedArticleList);
        }
        /*if(reprocessedCaseRecords.size() > 0 ){
            for(Case caseObj : reprocessedCaseRecords){
                caseObj.Is_Record_Published_to_SAP__c = true;
            }
            update reprocessedCaseRecords;
        }*/
        if(reprocessedLogEntryRecords.size() > 0 ){
            for(LogEntry__c logObj : reprocessedLogEntryRecords){
                logObj.isDataPublishedToSAP__c = true;
            }
            update reprocessedLogEntryRecords;
        }
    }
    
    public void sendEmail(List<String> failedArticleList){
        // Create an instance of email message
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        // Set email properties
        List<String> toAddress = Label.SAP_Notifier_List.split(';');
        emailMessage.toaddresses = toAddress;
        emailMessage.setSubject('SF-SAP Adverse Event Data Update Failure Notification');
        
        String emailBody = '<p>Hello PLM B&H Team</p>';
        emailBody += '<p>**This is an autogenerated email, please don’t reply to this email**</p>';
        emailBody += '<p>Please note that the Adverse Event Data update from Salesforce to PLM for the below article(s) failed.</p>';
        // Adding table format for details
        emailBody += '<table border="1" cellpadding="5" cellspacing="0">';
        emailBody += '<tr><th>Article</th><th>Update Date/Time</th><th>Failure Reason</th></tr>';
        for(String article : failedArticleList){
            emailBody += '<tr>';
            emailBody += '<td>' + article.split(';')[0] + '</td>';
            emailBody += '<td>' + article.split(';')[1] + '</td>';
            emailBody += '<td>' + article.split(';')[2] + '</td>';
            emailBody += '</tr>';
        }
        emailBody += '</table>';
        emailBody += '<p>Salesforce will reattempt to send the data for any system related failure. Please check the application(SLG1) log in SAP and take necessary corrective action if the failure pertains to PLM.</p>';
        emailBody += '<p>Thanks & Regards,<br>Salesforce Team </p>';
        
        emailMessage.setHtmlBody(emailBody); // Set HTML body
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
    }
}