/* updated for LBRAN-65 */
/* updated for CCS-119 - Himanshu - 08/30/2023
 * Modified By - Himanshu Mishra - 02/28/2025
 * Accomodate MIAW changes
 * */
public with sharing class NF_CheckExistingCaseContact {
  public class Input {
    @InvocableVariable(required=true)
    public String routableId = '';

    @InvocableVariable
    public String userEmail;
  }

  public class Output {
    @InvocableVariable
    public Account existingContactRecord;

    @InvocableVariable
    public String existingContactRecordId;

    @InvocableVariable
    public Case existingCaseRecord;

    @InvocableVariable
    public String existingCaseNumber;

    @InvocableVariable
    public Boolean isContactExists;

    @InvocableVariable
    public Boolean isCaseAlreadyExists; //within 24hrs

    /* added for LBRAN-65 */
    @InvocableVariable
    public String existingCaseId;
  }

  @InvocableMethod(label='Neuraflash - Get Existing Case and Contact')
  public static List<Output> getExistingInfo(List<Input> inputs) {
    List<Output> result = new List<Output>();
    Output out = new Output();
    out.isContactExists = false;
    out.isCaseAlreadyExists = false;

    String routableId = inputs[0].routableId;
    String contactEmail = inputs[0].userEmail;
    /*List<LiveChatTranscript> chatTranscriptList = [SELECT ID, ContactId, CaseId
                                                        FROM LiveChatTranscript
                                                        WHERE chatkey =: chatKey];
        */
    List<MessagingSession> msgSessionList = [
      SELECT ID, MessagingEndUserId, CaseId
      FROM MessagingSession
      WHERE Id = :routableId
    ];

    if (!msgSessionList.isEmpty()) {
      Account eachCustomer = NF_Util.getContact(contactEmail);
      if (eachCustomer != null) {
        out.isContactExists = true;
        out.existingContactRecord = eachCustomer;
        out.existingContactRecordId = eachCustomer.PersonContactId;
        /*   CCS-119 - Commented to re-use the existing case
                Case eachCase = NF_Util.getCaseRelatedToContact(eachCustomer.PersonContactId);
                if(eachCase !=null) {
                    out.isCaseAlreadyExists = true;
                    out.existingCaseRecord = eachCase;
                    out.existingCaseNumber = eachCase.CaseNumber;
                    out.existingCaseId = eachCase.Id;    // added for LBRAN-65 
                    chatTranscriptList[0].CaseId = eachCase.Id;
                    chatTranscriptList[0].Is_Case_Reused__c = true;
                    eachCase.Is_Case_Reused__c = true;
                    update eachCase;
                }
                */
        try {
          MessagingEndUser endUser = [
            SELECT Name, AccountId, ContactId
            FROM MessagingEndUser
            WHERE ID = :msgSessionList[0].MessagingEndUserId
          ];
          endUser.ContactId = eachCustomer.PersonContactId;
          endUser.AccountId = eachCustomer.Id;
          endUser.Name = eachCustomer.Name;
          update endUser;
        } catch (Exception e) {
          logger.error('Error ' + e)
            .addTag('NF_CheckExistingCaseContact_getExistingInfo');
        }
        logger.saveLog();
        //chatTranscriptList[0].ContactId = eachCustomer.PersonContactId;
        //update chatTranscriptList[0];
      }
    }

    result.add(out);
    return result;
  }
}