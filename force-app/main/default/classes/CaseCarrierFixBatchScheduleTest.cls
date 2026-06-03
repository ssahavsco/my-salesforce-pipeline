@isTest
public class CaseCarrierFixBatchScheduleTest {
    static testMethod void testMethod1(){ 
        Test.startTest();
        CaseCarrierFixBatchScheduler sh1 = new CaseCarrierFixBatchScheduler();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Carrier', sch, sh1); 
        Test.stopTest();
    }
}