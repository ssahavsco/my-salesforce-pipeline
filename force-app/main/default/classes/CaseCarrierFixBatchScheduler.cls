global class CaseCarrierFixBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        CaseCarrierFixBatch batch = new CaseCarrierFixBatch(); 
        Database.executebatch(batch, 100);
    }
}