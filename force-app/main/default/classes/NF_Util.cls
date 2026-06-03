/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Purpose is to update the Util fucntions to support custom picklist
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Peter Waddington  <peter.waddington@neuraflash.com>
 * @modifiedBy     Peter Waddington  <peter.waddington@neuraflash.com>
 * @maintainedBy   Peter Waddington  <peter.waddington@neuraflash.com>
 * @version        1.0
 * @created        2020-05-11
 * @modified       2021-05-11
 * @systemLayer    Util function
 * @jiraNumber     DP-37102
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @changes
 * v1.0          Peter Waddington  <peter.waddington@neuraflash.com>
 *
 * First version of class
 *
 * v1.1         Zain Ali         <zain.ali@neuraflash.com>
 *
 * Enhanced Query under 'getChatLogs' method to retrieve more ebotData fields
 *
 * v1.2         Himanshu         <hmishra@victoria.com>
 * Added getObjectPrefix method
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */

public with sharing class NF_Util {
  /* case 24hr logic comapre date to be used by Bot and Live Chat. */
  public static final Datetime CASE_24_HOUR_DATE = System.now().addHours(-24);

  public static Messaging_Insight__c getMessagingInsight(String routableId) {
    Messaging_Insight__c[] botSessions = [
      SELECT Id, IsUserAuthenticated__c, CarouselContent__c,Messaging_Session__c
      FROM Messaging_Insight__c
      WHERE Messaging_Session__c = :routableId
      LIMIT 1
    ];

    return botSessions.size() > 0 ? botSessions[0] : null;
  }
  public static void insertMessagingInsight(String routableId, String payload) {
    System.debug(LoggingLevel.DEBUG, 'bot session creation started.');
    Messaging_Insight__c session = new Messaging_Insight__c();
    session.CarouselContent__c = payload;
    session.Messaging_Session__c = routableId;
    insert session;
    System.debug(LoggingLevel.DEBUG, 'bot session created');
  }
  public static MessagingSession getMessagingSession(String sessionId) {
    System.debug(
      LoggingLevel.DEBUG,
      '>>NF_Util.getLiveChatTranscript chatKey is ' + sessionId
    );
    if (String.isEmpty(sessionId)) {
      System.debug(
        LoggingLevel.DEBUG,
        '>>NF_Util.getLiveChatTranscript Cannot find LiveChatTranscript, chatKey is empty'
      );
      logger.info('Cannot find LiveChatTranscript, chatKey is empty')
        .addTag('NF_Util.getLiveChatTranscript');
      logger.saveLog();
      return null;
    }

    List<MessagingSession> listMessagingSession = new List<MessagingSession>();

    try {
      listMessagingSession = [
        SELECT
          Id,
          Email__c,
          FirstName__c,
          LastName__c,
          JWT_Token__c,
          Page_URL__c,
          Page_Name__c,
          CreatedDate,
          Customer_Type__c,
          Language_Code__c,
          MessagingEndUserId,
          Device_Type__c
        FROM MessagingSession
        WHERE Id = :sessionId
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }

    return listMessagingSession.size() > 0 ? listMessagingSession[0] : null;
  }

  public static Einstein_Bot_Dialog_Configuration__mdt getEinsteinBotDialogConfiguration() {
    List<Einstein_Bot_Dialog_Configuration__mdt> configs = new List<Einstein_Bot_Dialog_Configuration__mdt>();

    try {
      configs = [
        SELECT Id, Live_Chat_Available__c, Create_Offline_Case__c
        FROM Einstein_Bot_Dialog_Configuration__mdt
        WHERE Label = :'Customer Care'
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }

    return configs.size() > 0 ? configs[0] : null;
  }

  public static Account getContact(String email) {
    List<Account> contactList = new List<Account>();
    try {
      if (String.isNotBlank(email)) {
        contactList = [
          SELECT Id, Name, Very_High_Value__c, PersonContactId
          FROM Account
          WHERE PersonEmail = :email
        ];
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return contactList.size() > 0 ? contactList[0] : null;
  }

  public static Case getCaseRelatedToContact(String contactId) {
    List<Case> caseList = new List<Case>();
    try {
      //DateTime compareDate = System.now().addHours(-24);
      /* added "Phone" origin per DP-60634 - blake */
      if (String.isNotBlank(contactId)) {
        caseList = [
          SELECT ID, CaseNumber, ContactId, CreatedDate, LastModifiedDate
          FROM Case
          WHERE
            ContactId = :contactId
            AND status != 'Closed'
            AND Origin != 'Twitter'
            AND Origin != 'Facebook'
            AND Origin != 'Instagram'
            AND Origin != 'Social'
            AND Origin != 'Email'
            AND Origin != 'Phone'
            AND LastModifiedDate >= :CASE_24_HOUR_DATE
          ORDER BY LastModifiedDate DESC
        ];
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return caseList.size() > 0 ? caseList[0] : null;
  }

  /* for Live chat */
  public static List<Account> getRelatedPersonAccount(
    Set<String> contactEmailSet
  ) {
    List<Account> accountList = new List<Account>();
    try {
      if (!contactEmailSet.isEmpty()) {
        accountList = [
          SELECT
            Id,
            PersonEmail,
            PersonContactId,
            Case_Subject__pc,
            (
              SELECT Id, Subject
              FROM Cases
              WHERE
                Status != 'Closed'
                AND LastModifiedDate >= :NF_Util.CASE_24_HOUR_DATE
                AND Contact.Email IN :contactEmailSet
              ORDER BY LastModifiedDate DESC
              LIMIT 1
            )
          FROM Account
          WHERE PersonEmail IN :contactEmailSet
          ORDER BY PersonEmail, LastModifiedDate DESC
        ];
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return accountList;
  }

  public static Account createCustomer(
    String fullName,
    String emailId,
    Boolean isInsert,
    String FirstName,
    String LastName
  ) {
    try {
      List<String> firstAndLastNameList = new List<String>();
      Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId();
      if (String.isNotBlank(fullName)) {
        firstAndLastNameList = splitFullNameIntoFirstAndLast(fullName);
      } else {
        firstAndLastNameList.add(FirstName);
        firstAndLastNameList.add(LastName);
      }

      Account newPersonAccount = new Account(
        firstName = firstAndLastNameList[0],
        lastName = firstAndLastNameList[1],
        personEmail = emailId,
        RecordTypeId = personAccRecordTypeId
      );
      if (isInsert) {
        insert newPersonAccount;
      }

      return newPersonAccount;
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return null;
  }

  public static Case createCase(String contactId, String userQuery) {
    try {
      Case newCase = new Case();
      insert newCase;
      return newCase;
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return null;
  }

  public static Group getQueue(String developerName) {
    Group[] groups = [
      SELECT Id, DeveloperName
      FROM Group
      WHERE DeveloperName = :developerName
      LIMIT 1
    ];

    return groups.size() > 0 ? groups[0] : null;
  }

  public static List<String> splitFullNameIntoFirstAndLast(String fullName) {
    //grab the first name and parse it
    String firstName;
    String lastName;
    List<String> resultList = new List<String>();
    if (!String.isEmpty(fullName)) {
      //tokenize the full name
      List<String> names = fullName.split(' ');
      if (!names.isEmpty()) {
        //set the first name, and a default last name
        firstName = names.remove(0);
        lastName = 'no_lastname_provided';

        if (!names.isEmpty()) {
          lastName = names[0];
          names.remove(0);
          while (!names.isEmpty()) {
            lastName += ' ' + names[0];
            names.remove(0);
          }
        }
      }
    }
    resultList.add(firstName);
    resultList.add(lastName);
    return resultList;
  }

  public static String getOrderMenuItem(
    NF_OrderHistoryService.OrderHistoryResponse order
  ) {
    if (order == null)
      return '';

    String menuItem = 'Order';

    menuItem += order.orderNumber;

    if (order.orderDate != null) {
      menuItem += ' placed on ' + order.orderDate;
    }

    return menuItem;
  }

  public static User getPlatformIntegrationUser() {
    User[] users = [
      SELECT Id, Name
      FROM User
      WHERE Name = 'Platform Integration User'
      LIMIT 1
    ];
    return users.size() > 0 ? users[0] : null;
  }

  public static List<Messaging_Bot_Chat_Log__c> getMessagingChatLogs(
    Messaging_Insight__c botSession,
    String routableId
  ) {
    List<Messaging_Bot_Chat_Log__c> chatLogs = new List<Messaging_Bot_Chat_Log__c>();

    if (botSession == null && String.isNotBlank(routableId)) {
      botSession = getMessagingInsight(routableId);
    }

    if (botSession != null) {
      chatLogs = [
        SELECT
          Id,
          Intent_Name__c,
          Current_Dialog_Name__c,
          Current_Utterance__c,
          Data_Field_1__c,
          Data_Field_2__c,
          Data_Field_3__c,
          Data_Field_4__c
        FROM Messaging_Bot_Chat_Log__c
        WHERE Messaging_Insight__c = :botSession.Id
        ORDER BY Name DESC
        LIMIT 50
      ];
    }

    return chatLogs;
  }
  public static Messaging_Bot_Chat_Log__c getLastBusinessIntent(
    List<Messaging_Bot_Chat_Log__c> chatLogs
  ) {
    Messaging_Bot_Chat_Log__c lastBusinessIntent = null;
    try {
      if (chatLogs != null) {
        for (Messaging_Bot_Chat_Log__c chatLog : chatLogs) {
          System.debug(
            LoggingLevel.DEBUG,
            '>>NF_Util.getLastBusinessIntent: chatLog=' + chatLog
          );
          String intentName = String.isNotEmpty(chatLog.Intent_Name__c)
            ? chatLog.Intent_Name__c
            : chatLog.Current_Dialog_Name__c;
          System.debug(
            LoggingLevel.DEBUG,
            '>>NF_Util.getLastBusinessIntent: chatLog=' + intentName
          );

          if (
            String.isNotEmpty(intentName) && intentName.substring(0, 3) == 'bus'
          ) {
            lastBusinessIntent = chatLog;
            break;
          }
        }
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    System.debug(
      LoggingLevel.DEBUG,
      '>>NF_Util.getLastBusinessIntent: lastBusinessIntent=' +
      lastBusinessIntent
    );

    return lastBusinessIntent;
  }

  /* to get live agent site url stored in custom setting */
  public static LBrandsAPI__c getLBrandAPISettings() {
    LBrandsAPI__c returnedAPISetting;
    try {
      List<LBrandsAPI__c> lBrandsAPISettings = [
        SELECT ID, Live_Agent_Site_Url__c
        FROM LBrandsAPI__c
      ];
      returnedAPISetting = lBrandsAPISettings[0];
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return returnedAPISetting;
  }

  // get an SObjectType from it's name as a String
  public static SObjectType getSobjectFromString(string name) {
    Type sobj = Type.forName(name);
    if (sobj != null) {
      return ((SObject) sobj.newInstance()).getSObjectType();
    } else {
      return null;
    }
  }

  // get the set of available record type infos for a given object for the current user, with Master removed
  public static List<RecordTypeInfo> getAvailableRecordTypes(
    string sObjectName
  ) {
    SObjectType sObjType = NF_Util.getSobjectFromString(sObjectName);
    List<RecordTypeInfo> availableRecordTypeInfos = new List<RecordTypeInfo>();
    for (
      RecordTypeInfo recordTypeInfo : sObjType.getDescribe()
        .getRecordTypeInfos()
    ) {
      if (
        recordTypeInfo.isAvailable() && recordTypeInfo.getName() != 'Master'
      ) {
        availableRecordTypeInfos.add(recordTypeInfo);
      }
    }
    return availableRecordTypeInfos;
  }

  // Get a list of picklist entries for a given sobject's field
  public static List<PicklistEntry> getAvailableFieldResults(
    string sObjectName,
    string fieldName
  ) {
    SObjectType sObjType = NF_Util.getSobjectFromString(sObjectName);
    return sObjType
      ?.getDescribe()
      .fields
      ?.getMap()
      .get(fieldName)
      ?.getDescribe()
      .getPicklistValues();
  }

  public static String getObjectPrefix(String objName) {
    return Schema.getGlobalDescribe().get(objName).getDescribe().getKeyPrefix();
  }

  /* to get chat button id based on developer name */
  public static Id getChatButtonId(String buttonDeveloperName) {
    Id chatButtonId;
    try {
      List<LiveChatButton> chatButtonIdList = [
        SELECT Id
        FROM LiveChatButton
        WHERE DeveloperName = :buttonDeveloperName
        LIMIT 1
      ];
      chatButtonId = chatButtonIdList[0].Id;
    } catch (Exception e) {
      System.debug(LoggingLevel.DEBUG, 'Exception encountered: ' + e);
    }
    return chatButtonId;
  }
}