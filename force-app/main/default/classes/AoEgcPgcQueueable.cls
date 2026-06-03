/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Queueable class for ECG/PCG Service Request.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Waddington  <peter.waddington@neuraflash.com>
* @modifiedBy     Peter Waddington  <peter.waddington@neuraflash.com>
* @maintainedBy   Peter Waddington  <peter.waddington@neuraflash.com>
* @version        1.0
* @created        2021-04-30
* @modified       2021-04-30
* @systemLayer    Controller
* @Jira Number    DP-37135, DP-37137
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Peter Waddington <peter.waddington@neuraflash.com>
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class AoEgcPgcQueueable implements Queueable {
    private List<Id> giftCardRequestIds;
    public AoEgcPgcQueueable(List<Id> giftCardRequestIds) {
        this.giftCardRequestIds = giftCardRequestIds;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * future method which makes a callout and updates GIFT_CARD_REQUEST__C.MESSAGE_ID__C field
    * When called from Flows the param will be a single string with the Id, however Standard SFDC
    * functionality expects the params for an Invokable to be a List which returns a List.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    gcrIdList           List<Id>
    * @return   List<String>
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @InvocableMethod(label='Request ECG PCG Queueable' description='Submit ECG/PCG request in a Queueable context') 
    public static List<String> sendEcgPcgReq(List<Id> gcrIdList) {
        List<String> invokeReturnList = new List<String>{'sent'};
        AoEgcPgcQueueable getGCRApprovalJob = new AoEgcPgcQueueable(gcrIdList);
        ID jobID = System.enqueueJob(getGCRApprovalJob);
        return invokeReturnList;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * execute function for a Queueable class instance, managed by the Salesforce runtime
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    QueueableContext context
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void execute(QueueableContext context) {
        for (Id gcrId:giftCardRequestIds) {
            AoEgcPgcService.sendEcgPcgReq(gcrId);
        }
    }
}