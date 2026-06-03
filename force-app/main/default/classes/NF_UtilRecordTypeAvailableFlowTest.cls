/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for NF_UtilRecordTypeAvailableFlowInvokable
* SObject, invocable from a flow
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Waddington  <peter.waddington@neuraflash.com>
* @modifiedBy     Peter Waddington  <peter.waddington@neuraflash.com>
* @maintainedBy   Peter Waddington  <peter.waddington@neuraflash.com>
* @version        1.0
* @created        2021-05-11
* @modified       2021-05-11
* @systemLayer    Test
* @jiraNumber     DP-41261
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Peter Waddington  <peter.waddington@neuraflash.com>
*
* First version of class
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest
public with sharing class NF_UtilRecordTypeAvailableFlowTest {
    @IsTest
    public static void testGetRecordTypes() {
        List<NF_UtilRecordTypeAvailableFlowInvokable.RecordTypeQuery> recParams = new List<NF_UtilRecordTypeAvailableFlowInvokable.RecordTypeQuery>();
        NF_UtilRecordTypeAvailableFlowInvokable.RecordTypeQuery param = new NF_UtilRecordTypeAvailableFlowInvokable.RecordTypeQuery();
        param.sObjectName = 'Case';
        recParams.add(param);

        List<NF_UtilRecordTypeAvailableFlowInvokable.RecordTypeResult> rtResults = NF_UtilRecordTypeAvailableFlowInvokable.getRecordTypes(recParams);
        NF_UtilRecordTypeAvailableFlowInvokable.RecordTypeResult rtResult = rtResults[0];

        // For sys admin the default case RT is chat, update if not the case
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Chat_Case').getRecordTypeId();

        System.assertNotEquals(null, rtResult.DefaultRecordTypeId, 'Sys Admin default record type should exist');
        System.assertEquals(true, rtResult.RecordTypeCount > 1, 'System admin should have access to more than 1 RT');

    }
}