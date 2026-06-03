/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for RestServiceError.cls
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
public class RestServiceError_Test {
   
    @isTest
    static void messageTest(){
        Test.startTest();
            RestServiceError rsr = new RestServiceError();
            rsr.setMessage( 'message' );
            System.assertEquals( 'message', rsr.getMessage() );
        Test.stopTest();
    }

    @isTest
    static void errorCodeTest(){
        Test.startTest();
        RestServiceError rsr = new RestServiceError();
        rsr.setErrorCode( 403 );
        System.assertEquals( 403, rsr.getErrorCode() );
        Test.stopTest();
    }
}