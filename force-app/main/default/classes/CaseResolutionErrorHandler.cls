/******************************************************************************
 * Version		Jira			Modified by			Description 
 * 
 * 1.0			CCS-302			Himanshu Mishra		Created class to truncate the unwanted error messages
 * ***************************************************************************/
public class CaseResolutionErrorHandler {

    @InvocableMethod(label='Truncate Error' description='Truncate input error message and return only specific error details')
    public static List<OutputError> getErrorMessage(List<InputError> input){
        List<OutputError> outputList = new List<OutputError>();
        try{
            String inputErrorMessage = input[0].errorDetails;
            String truncatedErrorMessage = inputErrorMessage.split('EXCEPTION:')[1].split(' You')[0];
            System.debug('EM '+truncatedErrorMessage);
            
            OutputError out = new OutputError();
            out.errorMessage = truncatedErrorMessage;
            outputList.add(out);
        } catch(Exception e){
            OutputError out = new OutputError();
            out.errorMessage = 'Some error occurred while creating Case Resolution. Please try again..';
            outputList.add(out);
        }
        return outputList;
    }
    
    public Class InputError{
        @InvocableVariable
        Public String errorDetails;
    }
    
    public Class OutputError{
        @InvocableVariable
        Public String errorMessage;
    }
}