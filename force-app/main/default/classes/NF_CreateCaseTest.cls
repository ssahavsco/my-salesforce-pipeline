/**
 * Created by mcasella on 9/4/20.
 */

@IsTest
public with sharing class NF_CreateCaseTest {
  static String routableId, sessionID, chatlogID;

  @IsTest
  public static void createCase() {
    Test.startTest();
    routableId = NF_UtilTest.createMessagingSession();
    System.debug(
      LoggingLevel.DEBUG,
      '>> Created dummy msg session: ' + routableId
    );
    Messaging_Insight__c session = NF_UtilTest.insertMessagingInsight(
      routableId
    );
    Messaging_Bot_Chat_Log__c chatlog = NF_UtilTest.insertChatLog(session);
    SessionID = session.Id;
    chatlogID = chatlog.Id;

    System.debug(LoggingLevel.DEBUG, '>> Created dummy session: ' + sessionID);
    System.debug(LoggingLevel.DEBUG, '>> Created dummy chat log: ' + chatlogID);
    System.debug(
      LoggingLevel.DEBUG,
      '>> Last utterance on chatlog: ' + chatlog.Current_Utterance__c
    );

    NF_CreateCase.Output[] res = callCreateCase(routableId);
    String caseNumber = res[0].caseNumber;
    System.assert(String.isNotEmpty(caseNumber), 'should have value');
    System.debug(
      LoggingLevel.DEBUG,
      '>> Case returned from NF_CreateCase: ' + caseNumber
    );

    Test.stopTest();
  }

  @IsTest
  public static void getCaseType() {
    String routableId = NF_UtilTest.createMessagingSession();
    String dataField1 = 'Sizing/Fit and Product Information';
    String dataField2 = 'UGG';
    String dataField4 = 'test description field';

    Test.startTest();

    Messaging_Insight__c session = NF_UtilTest.insertMessagingInsight(
      routableId
    );
    Messaging_Bot_Chat_Log__c log = NF_UtilTest.insertChatLog(session);
    log.Data_Field_1__c = dataField1;
    log.Data_Field_2__c = dataField2;
    log.Data_Field_4__c = dataField4;
    update log;

    Test.stopTest();

    List<Messaging_Bot_Chat_Log__c> logs = NF_Util.getMessagingChatLogs(
      null,
      routableId
    );
    Map<String, String> caseData = NF_CreateCase.getCaseType(logs);

    //System.assertEquals(dataField1, caseType, 'should have correct case type');
  }

  @IsTest
  public static void getInvalidCaseType() {
    String routableId = NF_UtilTest.createMessagingSession();
    String dataField1 = 'VS Stores 123';
    String dataField2 = 'fake';

    Test.startTest();

    Messaging_Insight__c session = NF_UtilTest.insertMessagingInsight(
      routableId
    );
    Messaging_Bot_Chat_Log__c log = NF_UtilTest.insertChatLog(session);
    log.Data_Field_1__c = dataField1;
    log.Data_Field_2__c = dataField2;
    update log;

    Test.stopTest();

    List<Messaging_Bot_Chat_Log__c> logs = NF_Util.getMessagingChatLogs(
      null,
      routableId
    );
    Map<String, String> caseData = NF_CreateCase.getCaseType(logs);
    Boolean isEmptyMap = caseData.isEmpty();
    System.assertEquals(true, isEmptyMap, 'Empty Map');
  }

  @IsTest
  static void createContact() {
    String routableId = 'abc';
    String fullName = 'Test User';
    String email = 'test@nf.com';
    NF_CreateCase.createContact(routableId, fullName, email);

    Contact c = [SELECT Id, Name FROM Contact];
    System.assertEquals(c.Name, fullName);
  }

  @IsTest
  static void getDeviceType() {
    System.assertEquals('', NF_CreateCase.getDeviceType(''));
    System.assertEquals('Phone', NF_CreateCase.getDeviceType('Mobile'));
    System.assertEquals('Tablet', NF_CreateCase.getDeviceType('iPad'));
    System.assertEquals('Desktop/Laptop', NF_CreateCase.getDeviceType('Linux'));
  }

  @IsTest
  static void DP_33642() {
    Test.startTest();
    routableId = NF_UtilTest.createMessagingSession();
    System.debug(
      LoggingLevel.DEBUG,
      '>> Created dummy transcript: ' + routableId
    );
    Messaging_Insight__c session = NF_UtilTest.insertMessagingInsight(
      routableId
    );
    Messaging_Bot_Chat_Log__c chatlog = NF_UtilTest.insertChatLog(session);
    SessionID = session.Id;
    chatlogID = chatlog.Id;

    String routableId = 'abc';
    String fullName = 'Test User';
    String email = 'test@nf.com';
    String contactId = NF_CreateCase.createContact(routableId, fullName, email);

    NF_CreateCase.Input input = new NF_CreateCase.Input();
    input.userOfferCode = 'Actually, I have applied 2 offer codes and at the end they weren’t applied. \nAnd the shipping is free for $50 purchases if using the VS credit card';
    input.contactId = contactId;
    input.routableId = routableId;
    input.isAuthUser = false;
    input.userComments = 'Details: cancel order # W037895947';
    List<NF_CreateCase.Input> inputs = new List<NF_CreateCase.Input>{ input };
    NF_CreateCase.createCase(inputs);

    Case[] cases = [SELECT Id FROM Case];
    //System.assertEquals(1, cases.size());

    Test.stopTest();

    //        "inputs": [
    //        {
    //        "userOfferCode": "Actually, I have applied 2 offer codes and at the end they weren’t applied. \nAnd the shipping is free for $50 purchases if using the VS credit card.",
    //        "orderNumber": null,
    //        "existingCaseId": null,
    //        "contactId": "0033h00000JpuusAAB",
    //        "chatKey": "f5f8d489-36df-4973-8b1a-1a28d375da33",
    //        "isAuthUser": false,
    //        "userComments": "Details: cancel order # W037895947"
    //    }
    //    ]
    //    }
  }

  @TestVisible
  static NF_CreateCase.Output[] callCreateCase(String transid) {
    NF_CreateCase.Input testInput = new NF_CreateCase.Input();
    testInput.routableId = transid;

    System.debug(
      LoggingLevel.DEBUG,
      'Calling createCase() - routableId: ' + transid
    );

    List<NF_CreateCase.Input> inputs = new List<NF_CreateCase.Input>();
    inputs.add(testInput);

    List<NF_CreateCase.Output> results = NF_CreateCase.createCase(inputs);

    System.assert(results != null, 'should have value');
    return results;
  }
}