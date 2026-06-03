/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for PostRequest.cls
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
public class PostRequest_Test {
    
    @isTest
    static void headersTest(){
        Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'hello' => 'world' };
            PostRequest pr = new PostRequest();
            pr.setHeaders( headers );
            Map<String, String> getHeaders = pr.getHeaders();
            System.assertEquals( 'world', getHeaders.get( 'hello' ) );
        Test.stopTest();
    }

    @isTest
    static void bodyTest(){
        Test.startTest();
            PostRequest pr = new PostRequest();
            pr.setBody( 'testBody' );
            System.assertEquals( 'testBody', pr.getBody() );
        Test.stopTest();
    }

    @isTest
    static void paramTest(){
        Test.startTest();
            Map<String, String> params = new Map<String, String>{ 'hello' => 'world' };
            PostRequest pr = new PostRequest();
            pr.setParameters( params );
            Map<String, String> getParams = pr.getParameters();
            System.assertEquals( 'world', getParams.get( 'hello' ) );
        Test.stopTest();
    }

    @isTest
    static void endpointTest(){
        Test.startTest();
            PostRequest pr = new PostRequest();
            pr.setRelativeEndpoint( 'testBody' );
            System.assertEquals( 'testBody', pr.getRelativeEndpoint() );
        Test.stopTest();
    }
}