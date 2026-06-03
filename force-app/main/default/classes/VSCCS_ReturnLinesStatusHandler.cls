/***
 *  Sumit Saha | CCS-1591
 */

public with sharing class VSCCS_ReturnLinesStatusHandler {
  private static Boolean allLinesAreTrue = true;

  @InvocableMethod(
    label='Case Resolution Satus'
    description='marking CR status Complete'
  )
  public static void caseResolutionStatus(List<Input> input) {
    String resolutionId = String.isNotBlank(input[0].caseResolutionId)
      ? input[0].caseResolutionId
      : null;
    List<International_Return_Lines__c> returnLines = [
      SELECT Id, Name, Completed__c
      FROM International_Return_Lines__c
      WHERE Case_Resolution__c = :resolutionId
    ];

    for (International_Return_Lines__c e : returnLines) {
      if (e.Completed__c == false) {
        allLinesAreTrue = false;
        break;
      }
    }

    if (allLinesAreTrue && returnLines.size() > 0) {
      Case_Resolution__c cr = [
        SELECT Id, Name, Status__c, EC_Status__c, Completion_Date__c
        FROM Case_Resolution__c
        WHERE id = :input[0].caseResolutionId
        LIMIT 1
      ];
      cr.Completion_Date__c = Date.today();
      cr.EC_Status__c = 'Completed';
      update cr;
    }
  }

  public class Input {
    @InvocableVariable(required=false)
    public String caseResolutionId;
  }
}