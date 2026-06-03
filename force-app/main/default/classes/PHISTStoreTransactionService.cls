/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* service class to make callout
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-03-25
* @modified       2021-07-07
* @systemLayer    Wrapper
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-14      code commenting

* v1.0            ravikant.kedia@neuraflash.com
* 2021-07-07      updated error deserialization in method doGet() and method doPost()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class PHISTStoreTransactionService implements IRestService {

    public LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
    public Integer timeOut = ( Integer )lbAPI.Timeout__c == null ? 5000 : lbAPI.Timeout__c.intValue();
    
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
    * make a callout for POST request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public RestResponse checkMaxFullfillmentStatusId( IRestRequest request ) {
        PostRequest req = ( PostRequest )request;

        //make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod( 'POST' );
		calloutRequest.setEndpoint( req.getRelativeEndpoint() );
        calloutRequest.setBody( req.getBody() );

        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode == 200 ) {
            if( resp.getBody() != null ) {
                Map<String, Object> r = ( Map<String, Object> ) JSON.deserializeUntyped( resp.getBody() );
                List<Object> dataList = (List<Object>) r.get('data');
                if( dataList[0] != null ) {
                    Map<String, Object> r1 = (Map<String, Object>) dataList[0];
                    response.setData( r1.get('MaxFulfillmentStatusId') );
                }
            }
        }else {
            if( !String.isEmpty(resp.getBody()) ) {
                RestServiceError serviceError = ( RestServiceError )JSON.deserialize( resp.getBody(), RestServiceError.class );
                serviceError.setErrorCode( statusCode );
                response.setError( serviceError );
                Logger.error(resp.getBody());
                Logger.saveLog();
            }
        }
        return response;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * make a callout for GET request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    request         IRestRequest
    * @return   IRestResponse   callout response
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public RestResponse doGet( IRestRequest request ){
        GetRequest req = ( GetRequest )request;

        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod( 'GET' );
		calloutRequest.setEndpoint( req.getRelativeEndpoint() );

        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode != 200 ){
            // If ther is error in retrieivng the data
            RestServiceError serviceError = ( RestServiceError )JSON.deserialize( resp.getBody(), RestServiceError.class );
            serviceError.setErrorCode( statusCode );
            response.setError( serviceError );
            Logger.error(resp.getBody());
            Logger.saveLog();
        } else {
            // Valid response
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
    public RestResponse doPost( IRestRequest request ){
        // Type cast into the PostRequest
        PostRequest req = ( PostRequest )request;

        // Make the callout request
        HttpRequest calloutRequest = new HttpRequest();
		calloutRequest.setMethod( 'POST' );
		calloutRequest.setEndpoint( req.getRelativeEndpoint() );
        calloutRequest.setBody( req.getBody() );
        calloutRequest.setTimeout( timeOut );
        // Response
        HTTPResponse resp = new Http().send( calloutRequest );
        RestResponse response = new RestResponse();
        Integer statusCode = resp.getStatusCode();
        response.setStatusCode( statusCode );
        if( statusCode == 200 ){
            response.setData( resp.getBody() );
        }else {
            RestServiceError serviceError = ( RestServiceError )JSON.deserialize( resp.getBody(), RestServiceError.class );
            serviceError.setErrorCode( statusCode );
            response.setError( serviceError );
            Logger.error(resp.getBody());
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