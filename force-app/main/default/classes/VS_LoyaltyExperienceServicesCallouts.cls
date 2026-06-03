/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Loyalty Experience Services callout class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sharath Vadla  <svadla@contractor.victoria.com>
* @version        1.0
* @created        08/10/2022
* @modified       02/19/2022
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* Modifiied by Sumit - 02/19/23 ~ DP-63906 
* Modifiied by Sumit - 03/10/23 ~ DP-65585
* Modified by Himanshu - 07/31/23 ~ CCS-75
* Modified by Himanshu - 07/09/24 ~ CCS-525
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class VS_LoyaltyExperienceServicesCallouts {
    private Static String accessToken;
    public final static String GET_METHOD = 'GET';
    public final static String POST_METHOD = 'POST';
    public final static String AUTH_HEADER_KEY = 'Authorization';
    public final static String CLASS_NAME = 'VS_LoyaltyExperienceServicesCallouts';
    public final static String LOYALTY_POINTS_HISTORY = 'Loyalty_Points_History';
    public final static String LOYALTY_POINTS_BALANCE = 'Loyalty_Points_Balance';
    public final static String LOYALTY_REWARDS = 'Loyalty_Rewards';
    public final static String LOYALTY_TRANSACTIONS = 'Loyalty_Transactions';
    public final static String LOYALTY_KOBIE_ID = 'Get_KobieID_By_Loyalty';
    public final static String LOYALTY_ADD_POINTS = 'Loyalty_Add_Points';
    public final static String LOYALTY_ENROLLMENT = 'Loyalty_Enrollment';
    public final static String GET_KOBIE_ID = 'getKobieUUID';
    public final static String KOBIE_ID_KEY = 'kobieUUID';
    public final static String LOYALTY_TRANSACTION_DETAILS = 'Loyalty_Transaction_Detail';
    public final static String LOYALTY_AUTHENTICATE_FUNCTION = 'authenticateLoyaltyExperience';
    public final static String GET_POINTS_HISTORY = 'getPointsHistory';
    public final static String GET_POINTS_BALANCE = 'getPointsBalance';
    public final static String GET_CUSTOMER_REWARDS = 'getCustomerRewards';
    public final static String GET_TRANSACTIONS = 'getTransactions';
    public final static String POST_APPEASMENT_POINTS = 'postAppeasementPoints';
    public final static String GET_TRANSACTION_DETAILS = 'getTransactionDetails';
    public final static String ADJUSTMENT_CODE = 'GOODWILL';
    public final static String BONUS_CODE = 'GOODWILL_VSPMTL';
    public final static String AUTH_SECRET_KEY = 'client_secret=';
    public final static String AUTH_ID_KEY = '&client_id=';
    public final static String GRANT_KEY = '&grant_type=';
    public final static String ACCESS_TOKEN = 'access_token';
    public final static String SOURCE_CODE = 'VSLOYALTY';
    public final static String BRAND = 'vs';
    public final static String DEFAULT_CUSTOMER_TYPE = 'I';
    public final static String SOURCE_LOCATION_CODE = '9000';
    public final static String SOURCE_CHANNEL_CODE = 'CCS';
    
    
    private static String authenticateLoyaltyExperience() {
        try {
            Loyalty_Experience_Authentication__c lytyExpAuth = Loyalty_Experience_Authentication__c.getOrgDefaults();
            system.debug(lytyExpAuth);
            HttpRequest request = new HttpRequest();
            String endpoint = lytyExpAuth.Base_Url__c +
                              AUTH_SECRET_KEY + lytyExpAuth.Client_Secret__c + 
                              AUTH_ID_KEY + lytyExpAuth.Client_Id__c +
                              GRANT_KEY + lytyExpAuth.Grant_Type__c;
            request.setEndpoint( endpoint );
            request.setMethod( POST_METHOD );
            request.setTimeout(lytyExpAuth.Time_out__c.intValue());
            HttpResponse response = new Http().send( request );
                if( response.getStatusCode() == 200 ){
                    Map<String, Object> authResponse = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody());
                    accessToken = ( String )authResponse.get( ACCESS_TOKEN );
                }else{
                    accessToken = '';
                    if(!Test.isRunningTest()){
                    Logger.error('Error while authenticating Experience service'+response.getBody());
                    Logger.saveLog();
                }
                }
                return accessToken;
        } catch (Exception ex) {
                Logger.error('Exception while authenticating Experience services'+ex.getMessage());
                Logger.saveLog();
        }
        return '';
    }
    @AuraEnabled(cacheable=true) 
    public static Map<String,Add_Points_Threshold__c> getAddPointsThresholdSettings(){
        return Add_Points_Threshold__c.getAll();
    }
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper getPointsHistory(String loyaltyId){
        return utilLoyaltyExperienceServiceCall(loyaltyId,LOYALTY_POINTS_HISTORY,GET_POINTS_HISTORY);
    }
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper getPointsBalance(String loyaltyId){
        return utilLoyaltyExperienceServiceCall(loyaltyId,LOYALTY_POINTS_BALANCE,GET_POINTS_BALANCE);
    }
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper getCustomerRewards(String loyaltyId){
        return utilLoyaltyExperienceServiceCall(loyaltyId,LOYALTY_REWARDS,GET_CUSTOMER_REWARDS);
    }
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper getTransactions(String loyaltyId){
        return utilLoyaltyExperienceServiceCall(loyaltyId,LOYALTY_TRANSACTIONS,GET_TRANSACTIONS);
    }
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper utilLoyaltyExperienceServiceCall(String loyaltyId,String serviceName, String methodName){
        try {
        Loyalty_Service_Setting__mdt lss_mdt = Loyalty_Service_Setting__mdt.getInstance(serviceName);
        String endPoint = lss_mdt.Base_Url__c + lss_mdt.Suffix_Url__c + loyaltyId;    
        Loyalty_Experience_Authentication__c lytyExpAuth = Loyalty_Experience_Authentication__c.getOrgDefaults();
        system.debug(lytyExpAuth);
        HttpRequest request = new HttpRequest();
        request.setEndpoint( endPoint );
        request.setMethod( GET_METHOD );
        system.debug(lytyExpAuth.Time_out__c.intValue());
        request.setTimeout(lytyExpAuth.Time_out__c.intValue());
        request.setHeader(AUTH_HEADER_KEY,lytyExpAuth.Token_Type__c+' '+ authenticateLoyaltyExperience());
        HttpResponse response = new Http().send( request );
        LoyaltyExperienceServiceResponseWrapper  respInstance = new LoyaltyExperienceServiceResponseWrapper();
            if( response.getStatusCode() == 200 ){
                respInstance.statusCode = response.getStatusCode();
                respInstance.response = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                return respInstance;
            }else{
                respInstance.statusCode = response.getStatusCode();
                Logger.error('Experience Service callout error'+response.getBody());
                Logger.saveLog();
                respInstance.response = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                return respInstance;
            }
        } catch (Exception ex) {
            Logger.error('Exception while calling Experience service'+String.valueOf(ex.getMessage()));
            Logger.saveLog();
            throw new AuraHandledException('Exception occured in' + methodName +ex.getMessage());
        }
    }
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper getTransactionDetails(String KobieTransId){
        try {
            Loyalty_Service_Setting__mdt lss_mdt = Loyalty_Service_Setting__mdt.getInstance(LOYALTY_TRANSACTION_DETAILS);
            String endpoint = lss_mdt.Base_Url__c + KobieTransId;
            HttpRequest request = new HttpRequest();
            request.setEndpoint( endpoint );
            request.setMethod( GET_METHOD );
            HttpResponse response = new Http().send( request );
            LoyaltyExperienceServiceResponseWrapper  respInstance = new LoyaltyExperienceServiceResponseWrapper();
            if( response.getStatusCode() == 200 ){
                respInstance.statusCode = response.getStatusCode();
                respInstance.response = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                system.debug('Response-'+respInstance);
                return respInstance;
            }else{
                respInstance.statusCode = response.getStatusCode();
                Logger.error('Error while calling getTransaction details service'+response.getBody());
                Logger.saveLog();
                return respInstance;
            }
        } catch (Exception ex) {
            Logger.error('Exception while calling getTransaction details service'+ex.getMessage());
            Logger.saveLog();
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public static String getKobieUUID(String loyaltyID){
        try {
        C_Grid_API_Config__mdt  getCustomerMetadata = C_Grid_API_Config__mdt.getInstance(LOYALTY_KOBIE_ID);
        String endpoint = getCustomerMetadata.Endpoint__c;
        String jsonBody = JSON.serialize(new LoyaltyCustomerRequestWrapper(loyaltyID));
        System.debug(endpoint);    
        System.debug(jsonBody);    

        HttpRequest request = new HttpRequest();
            request.setEndpoint( endpoint );
            request.setMethod( POST_METHOD );
            request.setBody(jsonBody);
            HttpResponse response = new Http().send( request );
            if( response.getStatusCode() == 200 ){
                Map<String, Object> kobieResp = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                if(!kobieResp.isEmpty() && kobieResp.size()>0 && kobieResp.containsKey(KOBIE_ID_KEY)){
                   system.debug('Kobie ID=>'+JSON.serialize(kobieResp.get(KOBIE_ID_KEY)));
                    String tempKobieID =  JSON.serialize(kobieResp.get(KOBIE_ID_KEY));
                    String kobieID = tempKobieID.replace('"','');
                    return kobieID;
                }else{
                    return '';
                }
            }else{
                if(!Test.isRunningTest()){
                Logger.error('Error while getting Kobie UUID from CGrid'+response.getBody());
                Logger.saveLog();
                }
                return '';
            }
        } catch (Exception ex) {
            if(!Test.isRunningTest()){
                Logger.error('Exception while getting Kobie UUID from CGrid'+ex.getMessage());
                Logger.saveLog();
            }
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    @future(callout = true)
    public static void postAppeasementPoints(String recordID, String loyaltyID, String loyaltyCustomerName, String sfAccountId, 
    String pointsReason, Integer pointsToAdd, String notesComments, String transactionNumber){
        try {   
        Loyalty_Service_Setting__mdt lss_mdt = Loyalty_Service_Setting__mdt.getInstance(LOYALTY_ADD_POINTS);
        String endpoint = lss_mdt.Base_Url__c + (String)getKobieUUID(loyaltyID) + lss_mdt.Suffix_Url__c ;
        String jsonBody = formAddPointsJSONPayload(pointsReason,pointsToAdd);
        HttpRequest request = new HttpRequest();
            request.setEndpoint( endpoint );
            request.setMethod( POST_METHOD );
            request.setBody(jsonBody);

            HttpResponse response = new Http().send( request );
            
            if( response.getStatusCode() == 200 ){
                Map<String, Object> pointsResponse = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                Case_Resolution__c crInst = new Case_Resolution__c();
                // crInst.Related_Case__c = recordID;
                crInst.Related_Case__c = recordID == null ? !String.isEmpty(sfAccountId) ? autoCase(sfAccountId) : autoCase() : recordID;
                crInst.Loyalty_ID__c = loyaltyID;
                crInst.Loyalty_Account_Name__c = !String.isBlank(sfAccountId)? [SELECT Name from Account where Id =: sfAccountId ][0].Name : loyaltyCustomerName;
                crInst.Points_Added__c = pointsToAdd;
                crInst.Case_Resolution_Type__c = pointsReason;
                crInst.Sub_Resolution_Code__c = '';
                crInst.Notes_Comments__c = notesComments;
                crInst.Transaction_Number__c = transactionNumber;
                crInst.Completion_Date__c = System.today();
                Insert crInst;
            }else{
                Logger.error('Error while adding points'+response.getBody());
                Logger.saveLog();
            }
        } catch (Exception ex) {
            Logger.error('Line Number :: ' + ex.getLineNumber() + ' Exception while adding points '+ex.getMessage()  );
            Logger.saveLog();
            throw new AuraHandledException(ex.getMessage());
        }   
    }
 
    
    /**
     * @description autoCase() method
     * @author Sumit Saha
     * @story DP-63906
     * @return   returns case#
     */
    public static String autoCase(){
        Case cs = new Case();
        try {
            cs.RecordTypeId = [Select Id from RecordType where DeveloperName = 'Digital_Phone' and SobjectType = 'Case' Limit 1].Id;
           // cs.AccountId = sfAccountId;
            cs.Origin = 'Phone'; 
            cs.Type = 'Rewards';
            cs.Sub_Type__c = 'Apply Purchase / Missing Points';
            cs.Status = 'Closed';
            cs.Auto_Closed__c = true;
            cs.VOC_Updates_Complete__c = true;
            cs.Is_Loyalty_Auto_Case__c = true;
            cs.Original_Department__c = 'Special Handling';
            cs.Final_Department__c = 'Special Handling';
            insert cs;
            return cs.Id;

        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    public static String autoCase(String sfAccountId){
        Case cs = new Case();
        try {
            cs.RecordTypeId = [Select Id from RecordType where DeveloperName = 'Digital_Phone' and SobjectType = 'Case' Limit 1].Id;
            cs.AccountId = sfAccountId;
            cs.Origin = 'Phone'; 
            cs.Type = 'Rewards';
            cs.Sub_Type__c = 'Apply Purchase / Missing Points';
            cs.Status = 'Closed';
            cs.Auto_Closed__c = true;
            cs.VOC_Updates_Complete__c = true;
            cs.Is_Loyalty_Auto_Case__c = true;
            cs.Original_Department__c = 'Special Handling';
            cs.Final_Department__c = 'Special Handling';
            insert cs;
            return cs.Id;

        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }


    public static String formAddPointsJSONPayload(String pointsReason,Integer pointsToAdd){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
            gen.writeFieldName('payload');
             gen.writeStartObject();     
             gen.writeFieldName('goodWill');
                gen.writeStartObject();
                gen.writeStringField('adjustmentCode', ADJUSTMENT_CODE);
                gen.writeStringField('adjustmentReason', pointsReason);
                gen.writeStringField('bonusCode', BONUS_CODE);
                gen.writeStringField('externalUserName', '');
                gen.writeNumberField('rewardAmount', pointsToAdd);
                gen.writeEndObject();
            gen.writeEndObject();
        gen.writeEndObject();        
        return gen.getAsString();
    }

    // Enrollment callout Method
    @AuraEnabled
    public static LoyaltyExperienceServiceResponseWrapper makeLoyaltyEnrollmentCallout(String first_name, String last_name, String email_id, String phone_number){
        try {
            Loyalty_Service_Setting__mdt lss_mdt = Loyalty_Service_Setting__mdt.getInstance(LOYALTY_ENROLLMENT);
            String endpoint = lss_mdt.Base_Url__c;
            VS_EnrollRequestWrapper enrollRequestWrapper = new VS_EnrollRequestWrapper(BRAND,email_id,first_name,last_name,phone_number, SOURCE_CODE,SOURCE_LOCATION_CODE,SOURCE_CHANNEL_CODE, DEFAULT_CUSTOMER_TYPE);
            String jsonBody = JSON.serialize(enrollRequestWrapper);
            system.debug('jsonBody'+jsonBody);
            HttpRequest request = new HttpRequest();
            request.setEndpoint( endpoint );
            request.setMethod( POST_METHOD );
            request.setTimeout(10000);
            request.setBody(jsonBody);
            HttpResponse response = new Http().send( request );
            LoyaltyExperienceServiceResponseWrapper  respInstance = new LoyaltyExperienceServiceResponseWrapper();
            if( response.getStatusCode() == 200 ){
                Map<String, Object> enrollResponse = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                respInstance.statusCode = response.getStatusCode();
                respInstance.response = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody() );
                if(respInstance.statusCode == 200 && respInstance.response.containsKey('message')){
                    return respInstance;
                }else if(respInstance.statusCode == 200 && respInstance.response.containsKey('vsLoyaltyId')){
                    String loyaltyIdValue = (String) respInstance.response.get('vsLoyaltyId'); 
                    String CIDValue = (String) respInstance.response.get('cgridId'); 
                    if(String.isNotBlank(CIDValue) && String.isNotBlank(loyaltyIdValue)){
                        Account[] acctRecord = [SELECT ID, FirstName, LastName, PersonEmail, Phone, CID__c, Loyalty_ID__pc 
                                              FROM Account 
                                              WHERE Loyalty_ID__pc =: null AND PersonEmail =: email_id AND CID__c != null];
                        if(acctRecord.size()>0){
                            acctRecord[0].FirstName = first_name;
                            acctRecord[0].LastName = last_name;
                            acctRecord[0].PersonEmail = email_id;
                            acctRecord[0].Phone = phone_number;
                            acctRecord[0].CID__c =  CIDValue;
                            acctRecord[0].Loyalty_ID__pc = loyaltyIdValue;
                            acctRecord[0].Rewards_Enrollment__c = true;
                            update acctRecord;
                        }else{
                            Account newAccountRecord = new Account();
                            newAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                            newAccountRecord.FirstName = first_name;
                            newAccountRecord.LastName = last_name;
                            newAccountRecord.PersonEmail = email_id;
                            newAccountRecord.Phone = phone_number;
                            newAccountRecord.CID__c = CIDValue;
                            newAccountRecord.Loyalty_ID__pc = loyaltyIdValue;
                            newAccountRecord.Rewards_Enrollment__c = true;
                            insert newAccountRecord;
                        }
                    }
                    return respInstance;
                }else{
                    Logger.error('Error while enrolling loyalty customer'+respInstance.response);               
                    Logger.saveLog();
                    return respInstance;
                }             
            }else{
                respInstance.statusCode = response.getStatusCode();
                respInstance.response = ( Map<String, Object> ) JSON.deserializeUntyped( response.getBody());
                Logger.error('Error while enrolling loyalty customer'+response.getBody());               
                Logger.saveLog();
                return respInstance;
            }
        } catch (Exception ex) {
            Logger.error('Exception while enrolling loyalty customer'+ex.getMessage());
            Logger.saveLog();
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @TestVisible
    public class LoyaltyExperienceServiceResponseWrapper{
        @AuraEnabled
        public Map<String, Object> response;
        @AuraEnabled
        public Integer statusCode;
    }
    public class LoyaltyCustomerRequestWrapper{
        public String vsLoyaltyID;
        public LoyaltyCustomerRequestWrapper(String LoyaltyID){
            vsLoyaltyID = LoyaltyID;
        }
	
    }
}