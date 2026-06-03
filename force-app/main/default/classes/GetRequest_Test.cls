/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for GetRequest.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-29
* @modified       2021-06-23
* @systemLayer    Test class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0              ravikant.kedia@neuraflash.com
* 2021-06-23        updated method bodyTest() and endpointTest()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class GetRequest_Test {
    
    @isTest
    static void headersTest(){
        Test.startTest();
            Map<String, String> headers = new Map<String, String>{ 'hello' => 'world' };
            GetRequest gr = new GetRequest();
            gr.setHeaders( headers );
            Map<String, String> getHeaders = gr.getHeaders();
            System.assertEquals( 'world', getHeaders.get( 'hello' ) );
        Test.stopTest();
    }

    @isTest
    static void bodyTest(){
        Test.startTest();
            GetRequest gr = new GetRequest();
            gr.setBody( 'testBody' );
            System.assertEquals( 'testBody', gr.getBody() );
        Test.stopTest();
    }

    @isTest
    static void paramTest(){
        Test.startTest();
            Map<String, String> params = new Map<String, String>{ 'hello' => 'world' };
            GetRequest gr = new GetRequest();
            gr.setParameters( params );
            Map<String, String> getParams = gr.getParameters();
            System.assertEquals( 'world', getParams.get( 'hello' ) );
        Test.stopTest();
    }

    @isTest
    static void endpointTest(){
        Test.startTest();
            GetRequest gr = new GetRequest();
            gr.setRelativeEndpoint( 'testEndpoint' );
            System.assertEquals( 'testEndpoint', gr.getRelativeEndpoint() );
        Test.stopTest();
    }
}