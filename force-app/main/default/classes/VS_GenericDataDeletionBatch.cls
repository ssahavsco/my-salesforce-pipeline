/**********************************************************************************************************
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Generic class to delete data older than 2 years as well as for speicifc duration
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * It can accept 2 types of parameter.
 * 	1. Only object name --> To delete data older than 2 years
 *  2. Object Name, Start Date, End Date --> To delete specific object data for specific duration
 * 
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * Author	- Himanshu Mishra
 * Version	- 1.0
 * Jira		- CCS-312
 **********************************************************************************************************/
global class VS_GenericDataDeletionBatch implements Database.Batchable<sObject> {
    
    public String query;
    
    global VS_GenericDataDeletionBatch(String objectApiName){
        Integer year = Date.today().year() - 2;
        Integer month = Date.today().month();
        Integer day = Date.today().day();
        Datetime dateOnTwoYearsAgo = datetime.newInstance(year, month, day);
        query = 'SELECT Id, CreatedDate FROM ' + objectApiName + ' WHERE CreatedDate < ' + dateOnTwoYearsAgo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
    
    global VS_GenericDataDeletionBatch(String objectApiName, DateTime startDate, DateTime endDate){
        query = 'SELECT Id FROM ' + objectApiName + ' WHERE CreatedDate >= ' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND CreatedDate < ' + endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
    
    /*Added against CCS-418 by Rahul Sharma on 12-June-2024 *****START******/
    global VS_GenericDataDeletionBatch(String objectApiName, integer noOfDays){
        Integer year = Date.today().year();
        Integer month = Date.today().month();
        Integer day = Date.today().day() - noOfDays;
        Datetime dateOnSixMothnsAgo = datetime.newInstance(year, month, day);
        query = 'SELECT Id, CreatedDate FROM ' + objectApiName + ' WHERE CreatedDate < ' + dateOnSixMothnsAgo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
    /*Added against CCS-418 by Rahul Sharma on 12-June-2024 *****END******/

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
        //System.debug('Scope '+scope);
    }

    public void finish(Database.BatchableContext BC) {
        // Perform any post-processing logic here
    }
}