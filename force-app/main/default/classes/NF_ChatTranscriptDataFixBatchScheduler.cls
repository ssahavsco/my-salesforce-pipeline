/****************************************************************************************************************
* Program Name         : NF_ChatTranscriptDataFixBatchScheduler
* Description          : Schedulable class to schedule batch NF_ChatTranscriptDataFixBatch
* Version              : 1.1
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   _          		DP-51067      1.1       Manishi      23 Dec,2021       Schedulable class to schedule batch NF_ChatTranscriptDataFixBatch
*     
*****************************************************************************************************************/
global class NF_ChatTranscriptDataFixBatchScheduler implements Schedulable {
    public Integer numHrs;
    global NF_ChatTranscriptDataFixBatchScheduler() {
        numHrs = 1;
    }
    global NF_ChatTranscriptDataFixBatchScheduler(Integer numberOfHoursBefore) {
		numHrs = numberOfHoursBefore;      
    }
    global void execute(SchedulableContext sc){
        NF_ChatTranscriptDataFixBatch batch = new NF_ChatTranscriptDataFixBatch(numHrs); 
        Database.executebatch(batch, 50);
    }
}