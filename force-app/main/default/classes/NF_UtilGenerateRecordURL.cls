public with sharing class NF_UtilGenerateRecordURL {
    // This invokable function returns the string representation of a record's URL ; this is Invocable because we call it from Flows.
    // Params (RecordURLParams)
    // recordId = 15 or 18 character representation of the record Id, often passed in the flow as (object entity).Id
    // Returns (RecordURLResult)
    // url = String representation of the URL to access the record directly in SFDC
    public class RecordURLParams{
        @InvocableVariable(Required=true)
        public String recordId;
    }

    public class RecordURLResult{
        @InvocableVariable(Required=true)
        public string url;
    }

    @InvocableMethod(label='Generate Record URL' description='Generates a URL which can be used to navigate directly to a record')
    public static List<RecordURLResult> generateRecordURL(List<RecordURLParams> recParams) {
        List<RecordURLResult> resultSet = new List<RecordURLResult>();
        for (RecordURLParams params:recParams) {
            RecordURLResult result = new RecordURLResult();
            result.url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + params.recordId;
            resultSet.add(result);
        }
        return resultSet;
    }
}