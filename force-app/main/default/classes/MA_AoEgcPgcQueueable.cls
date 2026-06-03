public with sharing class MA_AoEgcPgcQueueable implements Queueable, Database.AllowsCallouts {

        private String batchNumber;

        public MA_AoEgcPgcQueueable(String batchNumber) {
            this.batchNumber = batchNumber;
        }

    public void execute(QueueableContext context) {
        Mass_Appeasement__c [] orders = [Select Id,  Name, CreatedDate, Message_Id__c, BatchID__c  from Mass_Appeasement__c where CreatedDate = today and BatchID__c =: batchNumber and Message_Id__c = null];
        for (Mass_Appeasement__c ord : orders) {
            System.debug(ord.Name);
             MA_AoEgcPgcService.sendEcgPcgReq(ord.Name);
        }
    }
}