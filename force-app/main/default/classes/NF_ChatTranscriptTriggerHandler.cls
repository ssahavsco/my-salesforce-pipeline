/*****************************************************************************************************@@
 Class Name     :  NF_ChatTranscriptTriggerHandler
 Purpose        :  Handler class for live chat transcript trigger
 History:
 -------
 VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
 1.         Manishi                  5/6/2021            Added trigger bypass         DP-41198
 @Testsuite:  {NF_ConsoleEventsHandlerControllerTest}
 *********************************************************************************************************/
public class NF_ChatTranscriptTriggerHandler extends NF_TriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean triggerDisabled = false;
    /*Checks to see if the trigger has been disabled either by custom setting or by running code*/
    public override Boolean isDisabled(){
        return triggerDisabled;
    }

    public override void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){

        NF_ReassignBotCase.reassignCases((Map<Id, LiveChatTranscript>)newItems);

        NF_ReassignBotCase.updateAccountOnTranscript((List<LiveChatTranscript>)newItems.values());

        //added by Rishabh for DP-50178
        Map<Id, LiveChatTranscript> chatMap = (Map<Id, LiveChatTranscript>)newItems;
        String chatString = JSON.serialize(chatMap.values());
        if(System.IsBatch() == false && System.isFuture() == false){
        	NF_UpdateCaseClass.updateChatCreatedDate(chatString,chatMap.keySet());
        }
        //added by Rishabh for DP-53772
        //NF_UpdateCaseClass.updateContactAndAccount(chatString);
        //added by Ram for DP-56938
        
        //NF_UpdateCaseClass.updateDirectAgentHandleTime(chatMap.keySet());
    }

    //added by Rishabh for DP-50178
    public override void afterInsert(Map<Id, SObject> newItems){
        Map<Id, LiveChatTranscript> chatMap = (Map<Id, LiveChatTranscript>)newItems;
        String chatString = JSON.serialize(chatMap.values());
        NF_UpdateCaseClass.updateChatCreatedDate(chatString,chatMap.keySet());
        
        //NF_UpdateCaseClass.updateContactAndAccount(chatString);
        
        //NF_UpdateCaseClass.updateDirectAgentHandleTime(chatMap.keySet());
    }

    //added by Rishabh for DP-50178
    public override void afterDelete(Map<Id, SObject> oldItems){
        //String chatString = JSON.serialize(oldItems);
        //NF_UpdateCaseClass.updateChatCreatedDate((Map<Id, LiveChatTranscript>)oldItems);
    }

}