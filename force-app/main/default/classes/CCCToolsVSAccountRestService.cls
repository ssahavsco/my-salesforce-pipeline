/*
***********************************************************************************************************
* Program Name      : CCCToolsVSAccountRestService
* Description       : Service class to hit API and get response.
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37149    1.1         Ravikant Kedia      14-05-2021      Created Service class for API hit.
* REQ_02            DP-37149    1.2         Ravikant Kedia      26-05-2021      commenting and hit Proper API to get 
*                                                                               the data.
                    DP-61909    1.3         Sharath Vadla       12-20-2021      Adding Nebula Logger methods
***********************************************************************************************************
*/
public class CCCToolsVSAccountRestService implements IRestService {


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
        GetRequest req = ( GetRequest )request;
        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod( 'GET' );
		calloutRequest.setEndpoint(endPointMetadataObj.Endpoint__c);
        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
         if( statusCode == 200 ) {
            // Valid response
            response.setData(resp.getBody());
        } else {
            RestServiceError serviceError = new RestServiceError();
            serviceError.setErrorCode( statusCode );
            if( statusCode == 400 ) {
                serviceError.setMessage( endPointMetadataObj.Status_Code_400_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_400_Message__c);
            } else if( statusCode == 404 ) {
                serviceError.setMessage( endPointMetadataObj.Status_Code_404_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_404_Message__c);
            } else if( statusCode == 500 ) {
                serviceError.setMessage(endPointMetadataObj.Status_Code_500_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_500_Message__c);
            } else if( statusCode == 503 ) {
                serviceError.setMessage(endPointMetadataObj.Status_Code_503_Message__c );
                Logger.error(endPointMetadataObj.Status_Code_503_Message__c);
            } else {
                serviceError.setMessage( resp.getBody() );
                Logger.error(resp.getBody());
            }
            response.setError( serviceError );
            Logger.saveLog();
        } 
        return response;
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