/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* service class to make callout for Chat Bot
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-08-13
* @modified       2021-08-13
* @systemLayer    Wrapper
* @see            ????
* @see            ????
* @jiraId		  DP-39921 Service class for canceling orders from chatbot.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            manishi.kalra@neuraflash.com
* 2021-09-08      adding jira refrence
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class AOOrderCancellationService implements IRestService {

    
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
    public RestResponse doPost( IRestRequest request ){
        // Type cast into the PostRequest
        PostRequest req = ( PostRequest )request;
        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod( 'POST' );
		calloutRequest.setEndpoint( req.getRelativeEndpoint() );
        calloutRequest.setBody(req.getBody());
        // Response
        HTTPResponse resp = new Http().send( calloutRequest );

        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode == 200 ) {
            response.setData( JSON.serialize((AOOrderCancellationWrapper) System.JSON.deserialize(resp.getBody(), AOOrderCancellationWrapper.class)) );
        } else {
            RestServiceError serviceError = new RestServiceError();
            serviceError.setErrorCode( statusCode );
            if( statusCode == 400 ) {
                serviceError.setMessage('{ "success": false }' );
            } else if( statusCode == 404 ) {
                serviceError.setMessage('{ "success": false }' );
            } else if( statusCode == 500 ) {
                serviceError.setMessage('{ "success": false }' );
            } else if( statusCode == 503 ) {
                serviceError.setMessage('{ "success": false }' );
            } else {
                serviceError.setMessage('{ "success": false }' );
            }
            response.setError( serviceError );
            Logger.error('{ "success": false }');
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