/**************************************************************************************************************************
* Program Name         : VS_GenericDataDeletionBatchScheduler
* Description          : Schedular class for VS_GenericDataDeletionBatch.
* Version              : 1.0
* Modification Log     : 30 April, 2024
*--------------------------------------------------------------------------------------------------------------------------
*  JiraId        Version    Developer               Date           Description 
*--------------------------------------------------------------------------------------------------------------------------
*  CCS-312       1.0       Himanshu Mishra      04/30/2024     Schedular class for VS_GenericDataDeletionBatch.   
* 
***************************************************************************************************************************/
public class VS_GenericDataDeletionBatchScheduler implements Schedulable{
    public String objectName;
    public DateTime startDate, endDate;
    public Integer noOfDays;
	public VS_GenericDataDeletionBatchScheduler(String objectName) {
		this.objectName = objectName;
    }
    public VS_GenericDataDeletionBatchScheduler(String objectName, DateTime startDate, DateTime endDate) {
		this.objectName = objectName;
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    /*Added against CCS-418 by Rahul Sharma on 12-June-2024 *****START******/
    public VS_GenericDataDeletionBatchScheduler(String objectName, Integer noOfDays) {
		this.objectName = objectName;
        this.noOfDays = noOfDays;
    }
    /*Added against CCS-418 by Rahul Sharma on 12-June-2024 *****END******/
    
    public void execute(SchedulableContext sc){
        if(objectName != null && startDate != null && endDate != null){
        	VS_GenericDataDeletionBatch batch = new VS_GenericDataDeletionBatch(objectName, startDate, endDate);
            Database.executebatch(batch, 10000);
        }
         /*Added against CCS-418 by Rahul Sharma on 12-June-2024 *****START******/
        else if(objectName != null && noOfDays != null){
            VS_GenericDataDeletionBatch batch = new VS_GenericDataDeletionBatch(objectName, noOfDays);
            Database.executebatch(batch, 10000);
        }
        /*Added against CCS-418 by Rahul Sharma on 12-June-2024 *****END******/
        else if(objectName != null) {
            VS_GenericDataDeletionBatch batch = new VS_GenericDataDeletionBatch(objectName);
            Database.executebatch(batch, 10000);
        }
    }
}