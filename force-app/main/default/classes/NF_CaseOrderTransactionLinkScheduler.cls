global class NF_CaseOrderTransactionLinkScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        NF_CaseOrderTransactionLinkBatch nf_CaseOrder = new NF_CaseOrderTransactionLinkBatch(); // Your batch class
        database.executeBatch(nf_CaseOrder,1);
    }
}