/****************************************************************************************************************
* Program Name         : VS_CustomerCasesCountTest
* Description          : Test coverage for VS_CustomerCasesCount
* Version              : 1.0
* Modification Log     : 
*------------------------------------------------------------------------------------------------------------
*JiraId       Version    Developer               Date              Description 
*------------------------------------------------------------------------------------------------------------
*DP-56353      1.0       Sharath Vadla        07/07/2022     Test coverage for VS_CustomerCasesCount
*                                                                
*****************************************************************************************************************/

@IsTest
private class VS_CustomerCasesCountTest {
    static Id recordTypeIdPA = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    static Id relationsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Store_Relations_Case').getRecordTypeId();
    
    @IsTest
    static void testCasesCount(){
        Account testAccountA = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account A',
            Case_Count__c = 0
        );
        insert new Account[]{testAccountA};
        Test.startTest();
        Case testCaseRelationsA = new Case(
            RecordTypeId = relationsCaseRecordTypeId,
            AccountId = testAccountA.Id,
            Type = 'Backorders',
            Status = 'New'
        );        
        insert new Case[]{testCaseRelationsA};
         testCaseRelationsA.Type = 'Other';
         update testCaseRelationsA;
         System.assertEquals(1, [Select Id,Case_Count__c From Account Where Id =: testAccountA.Id].size() );
         Test.stopTest();    
    }
    
}