@isTest
public class VSCCS_MonitorOAuthUsageTest {
	
    @isTest
    static void testScheduler(){
        Test.startTest();
        VSCCS_MonitorOAuthUsage monitorUsage = new VSCCS_MonitorOAuthUsage();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Monitor OAuth Usage', sch, monitorUsage); 
        Test.stopTest();
    }
}