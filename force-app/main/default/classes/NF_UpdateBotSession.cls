/**
 * Created by mcasella on 9/21/20.
 */

public with sharing class NF_UpdateBotSession {
    public class Input {
        @InvocableVariable(required=false)
        public String chatKey;

        @InvocableVariable(required=false)
        public String field;

        @InvocableVariable(required=false)
        public String value;
    }

    @InvocableMethod(label = 'NeuraFlash - Update Bot Session')
    public static void setField(List<Input> params) {
        String chatKey = params[0].chatKey;
        String field = params[0].field;
        String value = params[0].value;

        try {
            ebotdata__Bot_Session__c[] sessions = [
                    SELECT Name, Id, ebotdata__Successful_Resolution__c
                    FROM ebotdata__Bot_Session__c
                    WHERE ebotdata__Live_Agent_Session_Id__c = :chatKey
                    LIMIT 1
            ];

            if(sessions.size() > 0){
                sessions[0].put(field, value);

                update sessions[0];
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG,'>> NF_SetResolutionStatus: ERROR AT LINE ' + e.getLineNumber());
            System.debug(LoggingLevel.DEBUG,'>> ERROR: ' + e.getMessage());
            System.debug(LoggingLevel.DEBUG,'>> ERROR: ' + e.getStackTraceString());
        }

    }
}