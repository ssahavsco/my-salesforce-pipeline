@isTest
public class CaseResolutionErrorHandlerTest {
	
    public static testMethod void successMethod(){
        Test.startTest();
        List<CaseResolutionErrorHandler.InputError> inputList =  new List<CaseResolutionErrorHandler.InputError>();
        CaseResolutionErrorHandler.InputError input = new CaseResolutionErrorHandler.InputError();
        input.errorDetails = 'Error Occurred: The flow tried to update these records: 500U800000447VFIAY. This error occurred: FIELD_CUSTOM_VALIDATION_EXCEPTION: Escalation Type & Team must be added before it can be closed.. You can look up ExceptionCode values in the https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_calls_concepts_core_data_objects.htm#';
        inputList.add(input);
        
        List<CaseResolutionErrorHandler.OutputError> output = CaseResolutionErrorHandler.getErrorMessage(inputList);
        System.debug('OP '+output[0].errorMessage);
        System.assertEquals(' Escalation Type & Team must be added before it can be closed..' , String.valueOf(output[0].errorMessage));
        Test.stopTest();
    }
    
    public static testMethod void failureMethod(){
        Test.startTest();
        List<CaseResolutionErrorHandler.InputError> inputList =  new List<CaseResolutionErrorHandler.InputError>();
        CaseResolutionErrorHandler.InputError input = new CaseResolutionErrorHandler.InputError();
        input.errorDetails = '';
        inputList.add(input);
        
        List<CaseResolutionErrorHandler.OutputError> output = CaseResolutionErrorHandler.getErrorMessage(inputList);
        System.debug('OP '+output[0].errorMessage);
        System.assertEquals('Some error occurred while creating Case Resolution. Please try again..' , String.valueOf(output[0].errorMessage));
        Test.stopTest();
    }
}