public with sharing class VSCCS_UpdateMessagingInsights {
  public class Input {
    @InvocableVariable(required=false)
    public String routableId;

    @InvocableVariable(required=false)
    public String field;

    @InvocableVariable(required=false)
    public String value;
  }
  @InvocableMethod(label='VS - Update Messaging Insights')
  public static void setField(List<Input> params) {
    String routableId = params[0].routableId;
    String field = params[0].field;
    String value = params[0].value;

    try {
      Messaging_Insight__c[] insights = [
        SELECT Name, Id, Successful_Resolution__c, Session_Escalation__c
        FROM Messaging_Insight__c
        WHERE Messaging_Session__c = :routableId
        LIMIT 1
      ];

      if (insights.size() > 0) {
        insights[0].put(field, value);

        update insights[0];
      }
    } catch (Exception e) {
      Logger.error('Error updating Messaging Insights ' + e.getMessage());
      Logger.saveLog();
    }
  }
}