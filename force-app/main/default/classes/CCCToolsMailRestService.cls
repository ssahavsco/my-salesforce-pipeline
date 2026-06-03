/*
***********************************************************************************************************
* Program Name      : CCCToolsMailRestService
* Description       : Service class for  controller
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37152    1.1         Ravikant Kedia      17-05-2021      Created service class to hit API.
* REQ_02            DP-37152    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
public class CCCToolsMailRestService implements IRestService {


public LBrands_API_Integration_Setting__mdt endPointMetadataObj;
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Authenticate the callout request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void authenticate() {}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for GET request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
	public RestResponse doGet( IRestRequest request ) {
        return new RestResponse();
    }


    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for POST request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public RestResponse doPost( IRestRequest request ) {        
        PostRequest req = ( PostRequest )request;
        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod('POST' );
		calloutRequest.setEndpoint(endPointMetadataObj.Endpoint__c);
        calloutRequest.setBody(req.getBody());

        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode == 200) {
            // Valid response
            response.setData(resp.getBody());
        } else {
            RestServiceError serviceError = new RestServiceError();
            serviceError.setErrorCode( statusCode );
            if( statusCode == 400 ) {
                serviceError.setMessage(endPointMetadataObj.Status_Code_400_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_400_Message__c);
            } else if( statusCode == 404 ) {
                serviceError.setMessage( endPointMetadataObj.Status_Code_404_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_404_Message__c);
            } else if( statusCode == 500 ) {
                serviceError.setMessage( endPointMetadataObj.Status_Code_500_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_500_Message__c);
            } else if( statusCode == 503 ) {
                serviceError.setMessage( endPointMetadataObj.Status_Code_503_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_503_Message__c);
            } else {
                serviceError.setMessage( resp.getBody() );
                Logger.error(endPointMetadataObj.Status_Code_503_Message__c);
            }
            response.setError( serviceError );
            Logger.saveLog();
        }
        return response;
    }


    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for PUT request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public RestResponse doPut( IRestRequest request ){
        return new RestResponse();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for Delete request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public RestResponse doDelete( IRestRequest request ){
        return new RestResponse();
    }
}