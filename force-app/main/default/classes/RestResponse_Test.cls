/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for RestResponse.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-29
* @modified       2021-04-29
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class RestResponse_Test {
    
    @isTest
    static void statusCodeTest(){
        Test.startTest();
            RestResponse rr = new RestResponse();
            rr.setStatusCode( 200 );
            System.assertEquals( 200, rr.getStatusCode() );
        Test.stopTest();
    }

    @isTest
    static void errorTest(){
        Test.startTest();
            RestServiceError error = new RestServiceError();
            error.setMessage( 'errorMessage' );
            RestResponse rr = new RestResponse();
            rr.setError( error );
            RestServiceError getError = rr.getError();
            System.assertEquals( 'errorMessage', getError.getMessage() );
        Test.stopTest();
    }

    @isTest
    static void dataTest(){
        Test.startTest();
            RestResponse rr = new RestResponse();

            rr.setData( 'data' );
            System.assertEquals( 'data', (String)rr.getData() );
        Test.stopTest();
    }

    @isTest
    static void headersTest(){
        Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'hello' => 'world' };
            RestResponse rr = new RestResponse();
            rr.setHeaders( headers );
            Map<String, String> getHeaders = rr.getHeaders();
            System.assertEquals( 'world', getHeaders.get( 'hello' ) );
        Test.stopTest();
    }
}