@isTest 
public class CaseCarrierFixBatchTest {
    static testMethod void testMethod1() 
    {
        List<Case> caseList = new List<Case>();
        for(Integer i=0 ;i <200;i++)
        {
            Case caseRecord = new Case();
            caseRecord.Carrier__c ='USPS';
            caseList.add(caseRecord);
        }
        
        insert caseList;
        
        Test.startTest();

            CaseCarrierFixBatch obj = new CaseCarrierFixBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}