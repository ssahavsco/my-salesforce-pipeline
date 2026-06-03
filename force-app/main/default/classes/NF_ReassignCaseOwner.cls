//used for Bot Cases
public with sharing class NF_ReassignCaseOwner {
    public static boolean reassignCaseOwner(Map<Id, LiveChatTranscript> liveChatTranscripts){
        if(liveChatTranscripts == null || liveChatTranscripts.size() == 0){
            return false;
        }

        User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();
        try{
            List<Case> cases = new List<Case>();
            for (Id chatTranscriptId : liveChatTranscripts.keySet()) {
                System.debug(LoggingLevel.DEBUG,'chatTranscriptId>>>' + chatTranscriptId);
                LiveChatTranscript transcript = liveChatTranscripts.get(chatTranscriptId);

                if (transcript.CreatedById != transcript.OwnerId) {
                    Id createdById = transcript.CreatedById;
                    System.debug(LoggingLevel.DEBUG,'createdById>>>' + createdById);
                    
                    if (createdById == platformIntegrationUser.Id) {
                        addCase(cases, transcript);
                    }
                }
            }
            if (cases.size() > 0) {
                update cases;
                return true;
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG,'Exception occured>>>>'+e.getStackTraceString());
        }

        return false;
    }

    @TestVisible
    private static void addCase(List<Case> cases, LiveChatTranscript transcript){
        if(cases == null || transcript == null)
            return;

        try {
            Case c = new Case();
            c.Id = transcript.caseId;
            c.OwnerId = transcript.ownerId;
            cases.add(c);

            cases.add(c);
        }
        catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'NF_ReassignCaseOwner.addCase: '+e.getMessage());
        }
    }
}