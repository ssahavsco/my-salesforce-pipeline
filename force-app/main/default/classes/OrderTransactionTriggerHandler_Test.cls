/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for OrderTransactionTriggerHandler.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-05-05
* @modified       2021-05-05
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class OrderTransactionTriggerHandler_Test {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @TestSetup
    static void setupData(){
        testSetupData();
    }

    @isTest
    static void beforeDeleteTriggerEnabledTest(){
        Integer otCount = [ SELECT COUNT() FROM Order_Transaction__c ];
        System.assertEquals( 3, otCount );

        Case cs = [ SELECT Id FROM Case LIMIT 1 ];
        Test.startTest();
            try{
                delete [ SELECT Id FROM Order_Transaction__c WHERE Case__c = :cs.Id ];
            }catch( Exception ex ){
                System.debug( '@@@@ exception ==>> ' + ex.getMessage() );
            }
        Test.stopTest();

        otCount = [ SELECT COUNT() FROM Order_Transaction__c ];
        System.assertEquals( 3, otCount );
    }

    @isTest
    static void beforeDeleteTriggerDisabledTest(){
        Integer otCount = [ SELECT COUNT() FROM Order_Transaction__c ];
        System.assertEquals( 3, otCount );

        Case cs = [ SELECT Id FROM Case LIMIT 1 ];
        OrderTransactionTriggerHandler.TriggerDisabled = true;
        Test.startTest();
            delete [ SELECT Id FROM Order_Transaction__c WHERE Case__c = :cs.Id ];
        Test.stopTest();

        otCount = [ SELECT COUNT() FROM Order_Transaction__c ];
        System.assertEquals( 0, otCount );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * create initial data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void testSetupData(){
        Case testCase = new Case(
            RecordTypeId = Schema.getGlobalDescribe().get( 'Case' ).getDescribe().getRecordTypeInfosByName().get( 'Chat Case' ).getRecordTypeId(),
            Origin = 'Chat',
            Type = 'Account Update / Email Frequency',
            Status = 'Closed',
            Sub_Type__c = 'Account Info Update'
        );
        insert testCase;

        Order_Transaction__c testOT1 = new Order_Transaction__c(
            Case__c = testCase.Id,
            CID__c = 'customerId1',
            Item_ID__c = '1'
        );
        Order_Transaction__c testOT2 = new Order_Transaction__c(
            Case__c = testCase.Id,
            CID__c = 'customerId2',
            Item_ID__c = '2'
        );
        Order_Transaction__c testOT3 = new Order_Transaction__c(
            Case__c = testCase.Id,
            CID__c = 'customerId3',
            Item_ID__c = '3'
        );
        List<Order_Transaction__c> otList = new List<Order_Transaction__c>{ testOT1, testOT2, testOT3 };
        insert otList;
    }
}