public with sharing class NF_CreateCustomerForBot {
  public class Input {
    @InvocableVariable(required=true)
    public String routableId = '';

    @InvocableVariable
    public String fullName;

    @InvocableVariable
    public String emailId;
  }

  public class Output {
    @InvocableVariable
    public Account insertedContact;

    @InvocableVariable
    public String insertedContactId;
  }

  @InvocableMethod(label='Neuraflash - Create Customer')
  public static List<Output> createCustomer(List<Input> inputs) {
    List<Output> result = new List<Output>();
    Output out = new Output();
    try {
      String routableId = inputs[0].routableId;
      String fullName = inputs[0].fullName;
      String emailId = inputs[0].emailId;
      String insertedContactId;
      String insertedAccountId;
      Account insertedContact = NF_Util.createCustomer(
        fullName,
        emailId,
        true,
        null,
        null
      );
      if (insertedContact != null) {
        out.insertedContact = insertedContact;

        Account[] accounts = [
          SELECT ID, PersonContactId
          FROM Account
          WHERE Id = :insertedContact.Id
        ];

        if (accounts.size() > 0) {
          insertedContactId = accounts[0].PersonContactId;
          insertedAccountId = accounts[0].Id;
          out.insertedContactId = insertedContactId;
          System.debug(
            LoggingLevel.DEBUG,
            'NF_CreateCustomerForBot: insertedContactId>>' + insertedContactId
          );
        }
      }
      String endUserId = [
        SELECT MessagingEndUserId
        FROM MessagingSession
        WHERE ID = :routableId
      ]
      .MessagingEndUserId;

      MessagingEndUser endUser = [
        SELECT ContactId, AccountId
        FROM MessagingEndUser
        WHERE ID = :endUserId
      ];
      endUser.ContactId = insertedContactId;
      endUser.AccountId = insertedAccountId;
      endUser.Name = fullName;

      update endUser;
      /* Commented By Himanshu
            List<LiveChatTranscript> chatTranscriptList = [SELECT ID, contactId
                                                            FROM LiveChatTranscript
                                                            WHERE chatkey =: chatKey];
            if(!chatTranscriptList.isEmpty()) {
                chatTranscriptList[0].contactId = insertedContactId;
                update chatTranscriptList[0];
            } */
    } catch (Exception e) {
      System.debug(
        LoggingLevel.DEBUG,
        'NF_CreateCustomerForBot: Exception=' + e.getStacktraceString()
      );
      logger.error('Exception ' + e.getStacktraceString())
        .addTag('NF_CreateCustomerForBot');
    }
    logger.saveLog();
    result.add(out);
    System.debug(
      LoggingLevel.DEBUG,
      'NF_CreateCustomerForBot: returning out=' + out
    );

    return result;
  }
}