/****************************************************************************************************************
* Program Name         : CallOutService
* Description          : This class is used to make different types of callout.
*                        Make use of methods as per your request Type. The class contains 
*                        virtual methods in case the child class implemnting this class 
*                        needs to have thier own logic for authenticating or changng the
*                        common request code pattern.
* Version              : 1.1
* Modification Log     : 12 May, 2021 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version         Developer             Date          Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01           Utility Class       1.1       Divyanshu Kumar      05/12/2021     This class is used to make different types of callout.
*                                                                                     Make use of methods as per your request Type. The class contains 
*                                                                                     virtual methods in case the child class implemnting this class 
*                                                                                     needs to have thier own logic for authenticating or changng the
*                                                                                     common request code pattern.        
*                                                                                                                                                                                                 
*****************************************************************************************************************/
public virtual class CallOutService implements IRestService {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Authenticate the callout request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    * Override this method in child class to authenitcate the request.
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void authenticate(){}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for GET request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual RestResponse doGet( IRestRequest request ){
         // Type cast into the PostRequest
        GetRequest req = ( GetRequest )request;

        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
        calloutRequest.setMethod( 'GET' );
        calloutRequest.setEndpoint( req.getRelativeEndpoint());
        calloutRequest.setBody( req.getBody() );
        Map<String,String> headers = req.getHeaders();
        if(!headers.isEmpty()){
            for(String s : headers.keyset()){
                calloutRequest.setHeader(s, headers.get(s));
            } 
        }
        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode != 200 ){
            RestServiceError serviceError = new RestServiceError();
            serviceError.setMessage( resp.getBody() );
            serviceError.setErrorCode( statusCode );
            response.setError( serviceError );
        } else {
            response.setData( resp.getBody() );
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
    public virtual RestResponse doPost( IRestRequest request ){
        // Type cast into the PostRequest
        PostRequest req = ( PostRequest )request;

        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod( 'POST' );
		calloutRequest.setEndpoint( req.getRelativeEndpoint() );
        calloutRequest.setBody( req.getBody() );

        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode != 200 ){
            RestServiceError serviceError = new RestServiceError();
            serviceError.setMessage( resp.getBody() );
            serviceError.setErrorCode( statusCode );
            response.setError( serviceError );
        } else {
            response.setData( resp.getBody() );
        }
        return response;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for PUT request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * Description - Put the common code here for put request if there is some scenario of PUT request.
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual RestResponse doPut( IRestRequest request ){
        return new RestResponse();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for Delete request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * Description - Put the common code here for Delete request if there is some scenario of DELETE 
    *               request.
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual RestResponse doDelete( IRestRequest request ){
        return new RestResponse();
    }
}