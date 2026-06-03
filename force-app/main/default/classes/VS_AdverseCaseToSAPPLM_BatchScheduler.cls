/**************************************************************************************************************************
* Program Name         : VS_AdverseCaseToSAPPLM_BatchScheduler
* Description          : Schedular class for VS_AdverseCaseToSAPPLM_Batch.
* Version              : 1.0
* Modification Log     : 24 September, 2024
*--------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*--------------------------------------------------------------------------------------------------------------------------
*  CCS-644       1.0       Himanshu Mishra      09/24/2024     Schedular class for VS_AdverseCaseToSAPPLM_Batch.   
* 
***************************************************************************************************************************/
public class VS_AdverseCaseToSAPPLM_BatchScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc){ 
        VS_AdverseCaseToSAPPLM_Batch batch = new VS_AdverseCaseToSAPPLM_Batch();
        Database.executebatch(batch, 10000);
    }
}