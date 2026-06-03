/**
 * VSCCS_QuizResultHandler
 * Purpose: Apex handler to persist quiz results from trainingConfiguration LWC.
 * History:
 * -------
 * VERSION  AUTHOR                 DATE                 DETAIL                      TICKET REFERENCE/ NO.
 * 1.       Himanshu Mishra        12/31/2025           Original Version      		 CCS-1009
 * @Testsuite:  {VSCCS_QuizResultHandlerTest}      
 */
public with sharing class VSCCS_QuizResultHandler {

    @AuraEnabled
    public static Boolean saveQuizResults(List<Test_Your_Knowledge_Results__c> answers) {
        if (answers == null || answers.isEmpty()) {
            return false;
        }

        try {
            Database.SaveResult[] results = Database.insert(answers, false, AccessLevel.USER_MODE);
            Integer successCount = 0;
            List<String> errors = new List<String>();
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                } else {
                    for (Database.Error e : results[i].getErrors()) {
                        errors.add('Row ' + i + ': ' + e.getMessage());
                    }
                }
            }
            if (!errors.isEmpty()) {
                try {
                    Logger.error('VSCCS_QuizResultHandler SObject DML partial failure | SuccessCount=' + successCount + ' | Errors=' + String.join(errors, ' || '))
                        .addTag('TrainingConfiguration');
                    Logger.saveLog();
                } catch (Exception logEx) {}
                return false;
            }
            return true;
        } catch (Exception ex) {
            Logger.error('VSCCS_QuizResultHandler SObject unexpected error: ')
                .setExceptionDetails(ex)
                .addTag('TrainingConfiguration');
            Logger.saveLog();
            return false;
        }
    }
}