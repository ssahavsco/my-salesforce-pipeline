/****************************************************************************************************************
* Program Name         : VS_GenericDataDeletionBatchTest
* Description          : Provide coverage to VS_GenericDataDeletionBatch.
* Version              : 1.0
* Modification Log     : 30 April, 2024
*------------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*  CCS-312       1.0       Himanshu Mishra      04/30/2024     Provide coverage to VS_GenericDataDeletionBatch.   
*                                                                                                                                                                                                 
*****************************************************************************************************************/
@IsTest
public class VS_GenericDataDeletionBatchTest {
	static testMethod void deleteDataOlderThanTwoYears(){
        Test.startTest();
        	List<Account> accList = createTestRecord();
            VS_GenericDataDeletionBatch cb = New VS_GenericDataDeletionBatch('Account');
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null, accList);
            cb.Finish(null);
        Test.stopTest();
    }
    static testMethod void deleteDataBetweenSpecificsDates(){
        Test.startTest();
        	DateTime startDate = DateTime.newInstance(2022, 3, 16);
			DateTime endDate = DateTime.newInstance(2022, 4, 1);
        	List<Account> accList = createTestRecord();
            VS_GenericDataDeletionBatch cb = New VS_GenericDataDeletionBatch('Account', startDate, endDate);
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null, accList);
            cb.Finish(null);
        Test.stopTest();
    }
        
    public static List<Sobject> createTestRecord(){
        List<Account> accList = new List<Account>();
        Account accountObj = new Account();
        accountObj.Name = 'Test User1';
        accList.add(accountObj);
        
        Account accountObj2 = new Account();
        accountObj2.Name = 'Test User2';
        accList.add(accountObj2);
        insert accList;
        
        return [Select Id from Account Where Name = 'Test User1' OR Name = 'Test User2'];
    }
}