/*
***********************************************************************************************************
* Program Name      : VSDirectMailPrefController
* Description       : Controller class to manage request and response.
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37152    1.1         Ravikant Kedia      17-05-2021      Created Controller class to get
*                                                                               the Direct mail Preference details.
* REQ_02            DP-37152    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
public class VSDirectMailPrefController {
    
    public static Map<String, LBrands_API_Integration_Setting__mdt> endPointMetaData = LBrands_API_Integration_Setting__mdt.getAll();
    public static Map<string, State_and_Country_Territory_Mapping__mdt> statesMetaData = State_and_Country_Territory_Mapping__mdt.getAll();
    
    @AuraEnabled(cacheable=true)
    public static String fetchStateList(){
        Map<String, List<SelectOpt>> stateMap = new Map<String, List<SelectOpt>>();
        for(State_and_Country_Territory_Mapping__mdt sctmd : statesMetaData.values()) {
            if(!stateMap.containsKey(sctmd.Country__c)) {
                stateMap.put(sctmd.Country__c, new List<SelectOpt>());
            }
            List<SelectOpt> soList = stateMap.get(sctmd.Country__c);
            soList.add(new SelectOpt(sctmd.Label, sctmd.QualifiedApiName));
            stateMap.put(sctmd.Country__c, soList);
        }
        return JSON.serialize(stateMap);
    }
    
    @AuraEnabled
    public static Boolean getAccountDetails(String email) {
        Boolean UCG = [Select UCG__c From Account where PersonEmail =: email limit 1].UCG__c;
        UCG = UCG != null ? UCG : FALSE;
        return UCG;
    }
    
    @AuraEnabled
    public static String getDirectMailPrefDetails( String recordId, String objectName ) {
        String queryString = 'SELECT Id, ';
        if( objectName == 'Case' ) {
            queryString += 'AccountId, Account.FirstName, Account.LastName, Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingState';
        } else {
            queryString += 'ContactId, Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, Contact.MailingState';
        }
        queryString += ' FROM ' + objectName + ' WHERE Id = :recordId';
        List<sObject> recordList = Database.query( queryString );
        return JSON.serialize( recordList[0] );
    }
    
    @AuraEnabled
    public static String updateDirectMailPrefDetails(String email, String newMailFrequency, String countryCode, String firstName, String lastname, String streetAddress1, String streetAddress2, String city, String region, String  postalCode, String recordId, String objectName) {
        String emailOpt = 'optIn';
        RestResponse response = new RestResponse();
        
        if(newMailFrequency == '05') {
            emailOpt = 'optOut';
        }
        
        LBrands_API_Integration_Setting__mdt endPointMetadataObj = endPointMetaData.get('CCCTools_VSDirectMailPref_Update');
        if( endPointMetadataObj.Active__c ) {
            // Created Service class object
            CCCToolsMailRestService directMailPrefService = new CCCToolsMailRestService();
            directMailPrefService.endPointMetadataObj = endPointMetadataObj;
            // Created POST Request Object
            PostRequest postReq = new PostRequest();
            postReq.setBody('{ "address": { "countryCode": "' + countryCode + '", "firstName": "' + firstName + '", "lastName": "' + lastname + '", "streetAddress1": "' + streetAddress1 + '", "streetAddress2": "' + streetAddress2 + '", "city": "' + city + '", "region": "' + region + '", "postalCode": "' + postalCode + '" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "'+ emailOpt +'", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }');        
            // call service class method and store responce in RestResponse class object
            response = directMailPrefService.doPost(postReq);
            if(response.getStatusCode() ==200){
               response.setData(endPointMetadataObj.Status_Code_200_Message__c );
            }  

            logger.info('CCCTools_VSDirectMailPref_Update '+response);
            logger.saveLog();
            return JSON.serialize(response);
        } else {
            RestServiceError serviceError = new RestServiceError();
            serviceError.setMessage( endPointMetadataObj.Status_Code_500_Message__c );
            serviceError.setErrorCode( 500 );
            response.setError( serviceError );
            return JSON.serialize(response);
        }
    }
    
    public class SelectOpt {
        public String label;
        public String value;
        public SelectOpt(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}