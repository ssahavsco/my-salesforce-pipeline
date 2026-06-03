/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VSCCSExtractBeautyAdverseCasesController
Created Date       : Dec 19, 2024
@author            : Kaustubh Chimote <kchimote@victoria.com>
@story             : CCS-807
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class VSCCSExtractBeautyAdverseCasesController {
    @AuraEnabled
    public static String generateExcel(String startDate, String endDate) {
        try {
 
            // Convert string dates to Datetime
            DateTime startDateTime = DateTime.newInstance(
                Integer.valueOf(startDate.substring(0,4)), // year
                Integer.valueOf(startDate.substring(5,7)), // month
                Integer.valueOf(startDate.substring(8,10)), // day
                0, 0, 0 );
 
            DateTime endDateTime = DateTime.newInstance(
                Integer.valueOf(endDate.substring(0,4)), // year
                Integer.valueOf(endDate.substring(5,7)), // month
                Integer.valueOf(endDate.substring(8,10)), // day
                23, 59, 59  );
 
            List<Case> caseList = [SELECT CaseNumber, Notes__c, Unspecified_Article__c, Date_Time_of_Issue__c, VS_Safety_Team_Confirmed_Article__c, VS_Beauty_Adverse_Reaction_Claim_Survey__c, Event_Type__c FROM Case WHERE Type = 'Beauty' AND Sub_Type__c = 'Adverse Reaction - Beauty' AND CreatedDate >= :startDateTime AND CreatedDate <= :endDateTime];
            if (caseList.isEmpty()) {
                throw new AuraHandledException('No records found for the selected date range.'); }
 
            String csvContent = generateExcelContent(caseList);
            return createPublicLink(csvContent);
 
        } catch (Exception e) {
            throw new AuraHandledException('Error generating report: ' + e.getMessage());
        }
    }
 
    public static String generateExcelContent(List<Case> caseList) {
    Set<String> uniqueQuestions = new Set<String>();
    for (Case caseRecord : caseList) {
        if (String.isNotBlank(caseRecord.VS_Beauty_Adverse_Reaction_Claim_Survey__c)) {
            List<String> surveyResponses = caseRecord.VS_Beauty_Adverse_Reaction_Claim_Survey__c.split('<br>');
            for (String response : surveyResponses) {
                if (String.isNotBlank(response)) {
                    List<String> parts = response.split(':');
                    if (parts.size() == 2) {
                        uniqueQuestions.add(parts[0].trim());
                    }
                }
            }
        }
    }

    // Create headers
    String csvContent = 'CaseNumber,Date Time of Issue,Safety Team Confirmed Article,Event Type,Unspecified Article,Notes,VS Beauty Adverse Reaction Claim Survey';
    for (String question : uniqueQuestions) {
        // Enclose question in double quotes and replace any internal double quotes
        csvContent += ',"' + question.replace('"', '""') + '"';
    }
    csvContent += '\n';

    // Generate rows
    for (Case caseRecord : caseList) {
        // Adding base case information
        String row = '"' + (caseRecord.CaseNumber != null ? caseRecord.CaseNumber : '') + '",'; row += '"' + (caseRecord.Date_Time_of_Issue__c != null ? caseRecord.Date_Time_of_Issue__c.format('yyyy-MM-dd HH:mm:ss') : '') + '",'; row += '"' + (caseRecord.VS_Safety_Team_Confirmed_Article__c != null ? caseRecord.VS_Safety_Team_Confirmed_Article__c : '') + '",'; row += '"' + (caseRecord.Event_Type__c != null ? caseRecord.Event_Type__c : '') + '",'; row += '"' + (caseRecord.Unspecified_Article__c == true ? 'Yes' : 'No') + '",'; row += '"' + (caseRecord.Notes__c != null ? caseRecord.Notes__c.replace('"', '""') : '') + '",';

        // Create a map to store question-answer pairs
        Map<String, String> surveyAnswers = new Map<String, String>(); if (String.isNotBlank(caseRecord.VS_Beauty_Adverse_Reaction_Claim_Survey__c)) {  List<String> surveyResponses = caseRecord.VS_Beauty_Adverse_Reaction_Claim_Survey__c.split('<br>'); for (String response : surveyResponses) { if (String.isNotBlank(response)) { List<String> parts = response.split(':'); if (parts.size() == 2) { surveyAnswers.put(parts[0].trim(), parts[1].trim());
                    }
                }
            }
        }

        for (String question : uniqueQuestions) { String answer = surveyAnswers.containsKey(question) ? surveyAnswers.get(question) : ''; answer = answer.replaceAll(',', ' ').replace('"', '""'); row += ',"' + answer + '"'; }

        csvContent += row + '\n';    }

    return csvContent; }

 
    public static String createPublicLink(String csvContent) {
        String fileName = 'SF_Beauty_Adverse_Events_' + DateTime.now().format('yyyy-MM-dd');
        ContentVersion conVersion = new ContentVersion();
        conVersion.Title = fileName;
        conVersion.PathOnClient = fileName + '.csv';
        conVersion.VersionData = Blob.valueOf(csvContent);
        conVersion.IsMajorVersion = true;
        insert conVersion;
 
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVersion.Id].ContentDocumentId;
 
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.Name = fileName;
        contentDistribution.ContentVersionId = conVersion.Id;
        contentDistribution.PreferencesAllowViewInBrowser = true;
        contentDistribution.PreferencesAllowOriginalDownload = true;
        contentDistribution.PreferencesNotifyOnVisit = false;
        contentDistribution.PreferencesNotifyRndtnComplete = false;
        insert contentDistribution;

        ContentDistribution dist = [ SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id = :contentDistribution.Id ];
 
        return dist.ContentDownloadUrl; } }