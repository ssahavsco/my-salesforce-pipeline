public with sharing class VSCCS_SetQueueId {
    
    public class Input{

        @InvocableVariable
        public String routableId;

        @InvocableVariable
        public Boolean isInternational;

        @InvocableVariable
        public Boolean isUHVCustomer;

        @InvocableVariable
        public String userEmail;

        @InvocableVariable
        public String orderEmail;
    }

    @InvocableMethod(label='VS - Set Queue Id')
    public static void setQueueId(List<Input> input){
        
        String queueName = 'MIAW_Customer_Care_Chat';
        String userEmail = Label.TechTeamEmail;

        if(input[0].isInternational != null && input[0].isInternational){
            queueName = 'MIAW_International_Order_Help';
        } else if(input[0].isUHVCustomer != null && input[0].isUHVCustomer){
            queueName = 'MIAW_Customer_Care_Chat_High_Priority';
        } else if(userEmail.equalsIgnoreCase(input[0].userEmail) || userEmail.equalsIgnoreCase(input[0].orderEmail)){
            queueName = 'MIAW_Tech_Team';
        } 

        MessagingSession msgSession = [Select Id, Queue_Id__c
          From MessagingSession where Id = :input[0].routableId ];
        
        Group queuName = NF_Util.getQueue(queueName);
        if(queuName != null) {
            msgSession.Queue_Id__c = queuName.Id;
            update msgSession;
        } 
    }
}