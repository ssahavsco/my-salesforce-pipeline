/****************************************************************************************************************
* Program Name         : LoggerUtility
* Description          : Log Utility class used to insert exception records whenever there is an error in some class and function
*                        or API Logs as per the requirements.
* Version              : 1.2
* Modification Log     : 18 May, 2021 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId           Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          Utility Class      1.1       Divyanshu Kumar       05/18/2021      Log Utility class used to insert exception records whenever 
*                                                                                     there is an error in some class and function
*                                                                                      or API Logs as per the requirements.
*
*   PW_01          Utility Class      1.2       Peter Waddington      09/16/2021      Add "Process Log" function to track job lifecycle
*                                                                                                                                                                                       
*****************************************************************************************************************/
public class LoggerUtility {
    /*
    @Author : Divyanshu Kumar
    @Company : Neuraflash
    @Description : Insert Exception Log Records.
    */
    public static void insertLog(String sourceClass,String sourceFunction,Object o){
        try {
            Logger__c logRec = new Logger__c();
            if (o instanceof Exception) {
                Exception ex = (Exception) o;
                if(ex !=null){ 
                    logRec.Strack_Trace__c = ex.getStackTraceString();
                    logRec.Log_Type__c = 'Exception Log';
                    logRec.Message__c = ex.getMessage();
                }
            }
            else{
                Logger apiLog = (Logger) o;
                logRec.Log_Type__c = 'API Log';
                logRec.API_Request__c = apiLog.request;
                logRec.API_Response__c = apiLog.response;
            } 
            logRec.Class_Name__c = sourceClass != null ? sourceClass : null;
            logRec.Source_Method__c = sourceFunction != null ? sourceFunction : null;       
            insert logRec;
        }
        catch(Exception e){
            System.debug('Failed to insert LOG to Logger__c'
            + ' Error Message = ' + e.getMessage()
            + ' Error Stack Trace = ' + e.getStackTraceString());
        }
    }

    public static void insertProcessLog(String className, String sourceMethod, String message) {
        try {
            Logger__c logRec = new Logger__c();
            logRec.Log_Type__c = 'Process Log';
            logRec.Class_Name__c = className;
            logRec.Source_Method__c = sourceMethod;
            logRec.Message__c = message;
            insert logRec;
        }
        catch(Exception e){
            System.debug('Failed to insert Process Log to Logger__c'
            + ' Error Message = ' + e.getMessage()
            + ' Error Stack Trace = ' + e.getStackTraceString());
        }
    }

    public class Logger{
        String response;
        String request;
        public Logger(String request,String response){
            this.request = request;
            this.response = response;
        }
    }
}