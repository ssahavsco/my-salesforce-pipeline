/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Batch class for Get Customer Info By Hashed Id controller.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Himanshu Mishra  <hmishra@victoria.com>
* @version        1.1
* @created        2023-09-20
* @Jira Number    CCS-166
* ──────────────────────────────────────────────────────────────────────────────────────────────────
**/
global class GetCustomerInfoByHashedCIDBatch implements Database.Batchable<sObject> , Database.Stateful{
    
    private List<String> setOfInputIds = new List<String>();
    private String finalStr = 'Hashed Id'+','+'Email'+'\n';
    private String query = '';
    private String currentUserEmail;
    
    global GetCustomerInfoByHashedCIDBatch(List<String> inputIds, String userEmail){
        setOfInputIds = inputIds;
        currentUserEmail = userEmail;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query='SELECT Hashed_CID__c,PersonEmail FROM Account WHERE Hashed_CID__c In : setOfInputIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        System.debug('accountList '+accountList);
        for (Account acc : accountList) {
            finalStr += acc.Hashed_CID__c +','+acc.PersonEmail+'\n';
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('finalStr2 '+finalStr);
        Blob excel = Blob.valueOf(finalStr);
        ContentVersion conVersion = new ContentVersion();
        conVersion.Title = String.valueOf('GetCustomerInfoByHashedCID - ' + date.today().format());
        conVersion.PathOnClient = String.valueOf('GetCustomerInfoByHashedCID - ' + date.today().format() +'.csv');
        conVersion.VersionData = excel;
        conVersion.IsMajorVersion = true;
        Insert conVersion;
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setBody(excel);
        attach.setFileName(String.valueOf('GetCustomerInfoByHashedCID - ' + date.today().format() + '.csv'));
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> recipientsNameList = new List<String>();
        recipientsNameList.add(currentUserEmail);
        String[] toAddresses = recipientsNameList;
        mail.setToAddresses(toAddresses);
        mail.setSubject('GetCustomerInfoByHashedCID - ' + Datetime.now() + ' - ' + BC.getJobId());
        string htmlBody = 'Hi Team, <br/> <br/>';
        htmlBody += 'Please see the attached document for customer email addresses for the needed Hashed Id. <br/><br/>';
        htmlBody += 'Thanks & Regards, <br/>';
        htmlBody+= 'Himanshu';
        mail.setHtmlBody(htmlBody);
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}