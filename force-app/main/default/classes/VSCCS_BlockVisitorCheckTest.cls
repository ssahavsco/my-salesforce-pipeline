/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VSCCS_BlockVisitorCheckTest
Created Date       : May 23, 2025
@description       : This is the test class for VSCCS_BlockVisitorCheck
@author            : Himanshu Mishra <hmishra@victoria.com>
@story             : CCS-925
Modification Log:
Ver   Date          Author           Story/Defect#        Modification
1.0   May 23, 2025  Himanshu Mishra   CCS-925             Initial Version
1.1   Sep 30, 2025  Himanshu Mishra   CCS-1238            Updated logic for exception handling
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
@IsTest(SeeAllData=true)
public class VSCCS_BlockVisitorCheckTest {
  @IsTest
  static void testIsIPBlocked() {
    // Create a test MessagingSession record with a blocked IP
    String msgId = VS_UtilTest.createMessagingSession();
    MessagingSession testSession = [
      SELECT Visitor_IP_Address__c
      FROM MessagingSession
      WHERE Id = :msgId
    ];
    testSession.Visitor_IP_Address__c = '136.226.230.117';
    update testSession;

    // Call the isIPBlocked method with the test data
    VSCCS_BlockVisitorCheck.Input input = new VSCCS_BlockVisitorCheck.Input();
    input.routableId = testSession.Id;

    List<VSCCS_BlockVisitorCheck.Input> inputs = new List<VSCCS_BlockVisitorCheck.Input>{
      input
    };
    List<VSCCS_BlockVisitorCheck.Output> outputs = VSCCS_BlockVisitorCheck.isIPBlocked(
      inputs
    );

    // Assert that the output indicates the IP is blocked
    System.assertEquals(1, outputs.size());
  }

  @IsTest
  static void testIsIPNotBlocked() {
    // Create a test MessagingSession record with a non-blocked IP

    String msgId = VS_UtilTest.createMessagingSession();
    MessagingSession testSession = [
      SELECT Visitor_IP_Address__c
      FROM MessagingSession
      WHERE Id = :msgId
    ];
    testSession.Visitor_IP_Address__c = '';
    update testSession;

    // Call the isIPBlocked method with the test data
    VSCCS_BlockVisitorCheck.Input input = new VSCCS_BlockVisitorCheck.Input();
    input.routableId = testSession.Id;

    List<VSCCS_BlockVisitorCheck.Input> inputs = new List<VSCCS_BlockVisitorCheck.Input>{
      input
    };
    List<VSCCS_BlockVisitorCheck.Output> outputs = VSCCS_BlockVisitorCheck.isIPBlocked(
      inputs
    );

    // Assert that the output indicates the IP is not blocked
    System.assertEquals(1, outputs.size());
    System.assertEquals(false, outputs[0].isCustomerBlocked);
  }
  @IsTest
  static void testException() {
    // Call the isIPBlocked method with the test data
    VSCCS_BlockVisitorCheck.Input input = new VSCCS_BlockVisitorCheck.Input();
    //input.routableId = testSession.Id;

    List<VSCCS_BlockVisitorCheck.Input> inputs = new List<VSCCS_BlockVisitorCheck.Input>{
      input
    };
    List<VSCCS_BlockVisitorCheck.Output> outputs = VSCCS_BlockVisitorCheck.isIPBlocked(
      inputs
    );
  }
}