/*****************************************************************************************************@@
Class Name     :  NF_CreateCase
Purpose        :  Create Case for the chatbot.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       mcasella               09/4/2020           Original Version             LBRAN-65
2.       manishi               	09/1/2021           Add cancel order message 
													to case description			 DP-39921
3.       zali                   02/22/2022          Added check to append case
                                                     Description                 DP-53443
4. 		 Himanshu				07/23/2023			Added changes for the 
													isAwaitingPaymentProcess	 CCS-8
@Testsuite:  {NF_CreateCaseTest}        
*********************************************************************************************************/
public with sharing class NF_CreateCase {
  public static final String ORIGIN = 'Chatbot';
  public static final String CHAT_ORIGIN = 'Chat';
  public static final String RECORD_TYPE = 'Chat Case';
  public static final String STATUS = 'New';
  public static final String QUEUE_NAME = 'Customer_Care_Case';

  public class Input {
    @InvocableVariable(required=false)
    public String routableId; // required so the bot can reference the current conversation

    @InvocableVariable(required=false)
    public String contactId; // optional so that Case Creation can still create a Case without a Person Account

    @InvocableVariable(required=false)
    public String userComments;

    @InvocableVariable(required=false)
    public Boolean isAuthUser;

    @InvocableVariable(required=false)
    public String orderNumber;

    @InvocableVariable(required=false)
    public String existingCaseId;

    @InvocableVariable(required=false)
    public String userOfferCode;

    @InvocableVariable(required=false)
    public String associateHoldMessage;

    @InvocableVariable(required=false)
    public Boolean isAwaitingPayment;
  }

  public class Output {
    @InvocableVariable(required=true)
    public String caseNumber;

    @InvocableVariable(required=false)
    public String errorMessage;
  }

  @InvocableMethod(label='NeuraFlash - Create Case')
  public static List<Output> createCase(List<Input> input) {
    String routableId = input[0].routableId;
    System.debug(LoggingLevel.DEBUG, 'NF_CreateCase: routableId=' + routableId);

    String contactId = input[0].contactId;
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase: contactId=[' + contactId + ']'
    );

    String userComments = input[0].userComments;
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase: userComments=[' + userComments + ']'
    );

    String associateHoldMessage = input[0].associateHoldMessage;
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase: userComments=[' + associateHoldMessage + ']'
    );

    Boolean isAuthUser =
      input[0].isAuthUser != null && Boolean.valueOf(input[0].isAuthUser);
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase: isAuthUser=[' + isAuthUser + ']'
    );

    String existingCaseId = input[0].existingCaseId;
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase: existingCaseId=[' + existingCaseId + ']'
    );

    Output output = new Output();

    logger.info(
      'NF_CreateCase -> ' +
        associateHoldMessage +
        ' - ' +
        isAuthUser +
        ' - ' +
        existingCaseId
    );

    try {
      MessagingSession msgSession = NF_Util.getMessagingSession(routableId);
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase: msgSession=' + msgSession
      );

      Case newCase = initializeCase(
        routableId,
        isAuthUser,
        existingCaseId,
        ORIGIN,
        true
      );

      NF_CreateCase.populateFieldsFromMsgSession(
        newCase,
        msgSession,
        contactId,
        true
      );

      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase: Upserting new case: ' + newCase
      );

      try {
        /* Chatbot specific fields */
        Messaging_Insight__c insight = NF_Util.getMessagingInsight(routableId);
        List<Messaging_Bot_Chat_Log__c> chatLogs = NF_Util.getMessagingChatLogs(
          insight,
          null
        );

        Map<String, String> caseData = getCaseType(chatLogs);
        if (!caseData.isEmpty()) {
          if (caseData.containsKey('caseType')) {
            newCase.Type = caseData.get('caseType');
          }
          if (caseData.containsKey('caseSubType')) {
            newCase.Sub_Type__c = caseData.get('caseSubType');
          }
          if (caseData.containsKey('caseDescription')) {
            newCase.Description = caseData.get('caseDescription');
          }
        }

        if (String.isNotBlank(userComments)) {
          /* DP-53443 edit to append user comments to case description*/
          if (String.isNotBlank(newCase.Description)) {
            newCase.Description = newCase.Description + '\n' + userComments;
          }
          /* DP-39921 starts to append the cancel message */

          else if (
            String.isNotBlank(associateHoldMessage) &&
            newCase.Description != null
          ) {
            newCase.Description =
              newCase.Description +
              '\n' +
              userComments +
              '\n' +
              associateHoldMessage;
          } else if (String.isNotBlank(associateHoldMessage)) {
            newCase.Description = userComments + '\n' + associateHoldMessage;
          } else {
            //long text area
            newCase.Description = userComments;
          }

          /* DP-39921 ends */
          /* DP-53443 ends */
        } else {
          /* DP-39921 starts to append the cancel message */
          if (String.isNotBlank(associateHoldMessage)) {
            newCase.Description =
              getCaseDescription(existingCaseId) +
              '\n' +
              associateHoldMessage;
          }
          /* DP-39921 ends */
        }

        /* CCS-8 starts to add VOC contact coding for Awaiting Payment Process */
        if (associateHoldMessage == 'AWAITING PAYMENT HOLD') {
          newCase.Type = 'Pre-Shipment: Order Detail and Status';
          newCase.Sub_Type__c = 'Review Order Details';
        }
        /* CCS-8 end  */

        if (
          !String.isBlank(input[0].orderNumber) &&
          newCase.Type != 'Place a new order'
        ) {
          newCase.Order_Number__c = input[0].orderNumber.length() <= 50
            ? input[0].orderNumber
            : input[9].orderNumber.substring(0, 50);
        }

        if (String.isNotEmpty(input[0].userOfferCode)) {
          newCase.Offer_Code1__c = input[0].userOfferCode.length() <= 50
            ? input[0].userOfferCode
            : input[0].userOfferCode.substring(0, 50);
        }
      } catch (Exception e) {
        logger.error(
          'NF_CreateCase: error setting Case fields: ' + e.getMessage()
        );
        System.debug(
          LoggingLevel.ERROR,
          'NF_CreateCase: error setting Case fields: ' + e.getMessage()
        );
        output.errorMessage += e.getMessage();
      }
      logger.info('New Case Details ' + newCase);
      upsert newCase;

      associateMsgSessionWithCase(msgSession, newCase.id, contactId);
      associateCaseWithSession(routableId, newCase.Id);

      Case CreatedCaseNumber = [
        SELECT CaseNumber
        FROM Case
        WHERE Id = :newCase.id
      ];
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase: New Case Number: ' + CreatedCaseNumber.CaseNumber
      );
      output.caseNumber = CreatedCaseNumber.CaseNumber;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase: exception=' + e.getMessage()
      );
      output.errorMessage += e.getMessage();
      logger.error('NF_CreateCase: exception=' + e.getMessage());
    }
    logger.saveLog();
    return new List<Output>{ output };
  }

  //creating a brand new Case, sharing logic between Chat and Chatbot
  public static Case initializeCase(
    String routableId,
    Boolean isAuthUser,
    String existingCaseId,
    String origin,
    Boolean setCaseOwner
  ) {
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase.initializeCase: need to create a new Case'
    );

    Case newCase = new Case();

    try {
      newCase.Origin = origin;
      newCase.Subject = getSubject(routableId);
      newCase.Chat_Created_Date__c = Date.valueOf(System.now());

      RecordType rt = getRecordType();
      if (rt != null) {
        newCase.recordTypeId = rt.id;
      }
      if (setCaseOwner) {
        Group caseQueue = NF_Util.getQueue(QUEUE_NAME);
        if (caseQueue != null) {
          newCase.OwnerId = caseQueue.Id;
        }
      }

      //TODO: set Auth Status for Partial Auth
      newCase.userAuth__c = isAuthUser ? 'Authenticated' : 'Not Authenticated';

      /* start of LBRAN-65 */
      if (String.isNotBlank(existingCaseId)) {
        newCase.Id = existingCaseId;
      }
      /* end of LBRAN-65 */
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'NF_CreateCase: Error initializing Case=' + e.getMessage()
      );
      logger.info('Error initializing Case=' + e.getMessage());
      logger.saveLog();
    }

    return newCase;
  }

  public static void populateFieldsFromTranscript(
    Case theCase,
    LiveChatTranscript lct,
    String contactId,
    Boolean createContact
  ) {
  }
  //Use the MsgSession to fill in fields on the Case
  public static void populateFieldsFromMsgSession(
    Case theCase,
    MessagingSession msgSession,
    String contactId,
    Boolean createContact
  ) {
    try {
      if (theCase != null) {
        system.debug('msgSession>>>' + msgSession);
        if (msgSession != null) {
          theCase.SourceId = msgSession.Id;

          /* Set Device Type */
          //if (String.isNotBlank(msgSession.Browser_Used__c))
          //theCase.Device_Type__c = getDeviceType(msgSession.UserAgent);
          theCase.Device_Type__c = msgSession.Device_Type__c;
          /* Set Invocation URL to Page name / Page URL */
          if (String.isNotEmpty(msgSession.Page_Name__c)) {
            theCase.invocationURL__c = msgSession.Page_Name__c;
          } else if (String.isNotEmpty(msgSession.Page_URL__c)) {
            theCase.invocationURL__c = msgSession.Page_URL__c;
          }
        }

        /* Attach the contact, or attempt to create one */
        if (String.isNotEmpty(contactId)) {
          theCase.ContactId = contactId;
        } else if (msgSession != null && createContact) {
          contactId = createContact(
            msgSession.Id,
            msgSession.FirstName__c,
            msgSession.Email__c
          );
        }

        /* Commeneted By Himanshu
                if(String.isNotEmpty(msgSession.Browser)){
                    theCase.Browser_Used__c = msgSession.Browser;
                    
                }*/

        if (msgSession.CreatedDate != null) {
          theCase.Date_Time_of_Issue__c = msgSession.CreatedDate;
        }
      }
    } catch (Exception e) {
      logger.info(
        'NF_CreateCase.populateFieldsFromMsgSession: error populating case with msgSession=' +
          msgSession +
          '\n' +
          e.getMessage()
      );
      logger.saveLog();
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase.populateFieldsFromMsgSession: error=' + e.getMessage()
      );
    }
  }

  @TestVisible
  private static String getDeviceType(String userAgent) {
    if (String.isEmpty(userAgent))
      return '';

    if (userAgent.contains('iPad')) {
      return 'Tablet';
    } else if (userAgent.contains('Tablet')) {
      return 'Tablet';
    } else if (userAgent.contains('Mobile')) {
      return 'Phone';
    } else if (userAgent.contains('Android')) {
      return 'Tablet';
    } else if (userAgent.contains('iPhone')) {
      return 'Phone';
    } else {
      return 'Desktop/Laptop';
    }
  }

  public static Boolean associateMsgSessionWithCase(
    MessagingSession msgSession,
    String caseId,
    String contactId
  ) {
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase.associateMsgSessionWithCase: msgSession=' + msgSession
    );
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase.associateMsgSessionWithCase: caseId=' + caseId
    );
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase.associateMsgSessionWithCase: contactId=' + contactId
    );

    boolean result = false;

    if (msgSession != null) {
      try {
        if (String.isNotEmpty(caseId)) {
          msgSession.caseId = caseId;
        }

        String endUserId = msgSession.MessagingEndUserId;
        MessagingEndUser endUser = [
          SELECT ContactId, Contact.Email
          FROM MessagingEndUser
          WHERE ID = :endUserId
        ];

        if (String.isNotEmpty(contactId) && String.isEmpty(endUser.ContactId)) {
          endUser.ContactId = contactId;
          System.debug(
            LoggingLevel.DEBUG,
            'Associated contactId ' +
              contactId +
              ' to msgSession ' +
              msgSession.Id
          );
        }
        msgSession.Email__c = msgSession.Email__c ?? endUser?.Contact?.Email;
        msgSession.Customer_Type__c = msgSession.Customer_Type__c ??
          'Unauthenticated';
        update endUser;
        update msgSession;

        result = true;
      } catch (Exception e) {
        //NF_EinsteinBotLogger.populatedLog(e);
        System.debug(
          LoggingLevel.DEBUG,
          'Exception encountered while updating msgSession: ' + e
        );
        System.debug(LoggingLevel.DEBUG, 'Line: ' + e.getLineNumber());
        System.debug(LoggingLevel.DEBUG, 'Trace: ' + e.getStackTraceString());
        result = false;
      }
    }

    return result;
  }

  @Future
  public static void associateCaseWithSession(
    String caseId,
    String routableId
  ) {
    if (String.isNotBlank(routableId)) {
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase associateCaseWithSession: routableId=' + routableId
      );

      Messaging_Insight__c insight = NF_Util.getMessagingInsight(routableId);
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase associateCaseWithSession: insight=' + insight
      );

      if (insight != null && String.isNotBlank(caseId)) {
        insight.Case__c = caseId;
        System.debug(
          LoggingLevel.DEBUG,
          'NF_CreateCase associateCaseWithSession: Case__c=' + insight.Case__c
        );

        update insight;
      }
    }
  }

  public static RecordType getRecordType() {
    RecordType[] recordTypes = [
      SELECT Id
      FROM RecordType
      WHERE Name = :RECORD_TYPE
      LIMIT 1
    ];

    return recordTypes.size() > 0 ? recordTypes[0] : null;
  }

  /* DP-39921 starts to get existing case description */
  private static String getCaseDescription(String caseId) {
    String existingCaseDescription = '';
    if (String.isNotBlank(caseId)) {
      List<Case> caseList = [
        SELECT ID, Description
        FROM Case
        WHERE Id = :caseId
        LIMIT 1
      ];
      if (!caseList.isEmpty()) {
        existingCaseDescription = caseList[0].Description;
      }
    }
    return existingCaseDescription;
  }
  /* DP-39921 ends to get existing case description */

  private static String getSubject(String routableId) {
    String subject = '';
    if (String.isNotBlank(routableId)) {
      //review business intents to get the first utterance from the user
      for (Messaging_Bot_Chat_Log__c chatLog : [
        SELECT Current_Utterance__c
        FROM Messaging_Bot_Chat_Log__c
        WHERE Live_Agent_Session_Id__c = :routableId
        ORDER BY CreatedDate ASC
      ]) {
        if (String.isNotBlank(chatLog.Current_Utterance__c)) {
          subject = chatLog.Current_Utterance__c;
          if (subject != null && subject.length() > 255) {
            subject = subject.substring(0, 255);
          }

          System.debug(
            LoggingLevel.DEBUG,
            'NF_CreateCase getCaseSubject: using utterance for subject=' +
            subject
          );
          break;
        }
      }
      //if we weren't able to find an utterance from the history
      if (String.isBlank(subject)) {
        //if it's empty here, just default to 'Chatbot Case'
        subject = 'Chatbot Case';
      }
    }

    return subject;
  }

  /**method below is to get case data for a new case from mdts*/
  @TestVisible
  private static Map<String, String> getCaseType(
    List<Messaging_Bot_Chat_Log__c> chatLogs
  ) {
    Map<String, String> caseData = new Map<String, String>();
    String caseTypeFromMetadata = '';
    String caseSubTypeFromMetadata = '';
    String caseType = '';
    String caseSubType = '';
    String description = '';

    if (chatLogs != null) {
      for (Messaging_Bot_Chat_Log__c chatLog : chatLogs) {
        if (String.isNotBlank(chatLog.Data_Field_1__c)) {
          caseTypeFromMetadata = chatLog.Data_Field_1__c;
        }
        if (String.isNotBlank(chatLog.Data_Field_2__c)) {
          caseSubTypeFromMetadata = chatLog.Data_Field_2__c;
        }
        if (String.isNotBlank(chatLog.Data_Field_4__c)) {
          description = chatLog.Data_Field_4__c;
          caseData.put('caseDescription', description);
        }
      }
    }

    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase getCaseType: found caseTypeFromMetadata=' +
      caseTypeFromMetadata
    );

    if (
      String.isNotBlank(caseTypeFromMetadata) ||
      String.isNotBlank(caseSubTypeFromMetadata)
    ) {
      caseTypeFromMetadata = caseTypeFromMetadata.trim();

      Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

      Schema.DescribeFieldResult subFieldResult = Case.Sub_Type__c.getDescribe();
      List<Schema.PicklistEntry> subPLE = subFieldResult.getPicklistValues();

      for (Schema.PicklistEntry f : ple) {
        if (caseTypeFromMetadata.equalsIgnoreCase(f.getValue())) {
          caseType = caseTypeFromMetadata;
          caseData.put('caseType', caseType);
          break;
        }
      }
      for (Schema.PicklistEntry f : subPLE) {
        if (caseSubTypeFromMetadata.equalsIgnoreCase(f.getValue())) {
          caseSubType = caseSubTypeFromMetadata;
          caseData.put('caseSubType', caseSubType);
          break;
        }
      }
    }

    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCase getCaseType: returning caseType=' + caseType
    );

    return caseData;
  }

  @TestVisible
  private static String createContact(
    String routableId,
    String fullName,
    String email
  ) {
    String contactId = '';

    try {
      NF_CreateCustomerForBot.Input input = new NF_CreateCustomerForBot.Input();
      List<NF_CreateCustomerForBot.Input> inputs = new List<NF_CreateCustomerForBot.Input>();
      input.routableId = routableId;
      input.fullName = fullName;
      input.emailId = email;
      inputs.add(input);

      List<NF_CreateCustomerForBot.Output> createCustomerOutputs = NF_CreateCustomerForBot.createCustomer(
        inputs
      );

      if (createCustomerOutputs.size() > 0) {
        contactId = createCustomerOutputs[0].insertedContactId;
        System.debug(
          LoggingLevel.DEBUG,
          'NF_CreateCase.createContact: updated contactId=' + contactId
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCase.createContact: Exception while creating contact=' +
        e.getMessage()
      );
    }

    return contactId;
  }
}