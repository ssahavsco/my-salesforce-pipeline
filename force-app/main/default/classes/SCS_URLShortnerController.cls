/****************************************************************************************************************
* Program Name         : SCS_URLShortnerController
* Description          : Controller class for scs_UrlShortner LWC
* Version              : 1.2
* Modification Log     : 22 April,2021.
* Modification Log     : 05 May,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-39681      1.1    Chayan Batabyal    22 April,2021    Used by scs_UrlShortner LWC to generate bit links by looking
                                                                            into metadata for API Callout configurations.
                                                                            Also used by the flow to generate bitlink during survey from case.

*   CB_02          DP-40793      1.2    Chayan Batabyal    05 May,2021      Maintains a count of how much of the selected plan we've already utilized.
                                                                            Resets the counter to 0 every start of the month through sheduled apex.
*****************************************************************************************************************/
public with sharing class SCS_URLShortnerController implements Schedulable{
    public static Integer totalLimit = 1000;
    public static Integer usedCount = 0;

    /**
    * @description Reset the used counter to 0 at the start of every month
    * @author cbatabyal@contractor.lb.com | 05-01-2021
    * @param SC
    **/
    public void execute(SchedulableContext SC) {
        updateSupportTimeThreshold(null);
    }

    @InvocableMethod(
        label='Shorten URL' callout=true
        description='Generates a shortened URL from a long URL'
    )
    public static List<FlowResponseWrapper> generateShortURL(
        List<FlowRequestWrapper> flowInputs
    ){
        List<FlowResponseWrapper> returnWrap = new List<FlowResponseWrapper>();
        FlowResponseWrapper singleWrap = new FlowResponseWrapper();
        ResponseWrapper responseWrapper = generateShortURL(
            flowInputs[0].urlToShorten,
            flowInputs[0].recordId,
            flowInputs[0].fieldAPIName
        );

        Map<String, Object> calloutResponse =
            (Map<String, Object>) responseWrapper.response;
        if(calloutResponse != null  && !calloutResponse.keySet().isEmpty()){
            if(
                calloutResponse.containsKey('link') &&
                calloutResponse.get('link') != null &&
                String.isNotBlank((String)calloutResponse.get('link'))
            ){
                singleWrap.shortURL = (String)calloutResponse.get('link');
                singleWrap.isSuccess = true;
            }
            else if(
                calloutResponse.containsKey('description') &&
                calloutResponse.get('description') != null &&
                String.isNotBlank((String)calloutResponse.get('description'))
            ){
                singleWrap.message = (String)calloutResponse.get('description');
                singleWrap.isSuccess = false;
            }
        }

        returnWrap.add(singleWrap);
        return returnWrap;
    }

    /**
    * @description Calls out the Bit.ly url shortening API and returns the response
    * after checking the available limit according to the current plan
    * @author cbatabyal@contractor.lb.com | 04-22-2021
    * @param longURL
    * @param recordId
    * @param fieldAPIName
    * @return ResponseWrapper
    **/
    @AuraEnabled
    public static ResponseWrapper generateShortURL(
        String longURL, String recordId, String fieldAPIName
    ){
        ResponseWrapper objWrap = new ResponseWrapper();

        if(String.isBlank(longURL)){
            return null;
        }
        try{
            String configName = 'Pink';
            if(String.isNotBlank(recordId) && String.isNotBlank(fieldAPIName)){
                String decider = String.valueOf(Database.query(
                    'SELECT FIELD_API_NAME FROM OBJECT_NAME WHERE Id =: recordId'.replace(
                        'OBJECT_NAME',
                        Id.valueOf(recordId).getSObjectType().getDescribe().getName()
                    ).replace('FIELD_API_NAME', fieldAPIName)
                )[0].get(fieldAPIName));

                //configName =
                   // String.isNotBlank(decider) && decider.equalsIgnoreCase('pink') ?
                   // 'Pink' : 'VS';
            }

            HTTPResponse resp = doCallOut(
                configName, new Map<String, String>{'LONGURL' => longURL}
            );

            objWrap.response = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
                objWrap.isSuccess = true;
                updateSupportTimeThreshold(configName);
            }
        }
        catch(Exception e){
            objWrap.isSuccess = false;
            objWrap.message = e.getMessage();
            Logger.error(e.getMessage());
            Logger.saveLog();
        }

        return objWrap;
    }

    /**
    * @description Used for API Callout
    * @author cbatabyal@contractor.lb.com | 05-01-2021
    * @param configName
    * @param bodyReplacements
    * @return HTTPResponse
    **/
    @TestVisible
    private static HTTPResponse doCallOut(
        String configName, Map<String, String> bodyReplacements
    ){
        SCS_Bitly_API_Configuration__mdt config = [
            SELECT Endpoint_URL__c, Callout_Type__c,
                Callout_Header__c, Callout_Body__c
            FROM SCS_Bitly_API_Configuration__mdt
            WHERE DeveloperName =: configName
            LIMIT 1
        ];

        HttpRequest calloutRequest = new HttpRequest();
        calloutRequest.setMethod(config.Callout_Type__c);
        calloutRequest.setEndpoint(config.Endpoint_URL__c);

        if(String.isNotBlank(config.Callout_Body__c)){
            String body = config.Callout_Body__c;

            if(bodyReplacements != null && !bodyReplacements.keySet().isEmpty()){
                for(String eachKey : bodyReplacements.keySet()){
                    body = body.replaceAll(eachKey, bodyReplacements.get(eachKey));
                }
            }

            calloutRequest.setBody(body);
        }

        if(String.isNotBlank(config.Callout_Header__c)){
            for(String eachHeader : config.Callout_Header__c.split(';')){
                calloutRequest.setHeader(
                    eachHeader.split(':')[0], eachHeader.split(':')[1]
                );
            }
        }

        return new Http().send(calloutRequest);
    }

    /**
    * @description Checks for the available limit according to the current plan
    * @author cbatabyal@contractor.lb.com | 05-01-2021
    * @param configName
    **/
    @TestVisible
    private static void getBitlyPlanLimit(String configName){
        Boolean planFound = false;
        HTTPResponse resp = doCallOut(configName, null);

        if(resp.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>)
                JSON.deserializeUntyped(resp.getBody());
            if(
                responseMap.containsKey('plan_limits') &&
                responseMap.get('plan_limits') != null &&
                !((List<Object>)responseMap.get('plan_limits')).isEmpty()
            ){
                for(Object eachObject : (List<Object>)responseMap.get('plan_limits')){
                    Map<String, Object> limitMap = (Map<String, Object>)eachObject;
                    if(limitMap != null && !limitMap.keySet().isEmpty()){
                        for(String eachAttribute : limitMap.keySet()){
                            if(
                                eachAttribute == 'name' &&
                                String.valueOf(limitMap.get('name')) == 'encodes' &&
                                limitMap.containsKey('limit') &&
                                String.isNotBlank(String.valueOf(limitMap.get('limit'))) &&
                                limitMap.containsKey('count') &&
                                String.isNotBlank(String.valueOf(limitMap.get('count')))
                            ){
                                totalLimit = Integer.valueOf(limitMap.get('limit'));
                                usedCount = Integer.valueOf(limitMap.get('count'));
                                planFound = true;
                                break;
                            }
                        }
                    }
                    if(planFound){
                        break;
                    }
                }
            }
        }
    }

    /**
    * @description Updates the counters of support time threshold records
    * @author cbatabyal@contractor.lb.com | 05-01-2021
    * @param configName
    **/
    @TestVisible @Future(callout = true)
    private static void updateSupportTimeThreshold(String configName){
        if(String.isNotBlank(configName)){
            getBitlyPlanLimit(configName + 'PlanLimit');
        }
        List<Support_Time_Threshold__c> thresholds = [
            SELECT Id, Number_of_Shortened_URLs_Pink__c,
                Number_of_Shortened_URLs_VS__c
            FROM Support_Time_Threshold__c
        ];
        if(thresholds != null && !thresholds.isEmpty()){
            for(Support_Time_Threshold__c eachThreshold : thresholds){
                if(String.isBlank(configName)){
                    eachThreshold.Number_of_Shortened_URLs_Pink__c = 0;
                    eachThreshold.Number_of_Shortened_URLs_VS__c = 0;
                }
                else if(configName.equalsIgnoreCase('pink')){
                    eachThreshold.Number_of_Shortened_URLs_Pink__c = usedCount;
                }
                else{
                    eachThreshold.Number_of_Shortened_URLs_VS__c = usedCount;
                }
            }

            update thresholds;
        }
    }

    public class ResponseWrapper{
        @AuraEnabled
        public Boolean isSuccess = false;

        @AuraEnabled
        public Object response;

        @AuraEnabled
        public String message;
    }

    public class FlowResponseWrapper{
        @InvocableVariable(label = 'Shortened URL')
        public String shortURL;

        @InvocableVariable(label = 'Message, If any')
        public String message = 'Test';

        @InvocableVariable(label = 'Was Callout Successful')
        public Boolean isSuccess = false;
    }

    public class FlowRequestWrapper{
        @InvocableVariable(label = 'URL to shorten')
        public String urlToShorten;

        @InvocableVariable(label = 'Record Id, If any')
        public String recordId;

        @InvocableVariable(label = 'Field\'s API Name to get the brand name')
        public String fieldAPIName;
    }
}