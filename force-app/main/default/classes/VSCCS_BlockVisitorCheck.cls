/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VSCCS_BlockVisitorCheckTest
Created Date       : Mar 22, 2025
@description       : This is the test class for VSCCS_BlockVisitorCheck
@author            : Himanshu Mishra <hmishra@victoria.com>
@story             : CCS-703
Modification Log:
Ver   Date          Author           Story/Defect#        Modification
1.0   Mar 22, 2025  Himanshu Mishra   CCS-925             Retrieve blocked customer details based on IP Address
1.1   Sep 30, 2025  Himanshu Mishra   CCS-1238            Updated logic for IPv6
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class VSCCS_BlockVisitorCheck {
  public class Input {
    @InvocableVariable
    public String routableId;
  }

  public class Output {
    @InvocableVariable
    public Boolean isCustomerBlocked;
  }
  // Method to check if the IP is blocked
  @InvocableMethod(label='Block Customer Based on IP Address')
  public static List<Output> isIPBlocked(List<Input> input) {
    // Convert the input IP address to a Long for comparison
    Output out = new Output();
    try {
      MessagingSession msgSession = [
        SELECT Visitor_IP_Address__c
        FROM MessagingSession
        WHERE Id = :input[0].routableId
      ];
      String ipAddress = msgSession.Visitor_IP_Address__c;
      if (String.isBlank(ipAddress)) {
        out.isCustomerBlocked = false;
        return new List<Output>{ out };
      }

      // Fetch Blocked Visitor records from custom metadata
      List<Block_Visitors__mdt> blockVisitorRecords = [
        SELECT From_IP_Address__c, To_IP_Address__c
        FROM Block_Visitors__mdt Where From_IP_Address__c = :ipAddress
      ];
      if(blockVisitorRecords.size() > 0) {
        out.isCustomerBlocked = true;
        return new List<Output>{ out };
      }

      // Loop through all metadata records
      
    } catch (Exception e) {
      logger.error('Error in isIPBlocked')
        .setExceptionDetails(e)
        .addTag('BotException');
      Logger.saveLog();
    }

    out.isCustomerBlocked = false; // IP is not in any blocked range
    return new List<Output>{ out };
  }
}