/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for newCaseController.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-23
* @modified       2021-04-29
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          ravikant.kedia@neuraflash.com
* 2021-04-29    updated test data and method getDetailsTest()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class newCaseController_Test {
    
    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    static void getDetailsTest(){
        Test.startTest();
            String result = newCaseController.getDetails( 'TestCID', '1300' );
            newCaseController.CaseResponse res = ( newCaseController.CaseResponse )JSON.deserialize( 
                result, 
                newCaseController.CaseResponse.class
            );
            System.assertEquals( 'Test Account', res.customer.Name );
            System.assertEquals( 'SAPAccount', res.acc.Name );
        Test.stopTest();
    }

    @isTest
    static void createCaseTest(){
        Test.startTest();
            // Success
            Case cs = new Case(
                RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Chat Case').getRecordTypeId(),
                Origin = 'Chat',
                Type = 'Account Update / Email Frequency',
                Status = 'New',
                Sub_Type__c = 'Account Info Update'
            );
            String result = newCaseController.createCase( JSON.serialize( cs ) );
            newCaseController.SaveData res = ( newCaseController.SaveData )JSON.deserialize( 
                result, 
                newCaseController.SaveData.class
            );
            System.assertEquals( true, res.success );

            // Exception
            cs = new Case(
                RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Chat Case').getRecordTypeId(),
                Origin = 'Exception',
                Type = 'Account Update / Email Frequency',
                Status = 'New',
                Sub_Type__c = 'Exception'
            );
            String exceptionResult = newCaseController.createCase( JSON.serialize( cs ) );
            newCaseController.SaveData exceptionRes = ( newCaseController.SaveData )JSON.deserialize( 
                exceptionResult, 
                newCaseController.SaveData.class 
            );
            System.assertEquals( false, exceptionRes.success );
        Test.stopTest();
    }

    private static void testSetupData(){

        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccountPA = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account',
            CID__c       = 'TestCID'
        );
        insert testAccountPA;

        Account testAccountSAP = new Account(
            Name         = 'SAPAccount',
            SAP_Store__c = '1300'
        );
        insert testAccountSAP;
    }
}