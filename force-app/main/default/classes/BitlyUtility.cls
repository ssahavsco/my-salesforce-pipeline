/***************************************************************
*Class Name 			: BitlyUtility
*CreatedDate 			: 24-Feb-2022
*Description 			: Bitly utility Class for URL Shortner
*Created By 			: Poojitha Korrapati
*Version              	: 1.1
*Modification Log     	:  
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   PK_01          DP-53595       1.1       Poojitha Korrapati      02/24/2022      PayByLink: Create URL shortner utility Class (Version 1)
*                                                                                                                                                                                       
*****************************************************************************************************************/

public with sharing class BitlyUtility {
   
    public static Integer totalLimit = 1000;
    public static Integer usedCount = 0;
      
    @InvocableMethod(
        label='PayByLink Shorten URL' callout=true
        description='Generates a shortened URL from a long URL'
    )
    public static List<FlowResponseWrapper> bitlyUrlShortner( List<FlowRequestWrapper> flowInputs ){
        system.debug(flowInputs);
        List<FlowResponseWrapper> returnWrap = new List<FlowResponseWrapper>();
        FlowResponseWrapper singleWrap = new FlowResponseWrapper();
        ResponseWrapper responseWrapper = bitlyUrlShortner(
            flowInputs[0].caseNumber,
            flowInputs[0].urlToShorten,
            flowInputs[0].sourceType
        );
        
        Map<String, Object> calloutResponse = (Map<String, Object>) responseWrapper.response;
        if(calloutResponse != null  && !calloutResponse.keySet().isEmpty()){
            if(
                calloutResponse.containsKey('link') &&
                calloutResponse.get('link') != null &&
                String.isNotBlank((String)calloutResponse.get('link'))
            ){
                singleWrap.shortURL = (String)calloutResponse.get('link');
                singleWrap.isSuccess = true;
            }
            else{
                singleWrap.shortURL =  flowInputs[0].urlToShorten;
                singleWrap.isSuccess = false;
            }
        }
        
        returnWrap.add(singleWrap);
        return returnWrap; 
    }
    
    
    /**
    * @description Calls out the Bit.ly url shortening API and returns the response
    * after checking the available limit according to the current plan
    * @author Poojitha Korrapati | 24-Feb-2022
    * @param longURL
    * @param caseNumber
    * @param sourceType
    * @return ResponseWrapper
    **/
    
    @AuraEnabled
    public static ResponseWrapper bitlyUrlShortner(
        String caseNumber, String longUrl, String sourceType){
            system.debug(caseNumber);
            system.debug(longUrl);
            system.debug(sourceType);

            ResponseWrapper objWrap = new ResponseWrapper();
            
            if(String.isBlank(longURL)){
                return null;
            }
            try{
                String configName = 'VS';
                HTTPResponse resp = doCallOut(
                    configName, new Map<String, String>{'LONGURL' => longURL}
                );
                Map<String, Object> responseMap = (Map<String, Object>)
                    JSON.deserializeUntyped(resp.getBody());
                objWrap.response = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                
                if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
                    objWrap.isSuccess = true;
                    updateSupportTimeThreshold('VS');
                }
                
                system.debug('caseNumber' +caseNumber);
                If(caseNumber != null && caseNumber != ''){
                    Case caseRecord = new Case();
                    //Get Case Number from LiveChatTranscript as From Chat UI the  input will be live chat transcript ID. 
                    If(sourceType == 'chatUI'){
                        LiveChatTranscript liveChat = new LiveChatTranscript();
                        liveChat = [SELECT id,Case.CaseNumber from LiveChatTranscript where id =: caseNumber];
                       If(liveChat.case.CaseNumber != null ){
                        caseNumber = liveChat.case.CaseNumber;
                       }
                    }
                 //Get Case record details to update the counter 
                    caseRecord = [Select Id,CaseNumber,Bitly_ChatUI_Count__c,Bitly_Payby_Link_Count__c from Case where caseNumber =:caseNumber];                   
                    system.debug('caseRecord' +caseRecord.Bitly_ChatUI_Count__c);
                    system.debug('caseRecord' +caseRecord.Bitly_Payby_Link_Count__c);

                    If(sourceType == 'payByLink'){
                        if(caseRecord.Bitly_Payby_Link_Count__c !=null){
                            caseRecord.Bitly_Payby_Link_Count__c += 1;
                            }
                            else{
                                caseRecord.Bitly_Payby_Link_Count__c =1;
                            }
                     }else If(sourceType == 'ChatUI'){
                         if(caseRecord.Bitly_ChatUI_Count__c !=null){
                            caseRecord.Bitly_ChatUI_Count__c += 1;
                            }
                            else{
                                caseRecord.Bitly_ChatUI_Count__c =1;
                            }
                     }
                    system.debug('caseRecord' +caseRecord);
                     
                    Update caseRecord;   
                }
            }
            catch(Exception e){
                system.debug('*** EXCEPTION ****'+ e.getMessage()+'*** LINE NUMBER ****'+e.getLineNumber());  
            }
            return objWrap;
        }
    
    /**
	* @description Used for API Callout
    * @author Poojitha Korrapati | 24-Feb-2022
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
    * @author Poojitha Korrapati | 24-Feb-2022
    * @param configName
    **/
    @TestVisible
    private static void getBitlyPlanLimit(String configName){
        Boolean planFound = false;
        HTTPResponse resp = doCallOut(configName, null);
        system.debug('resp'+resp.getBody());
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
    * @author Poojitha Korrapati | 24-Feb-2022
    * @param configName
    **/
    @TestVisible @Future(callout = true)
    public static void updateSupportTimeThreshold(String configName){
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

        @InvocableVariable(label = 'Case Number')
        public String caseNumber;

        @InvocableVariable(label = 'Source Type PayByLink /ChatUI')
        public String sourceType;
    }


  }