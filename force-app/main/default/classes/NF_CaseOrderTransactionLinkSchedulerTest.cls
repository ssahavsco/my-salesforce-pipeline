@isTest
public  class NF_CaseOrderTransactionLinkSchedulerTest {
    @isTest
    static void testScheduler(){
        Test.startTest();
        NF_CaseOrderTransactionLinkScheduler nf_C = new NF_CaseOrderTransactionLinkScheduler();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, nf_C); 
        Test.stopTest();
    }
}