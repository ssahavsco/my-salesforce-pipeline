/**
 * Created by mcasella on 9/4/20.
 * Modified By - Himanshu Mishra - 02/28/2025
 * Accomodate MIAW changes
 */

@IsTest
public with sharing class NF_UtilTest {
  // @IsTest
  // public static void getMessagingSession() {
  //   String routableId = 'abc';
  //   String url = 'https://www.victoriassecret.com';
  //   String pageName = 'VS';
  //   String token = 'def';
  //   //String browser = 'Chrome';
  //   //String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36';

  //   Id contactId = NF_CreateCase.createContact(
  //     routableId,
  //     'Test User',
  //     'test@nf.com'
  //   );

  //   MessagingSession msgSession = createMessagingSession();
  //   //msgSession.Browser = browser;
  //   msgSession.Page_Name__c = pageName;
  //   //msgSession.UserAgent = userAgent;
  //   //msgSession.ContactId = contactId;
  //   upsert msgSession;

  //   MessagingSession getMsgSession = NF_Util.getMessagingSession(routableId);
  //   System.assertEquals(getMsgSession.JWT_Token__c, token, '');
  //   System.assertEquals(getMsgSession.Page_URL__c, url, '');
  //   System.assertEquals(getMsgSession.Page_Name__c, pageName, '');
  //   //System.assertEquals(getMsgSession.Browser, browser);
  //   //System.assertEquals(getMsgSession.UserAgent, userAgent);
  //   System.assertEquals(getMsgSession.EndUserContactId, contactId, '');
  // }

  public static String createMessagingSession() {
    String channelId = createMessagingChannel();
    MessagingEndUser endUser = new MessagingEndUser();
    endUser.Name = 'Test End User'; // Required field
    endUser.MessageType = 'EmbeddedMessaging'; // Required field
    endUser.MessagingChannelId = channelId; // Required field
    endUser.MessagingPlatformKey = 'Test User'; // Required field
    insert endUser;

    MessagingSession session = new MessagingSession();
    session.MessagingChannelId = channelId;
    session.MessagingEndUserId = endUser.Id;
    session.Status = 'Ended';
    session.AgentType = 'Agent';
    insert session;

    return session.Id;
  }

  public static String insertMessagingSessionWithContact(String contactId) {
    String channelId = createMessagingChannel();
    MessagingEndUser endUser = new MessagingEndUser();
    endUser.Name = 'Test End User'; // Required field
    endUser.MessageType = 'EmbeddedMessaging'; // Required field
    endUser.MessagingChannelId = channelId; // Required field
    endUser.MessagingPlatformKey = 'Test User'; // Required field
    endUser.contactId = contactId;
    insert endUser;

    MessagingSession session = new MessagingSession();
    session.MessagingChannelId = channelId;
    session.MessagingEndUserId = endUser.Id;
    session.Status = 'Ended';
    session.AgentType = 'Agent';
    insert session;

    MessagingSessionMetrics metric = new MessagingSessionMetrics(
      MessagingSessionId = session.Id,
      MessagingSessionMetricType = 'AgentMessageCount',
      MessagingSessionMetricValue = 5
    );
    insert metric;

    MessagingSessionMetrics metric2 = new MessagingSessionMetrics(
      MessagingSessionId = session.Id,
      MessagingSessionMetricType = 'EndUserMessageCount',
      MessagingSessionMetricValue = 10
    );
    insert metric2;
    MessagingSessionMetrics metric3 = new MessagingSessionMetrics(
      MessagingSessionId = session.Id,
      MessagingSessionMetricType = 'MaxAgentResponseTime',
      MessagingSessionMetricValue = 100
    );
    insert metric3;
    MessagingSessionMetrics metric4 = new MessagingSessionMetrics(
      MessagingSessionId = session.Id,
      MessagingSessionMetricType = 'AverageEndUserResponseTime',
      MessagingSessionMetricValue = 100
    );
    insert metric4;

    return session.Id;
  }
  @IsTest
  public static void testMessagingMethods() {
    String routableId = createMessagingSession();
    MessagingSession msgSession = NF_Util.getMessagingSession(routableId);
    NF_Util.insertMessagingInsight(routableId, 'test');
    Messaging_Insight__c msgInsight = NF_Util.getMessagingInsight(routableId);
    Messaging_Bot_Chat_Log__c chatLog = insertChatLog(msgInsight);
    List<Messaging_Bot_Chat_Log__c> botChatLogsList = NF_Util.getMessagingChatLogs(
      msgInsight,
      routableId
    );
    Messaging_Bot_Chat_Log__c botChatLogsWithIntent = NF_Util.getLastBusinessIntent(
      new List<Messaging_Bot_Chat_Log__c>{ chatLog }
    );
  }

  @IsTest
  public static void testCustomerMethods() {
    Account acc = NF_Util.createCustomer(
      'Abc Xyz',
      'abc@test.com',
      true,
      '',
      ''
    );
    acc = NF_Util.getContact('abc@test.com');
    Set<String> contactEmailSet = new Set<String>{ 'abc@test.com' };
    List<Account> accList = NF_Util.getRelatedPersonAccount(contactEmailSet);
    Case newCaseObj = NF_Util.createCase(acc.PersonContactId, '');
    Case createdCase = NF_Util.getCaseRelatedToContact(acc.PersonContactId);
  }

  public static String createMessagingChannel() {
    User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();
    MessagingChannel channel;
    System.runAs(platformIntegrationUser) {
      channel = new MessagingChannel();
      channel.DeveloperName = 'Test_Channel';
      channel.MasterLabel = 'Test Channel';
      channel.MessageType = 'EmbeddedMessaging';
      channel.MessagingPlatformKey = 'Test Channel';
      insert channel;
    }
    return channel.Id;
  }

  public static Messaging_Insight__c insertMessagingInsight(String routableId) {
    Messaging_Insight__c session = new Messaging_Insight__c();
    session.Messaging_Session__c = routableId;
    insert session;
    return session;
  }

  public static Messaging_Bot_Chat_Log__c insertChatLog(
    Messaging_Insight__c session
  ) {
    Messaging_Bot_Chat_Log__c log = new Messaging_Bot_Chat_Log__c();
    log.Messaging_Insight__c = session.Id;
    log.Intent_Name__c = 'bus_testIntent_end';
    log.Current_Utterance__c = 'firstUserInput';
    log.Live_Agent_Session_Id__c = session.Messaging_Session__c;
    insert log;
    return log;
  }
  public static MessagingSession insertMessagingSession(
    String routableId,
    String pageUrl,
    String token,
    String contactId
  ) {
    MessagingEndUser endUser = new MessagingEndUser();
    endUser.Name = 'Test End User'; // Required field
    endUser.MessageType = 'EmbeddedMessaging'; // Required field
    endUser.MessagingPlatformKey = 'Test User';
    endUser.MessagingChannelId = createMessagingChannel(); // Required field
    endUser.ContactId = contactId; // Optional but included for completeness
    insert endUser;

    MessagingSession msgSession = new MessagingSession();
    msgSession.MessagingEndUserId = endUser.Id;

    if (String.isNotEmpty(routableId)) {
      msgSession.Id = routableId;
    }

    if (String.isNotEmpty(pageUrl)) {
      msgSession.Page_URL__c = pageUrl;
    }

    if (String.isNotEmpty(token)) {
      msgSession.JWT_Token__c = token;
    }

    insert msgSession;

    return msgSession;
  }

  //
  @isTest
  static void validateSharedFunctions() {
    Einstein_Bot_Dialog_Configuration__mdt dialogMetadata = NF_Util.getEinsteinBotDialogConfiguration();
    LBrandsAPI__c lbAPIs = NF_Util.getLBrandAPISettings();
    String sObjectPrefix = NF_Util.getObjectPrefix('MessagingSession');
    SObjectType testCase = NF_Util.getSobjectFromString('Case');
    System.assertEquals(
      Case.getSObjectType(),
      testCase,
      'Running getSobjectFromString for Case should return a Case'
    );

    List<RecordTypeInfo> caseRecordTypes = NF_Util.getAvailableRecordTypes(
      'Case'
    );
    List<RecordTypeInfo> allCaseRecordTypes = Case.getSObjectType()
      .getDescribe()
      .getRecordTypeInfos();
    Integer allCaseRTCount = allCaseRecordTypes.size();
    for (RecordTypeInfo rti : allCaseRecordTypes) {
      if (!rti.isAvailable() || rti.getName() == 'Master') {
        allCaseRTCount--;
      }
    }
    System.assertEquals(
      caseRecordTypes.size(),
      allCaseRTCount,
      'Tested function should return as many record types as the source object, minus one for Master'
    );

    List<PicklistEntry> picklistEntryValues = NF_Util.getAvailableFieldResults(
      'Case',
      'Status'
    );
    Boolean foundValueInPicklist = false;
    for (PicklistEntry ple : picklistEntryValues) {
      if (ple.getValue() == 'New') {
        foundValueInPicklist = true;
      }
    }
    System.assertEquals(
      true,
      foundValueInPicklist,
      'Case Status New should be one of the available status values'
    );

    picklistEntryValues = NF_Util.getAvailableFieldResults('Case', 'Origin');
    foundValueInPicklist = false;
    for (PicklistEntry ple : picklistEntryValues) {
      if (ple.getValue() == 'Phone') {
        foundValueInPicklist = true;
      }
    }
    System.assertEquals(
      true,
      foundValueInPicklist,
      'Case Origin Phone should be one of the available status values'
    );

    picklistEntryValues = NF_Util.getAvailableFieldResults(
      'Case',
      'Description'
    );
    System.assertEquals(
      0,
      picklistEntryValues.size(),
      'a field that is not a picklist should return a list sized 0'
    );

    picklistEntryValues = NF_Util.getAvailableFieldResults('Case', 'Stat');
    System.assertEquals(
      null,
      picklistEntryValues,
      'a field that does not exist should return null'
    );

    picklistEntryValues = NF_Util.getAvailableFieldResults('Casess', 'Status');
    System.assertEquals(
      null,
      picklistEntryValues,
      'an object that does not exist should return null'
    );
  }

  // Single param overload
  // This generates a User for a given profile name using a default alias
  // Use this when you only need 1 user
  public static User generateSampleUserForProfile(string profileName) {
    return NF_UtilTest.generateSampleUserForProfile(profileName, 'Test');
  }

  // Generate a user for a given set of params, currently profile and alias, returns the user
  public static User generateSampleUserForProfile(
    string profileName,
    string alias
  ) {
    Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName];
    String randValueString = String.valueOf(
        Integer.valueof((Math.random() * 10000))
      )
      .leftPad(6, '0');
    User u = new User(
      ProfileId = p.Id,
      FirstName = 'User',
      LastName = alias,
      Alias = 'a' + alias,
      Email = 'test' + alias + '@example.com',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      UserName = alias + randValueString + '@example.com',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US'
    );
    insert u;
    return u;
  }
}