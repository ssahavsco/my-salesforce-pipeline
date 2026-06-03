public with sharing class NF_GetUserInfo {
  public class Input {
    @InvocableVariable(required=false)
    public String routableId = '';
  }

  public class Output {
    @InvocableVariable
    public String userEmail = '';

    @InvocableVariable
    public String firstName = '';

    @InvocableVariable
    public String lastName = '';

    @InvocableVariable(required=true)
    public Boolean isAuthenticatedUser;

    @InvocableVariable
    public Boolean isVeryHighValueCustomer;

    @InvocableVariable
    public String userLanguage;
    
    @InvocableVariable
    public String deviceType;
  }

  @InvocableMethod(label='Neuraflash - Get User Info')
  public static List<Output> getUserInfo(List<Input> inputs) {
    List<Output> result = new List<Output>();
    Output out = new Output();

    String routableId = inputs[0].routableId;
      MessagingSession msgSession = NF_Util.getMessagingSession(routableId);
      if (msgSession != null) {
        out.userEmail = msgSession.Email__c;
        String[] emailArray;
        String userFirstName;
        if (!String.isBlank(msgSession.Email__c)) {
          emailArray = msgSession.Email__c.split('@');
          userFirstName = emailArray[0];
        }
        out.firstName = String.isNotBlank(msgSession.FirstName__c)
          ? msgSession.FirstName__c
          : userFirstName;
        out.lastName = msgSession.LastName__c;
        out.deviceType = msgSession.Device_Type__c;
        out.isAuthenticatedUser = msgSession.Customer_Type__c == 'Authenticated'
          ? true
          : false;
        /* LBRAN-39 */
        Messaging_Insight__c botSession = NF_Util.getMessagingInsight(
          routableId
        );
        if (botSession != null) {
          botSession.IsUserAuthenticated__c = out.isAuthenticatedUser;
          update botSession;
        }
        /* CCS-95 */
        Account eachCustomer = NF_Util.getContact(out.userEmail);
        if (eachCustomer != null) {
          out.isVeryHighValueCustomer = eachCustomer.Very_High_Value__c;
        }

        /******* Himanshu Set Language Start *******************/
        if (
          msgSession.Language_Code__c != null &&
          msgSession.Language_Code__c != ''
        ) {
          out.userLanguage = msgSession.Language_Code__c == 'fr_CA'
            ? 'zh_CN'
            : msgSession.Language_Code__c;
        } else {
          out.userLanguage = 'en_US';
        }
        logger.info('User Language ' + out.userLanguage);
        logger.saveLog();
        /******* Himanshu Set Language End *******************/
      } else {
        logger.info('Error in getting user info');
        logger.saveLog();
        System.debug(
          LoggingLevel.DEBUG,
          '>>NF_GetUserInfo getUserInfo failed to retrieve LiveChatTranscript'
        );
      }

    result.add(out);
    return result;
  }
}