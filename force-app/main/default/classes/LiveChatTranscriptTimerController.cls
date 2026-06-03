/*****************************************************************************************************@@
Class Name     :  LiveChatTranscriptTimerController
Purpose        :  helper class used to get the case field set for the VOC coding component placed on Case layout.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Pooja                01/09/2023           Original Version  			DP-50419

@Testsuite:  {LiveChatTranscriptTimerController_Test}                                       
*********************************************************************************************************/
public class LiveChatTranscriptTimerController {
    
    @AuraEnabled
    public static LiveChatTranscriptTimerController.wrapperObj getCaseInfo(string recordId){
        List<case> casRec = new List<case>();
        LiveChatTranscript transcript = new LiveChatTranscript();
         
        transcript = [select id,caseID,Custom_Chat_End_Time__c,EndTime,OwnerId,Is_Wrap_Up_Alert_Displayed__c  from LiveChatTranscript where id=:recordId];
                        


        casRec=[select id,status,Contact.Name,caseNumber,OwnerId,createdDate  from case where id=:transcript.caseID];
        LiveChatTranscriptTimerController.wrapperObj wrpObj = new LiveChatTranscriptTimerController.wrapperObj();    
        VS_Chat_Settings__c settings = VS_Chat_Settings__c.getValues('VSChat');
        string alertMessage = '';
                    System.debug( ' settings.Chat_Wrap_Up_Alert__c'+  System.today() );

        if((!casRec.isEmpty() && casRec[0].status != 'Closed') && transcript.Custom_Chat_End_Time__c != null && casRec[0].createdDate.date() == System.today()){     
            wrpObj.alertTimeSeconds = settings.Chat_Wrap_Up_Alert_Seconds__c *1000;
            System.debug( ' settings.Chat_Wrap_Up_Alert__c'+settings.Chat_Wrap_Up_Alert__c);
            System.debug( ' settings.Chat_Wrap_Up_Alert__c'+ casRec[0].createdDate );
            System.debug( ' settings.Chat_Wrap_Up_Alert__c'+ casRec[0].createdDate.date() );
            System.debug( ' settings.Chat_Wrap_Up_Alert__c'+  System.today() );
            System.debug( ' settings.Chat_Wrap_Up_Alert__c'+ (UserInfo.getUserId() == casRec[0].OwnerId ));
            
            alertMessage = settings.Chat_Wrap_Up_Alert_Message__c.replace('CustomerName', casRec[0].Contact.Name); 
            alertMessage = alertMessage.replace('CaseNumber', casRec[0].caseNumber);
            wrpObj.alertMessage = alertMessage; 
                        System.debug( ' transcript.ownerId'+  transcript.ownerId );
                        System.debug( ' casRec[0].OwnerId'+  casRec[0].OwnerId );
            if(transcript.ownerId == casRec[0].OwnerId  && UserInfo.getUserId() == casRec[0].OwnerId && settings.Chat_Wrap_Up_Alert__c  && transcript.Is_Wrap_Up_Alert_Displayed__c == False  &&  transcript.EndTime == NULL){
                 wrpObj.alertEnabled = true;
             } 
            
           
            //'Alert: Your chat with CustomerName has been in wrap up for more than 1 minute. Please reach out to a leader if you need support.';
        }

        System.debug( ' wrpObj'+ wrpObj);

        return wrpObj;
    } 

    Public class wrapperObj{
        
        @AuraEnabled
        public  Boolean alertEnabled = false;
        @AuraEnabled
        public  Decimal alertTimeSeconds;
        @AuraEnabled
        public  String alertMessage;
    } 
}