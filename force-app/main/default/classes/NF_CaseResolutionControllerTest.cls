/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for NF_CaseResolutionController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Waddington  <peter.waddington@neuraflash.com>
* @modifiedBy     Peter Waddington  <peter.waddington@neuraflash.com>
* @maintainedBy   Peter Waddington  <peter.waddington@neuraflash.com>
* @version        1.0
* @created        2021-04-28
* @modified       2021-04-28
* @systemLayer    Test
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Peter Waddington <peter.waddington@neuraflash.com>
*               DP-37125 and others:
*               Test class to provide coverage for the NF_CaseResolutionController class
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest
public with sharing class NF_CaseResolutionControllerTest {
    
    // Test to provide baseline coverage for the class
    @IsTest
    public static void testGetCaseOrderTransactions() {
        // create a new case object with minimal data
        Case c = new Case(Subject='Test');
        insert c;
        Date d = Date.parse('01/31/2021');
        // create a transaction related to the case
        Order_Transaction__c ot = new Order_Transaction__c(
            Store_Number__c = '1',
            Transaction_Date__c = d,
            Register_Number__c = '2',
            Transaction_Number__c = '3',
            Payment_Method__c = '4',
            Case__c = c.Id
        );
        insert ot;
        
        // get OT for the Case
        List<Order_Transaction__c> lot = NF_CaseResolutionController.getCaseOrderTransactions(c.Id);

        // check the OT we created is the first element returned
        System.assertEquals(lot[0].Payment_Method__c, '4', 'Order Transaction case should match');

        // searching for a non-existent case should return a list with no items
        lot = NF_CaseResolutionController.getCaseOrderTransactions('fakeId');
        System.assertEquals(lot.size(), 0, 'Bad ID should return blank list');

        // searching for a null case id should return a list with no items
        lot = NF_CaseResolutionController.getCaseOrderTransactions(null);
        System.assertEquals(lot.size(), 0, 'Null Case ID returns a blank list');
    }
}