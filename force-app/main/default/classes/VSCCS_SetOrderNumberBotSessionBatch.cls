/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VSCCS_SetOrderNumberBotSessionBatch
Created Date       : Oct 29, 2024
@description       : This Class will set the order number in bot session records
@author            : Himanshu Mishra <hmishra@victoria.com>
@story             : CCS-703
Modification Log:
Ver   Date         Author          Story/Defect#         Modification
1.0   Oct 29,2024  Himanshu Mishra   CCS-703             Initial Version
1.1	  Dec 19,2024  Himanshu Mishra   CCS-825             Added changes to run the job with last N mins
1.2   May 6, 2025  Himanshu Mishra   DP-91108            Added MIAW changes
1.3   Sep 25, 2025 Himashu Mishra    CCS-1157            Added Customer Type change
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class VSCCS_SetOrderNumberBotSessionBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
  // Start method: Query for Bot Sessions created today
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Integer last_N_Minutes = Integer.valueOf(System.Label.VSCCS_Last_N_Minutes);
    DateTime dt = System.Now().addMinutes(-last_N_Minutes); // /CCS-825
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          Order_Number__c,
          (SELECT Current_Utterance__c FROM Messaging_Bot_Chat_Logs__r)
        FROM Messaging_Insight__c
        WHERE CreatedDate > :dt
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<Messaging_Insight__c> botSessions
  ) {
    List<Messaging_Insight__c> sessionsToUpdate = new List<Messaging_Insight__c>();

    // Loop through each bot session and check related chat logs
    for (Messaging_Insight__c session : botSessions) {
      for (
        Messaging_Bot_Chat_Log__c chatLog : session.Messaging_Bot_Chat_Logs__r
      ) {
        // Check if the chat log Utterance matches the order number pattern
        if (
          String.IsNotBlank(chatLog.Current_Utterance__c) &&
          isValidOrderNumber(chatLog.Current_Utterance__c)
        ) {
          // Update the session's Order_Number__c field if a valid order number is found
          session.Order_Number__c = chatLog.Current_Utterance__c;
          //CCS-1157 - Start
          if(session.Order_Number__c.startsWith('G')){
            session.Customer_Type__c = 'INTL';
          }
          //CCS-1157 - End
          sessionsToUpdate.add(session);
          break; // Stop once a valid order number is found for this session
        }
      }
    }

    // Perform DML update if there are any sessions to update
    if (!sessionsToUpdate.isEmpty()) {
      Database.SaveResult[] results;
      try {
        results = Database.update(sessionsToUpdate, true);
      } catch (DmlException e) {
        logger.error(
            'Error updating bot session records: ' + e.getMessage(),
            results
          )
          .addTag('UpdateOrderNumberInBotSession');
        logger.saveLog();
      }
    }
  }

  // Finish method: Post-processing after batch execution
  public void finish(Database.BatchableContext bc) {
    System.debug('Batch job completed.');
  }

  // Helper method to check if a given input is a valid order number
  public static Boolean isValidOrderNumber(String orderNumber) {
    // Order number should be 10 characters long and start with an alphabet
    String orderNumberPattern = Label.VS_Order_Number_Pattern + '[0-9]{9}'; //VS_Order_Number_Pattern - ^[W|C|S|M|B|R|E|X|T|G|D]
    return Pattern.compile(orderNumberPattern).matcher(orderNumber).matches();
  }

  // Schedulable execute method to run the batch class
  public void execute(SchedulableContext sc) {
    Database.executeBatch(this, 200); // Running the batch with batch size of 100
  }
}