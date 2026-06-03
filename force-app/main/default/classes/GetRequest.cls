/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex class designed to create HTTP GET requests.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-03-25
* @modified       2021-04-14
* @systemLayer    Rest
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-14      did code commenting
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class GetRequest implements IRestRequest {
    
    private Map<String, String> headers;
    private Map<String, String> params;
    private String relativeEndpoint;
    private String body;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * get headers map
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Map<String, String> HTTP request headers
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Map<String, String> getHeaders(){
        return headers;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * set headers and their value for the HTTP request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    headers    Map<String,String>
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setHeaders( Map<String, String> headers ){
        this.headers = headers;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * get body for HTTP Request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   String    HTTP request body
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public String getBody(){
        return body;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * set body for the HTTP request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    body    String( body of the request )
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setBody( String body ){
        this.body = body;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * get params map
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Map<String, String>    HTTP request params
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public Map<String, String> getParameters(){
        return params;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * set params and their value for the HTTP request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    params    Map<String, String>
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setParameters( Map<String, String> params ){
        this.params = params;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * get Endpoint for HTTP request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   String    HTTP request endpoint
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public String getRelativeEndpoint(){
        return relativeEndpoint;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * set endpoint for the HTTP GET request
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    relativeEndpoint    String (HTTP endpoint)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void setRelativeEndpoint( String relativeEndpoint ){
		this.relativeEndpoint = relativeEndpoint;
    }
}