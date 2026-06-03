global class NF_DRSAccountAutoMergeSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        // check records created in the last 25 hours
        Datetime dtPast = Datetime.now().addHours(-25);
        Datetime dtNow = Datetime.now();
        LoggerUtility.insertProcessLog('NF_DRSAccountAutoMergeSchedulable', 'execute', 'Scheduled instance of Auto Merge process for timeframe: '+dtPast.format()+' to '+dtNow.format()+' starting');
        NF_DuplicateRecordSetAccountAutoMerge duplicateRecordJob = new NF_DuplicateRecordSetAccountAutoMerge(dtPast, dtNow, false); 
        Database.executebatch(duplicateRecordJob, 5);
    }
}