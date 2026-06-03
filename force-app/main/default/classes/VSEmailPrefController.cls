/*
***********************************************************************************************************
* Program Name      : VSEmailPrefController
* Description       : Controller class to manage request and response.
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37150    1.1         Ravikant Kedia      17-05-2021      Created Controller class 
*                                                                               to get the email Preference details.
* REQ_02            DP-37150    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
public class VSEmailPrefController {

    public static Map<String, LBrands_API_Integration_Setting__mdt> endPointMetaData = LBrands_API_Integration_Setting__mdt.getAll();

    @AuraEnabled
    public static Boolean getAccountDetails(String email) {
        Boolean UCG = [Select UCG__c From Account where PersonEmail =: email limit 1].UCG__c;
        UCG = UCG != null ? UCG : FALSE;
        return UCG;
    }
    @AuraEnabled
    public static String getEmailPrefDetails(String email) {
        RestResponse response = new RestResponse();
        CCCToolsEmailRestService emailPrefService = new CCCToolsEmailRestService();
        LBrands_API_Integration_Setting__mdt endPointMetadataObj = endPointMetaData.get('CCCTools_VSEmailPref_Detail');
        emailPrefService.endPointMetadataObj = endPointMetadataObj;
    
        if(endPointMetadataObj.Active__c ) {            
            // Created Get Request Object
            PostRequest postReq = new PostRequest();
            postReq.setBody('{"email": "' + email + '"}');
            // call service class method and store responce in RestResponse class object
            response = emailPrefService.doPost(postReq);
            String responseData = (String) response.getData();
            if (responseData != null) {
               response.setData((CCCToolsVSEmailPrefWrapper) System.JSON.deserialize(responseData, CCCToolsVSEmailPrefWrapper.class));
            }
            return JSON.serialize(response);
        } else {
            RestServiceError serviceError = new RestServiceError();
            serviceError.setMessage(endPointMetadataObj.Status_Code_500_Message__c );
            serviceError.setErrorCode( 500 );
            response.setError( serviceError );
            return JSON.serialize(response);
        }
    }

    @AuraEnabled
    public static String updateEmailPrefDetails(String email, String newEmailFrequency, String recordId, String objectName) {
        String emailOpt = 'optIn';
        RestResponse response = new RestResponse();

        if(newEmailFrequency == '05') {
            emailOpt = 'optOut';
        }


        LBrands_API_Integration_Setting__mdt endPointMetadataObj = endPointMetaData.get('CCCTools_VSEmailPref_Update');

        if( endPointMetadataObj.Active__c ) {
            // Created Service class object
	        CCCToolsEmailRestService emailPrefService = new CCCToolsEmailRestService();	
            emailPrefService.endPointMetadataObj = endPointMetadataObj;
            // Created POST Request Object
            PostRequest postReq = new PostRequest();
            postReq.setBody('{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "'+ email +'", "frequency" : "'+ newEmailFrequency +'", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "'+ emailOpt + '"} }');
            
            // call service class method and store responce in RestResponse class object
            response = emailPrefService.doPost(postReq);
            if(response.getStatusCode() ==200){
               response.setData(endPointMetadataObj.Status_Code_200_Message__c );
            }  
            logger.info('VSEmailPrefController '+response);
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
}