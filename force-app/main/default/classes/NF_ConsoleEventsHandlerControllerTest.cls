/*****************************************************************************************************@@
Class Name     :  NF_ConsoleEventsHandlerControllerTest
Purpose        :  Test class for NF_ConsoleEventsHandlerController
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version            
*********************************************************************************************************/

@isTest(seeAllData=false)
public with sharing class NF_ConsoleEventsHandlerControllerTest {
  @TestSetup
  static void makeData() {
    RecordType personAccountRecordType = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Person Account' AND SObjectType = 'Account'
    ];
    Account acc = new Account();
    acc.firstName = 'Test';
    acc.RecordTypeId = personAccountRecordType.Id;
    acc.lastName = 'Test Name';
    insert acc;

    Contact con = new Contact();
    con.firstName = 'Test';
    con.lastName = 'Customer';
    con.Email = 'con@test.com';
    insert con;

    Case c = new Case();
    c.AccountId = acc.Id;
    insert c;

    String routableId = NF_UtilTest.insertMessagingSessionWithContact(con.Id);

    MessagingSession msgSession = [
      SELECT CaseId
      FROM MessagingSession
      WHERE Id = :routableId
    ];
    msgSession.CaseId = c.Id;
    update msgSession;
      
    Active_Session__c session = new Active_Session__c();
    session.Active_Session_Key__c = 'ABC';
    insert session;
  }

  //When MessagingSession record exists
  @isTest
  static void validate_1() {
    Test.startTest();

    MessagingSession msgSession = [SELECT Id FROM MessagingSession LIMIT 1];
    Case cse = [SELECT Id FROM Case LIMIT 1];
    Contact con = [SELECT Id FROM Contact LIMIT 1];
    NF_ConsoleEventsHandlerController.Response resp = NF_ConsoleEventsHandlerController.getCaseAndContact(
      msgSession.Id
    );
    System.assertEquals(cse.Id, resp.caseId, 'id should match');
    // System.assertEquals(con.Id, resp.contactId);

    Test.stopTest();
  }

  //When LiveChatTranscript record not exists
  @isTest
  static void validate_2() {
    Test.startTest();

    NF_ConsoleEventsHandlerController.Response resp = NF_ConsoleEventsHandlerController.getCaseAndContact(
      'Test'
    );
    NF_ConsoleEventsHandlerController.Response resp1 = new NF_ConsoleEventsHandlerController.Response();
    System.assertEquals(null, resp, 'should have value');

    Test.stopTest();
  }

  static testMethod void getevent() {
    //insert Live Chat Visitor
    MessagingSession msgSession = [SELECT Id, Unique_Identifier__c FROM MessagingSession LIMIT 1];
	msgSession.Unique_Identifier__c = 'TEST_KEY_123';
    Test.startTest();
    NF_ConsoleEventsHandlerController.saveChatEndTime(msgSession.Id);
    NF_ConsoleEventsHandlerController.saveChatTabCloseTime(msgSession.Id);
    NF_ConsoleEventsHandlerController.updateMessagingSessionMetrics(
      msgSession.Id
    );
    NF_ConsoleEventsHandlerController.updateAgentFirstMessageTime(
      msgSession.Id
    );
    NF_ConsoleEventsHandlerController.getInactiveMessage(msgSession.Id);
    NF_ConsoleEventsHandlerController.getCustomerName(msgSession.Id);
    NF_ConsoleEventsHandlerController.changeOwnerToQueue(msgSession.Id);
    NF_ConsoleEventsHandlerController.UpdateAgentInactivity(msgSession.Id);
    NF_ConsoleEventsHandlerController.updateCustomerInactivityTime(
      msgSession.Id
    );
    NF_ConsoleEventsHandlerController.updateEndUserMessageCount(msgSession.Id);
    NF_ConsoleEventsHandlerController.updateActivitySession(msgSession.Id);
    NF_ConsoleEventsHandlerController.sessionIsActive(msgSession.Id);
    system.assertNotEquals(null, msgSession.Id);
    Test.stopTest();
  }
}