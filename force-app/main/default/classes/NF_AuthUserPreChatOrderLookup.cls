/*****************************************************************************************************@@
Class Name     :  NF_AuthUserPreChatOrderLookup
Purpose        :  Controller to fethc pre chat details
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                   03/02/2021          Original Version             DP-36414
2.       Himanshu Mishra        02/28/2025          Updated MIAW Changes         DP-91108
     
*********************************************************************************************************/
public with sharing class NF_AuthUserPreChatOrderLookup {
  @InvocableMethod(
    label='Neuraflash - Fetch Order History From PreChat Details'
  )
  public static List<NF_AuthUserOrderLookup.Output> getOrderHistoryFromPreChatDetails(
    List<NF_AuthUserOrderLookup.Input> input
  ) {
    NF_AuthUserOrderLookup.Output output = new NF_AuthUserOrderLookup.Output();
    try {
      MessagingSession msgSession = NF_Util.getMessagingSession(
        input[0].routableId
      );
      if (
        msgSession != null &&
        msgSession.Customer_Type__c == 'Authenticated'
      ) {
        String email = msgSession.Email__c;
        List<Pre_Chat_Detail__c> pcdList = [
          SELECT Id, Email__c, Order_History_Response__c
          FROM Pre_Chat_Detail__c
          WHERE Email__c = :email
          ORDER BY createdDate DESC
          LIMIT 1
        ];
        if (pcdList != null && !pcdList.isEmpty()) {
          output = (NF_AuthUserOrderLookup.Output) JSON.deserialize(
            pcdList[0].Order_History_Response__c,
            NF_AuthUserOrderLookup.Output.class
          );
        } else {
          output.orderResponseSize = 0;
        }
      }
    } catch (exception e) {
      output.orderResponseSize = 0;
    }
    return new List<NF_AuthUserOrderLookup.Output>{ output };
  }
}