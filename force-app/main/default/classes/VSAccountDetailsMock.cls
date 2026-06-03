/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for VSAccountDetailsMock
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-05-13
* @modified       2021-05-14
* @systemLayer    Controller
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-14      if criteria added and RestResponse class added to store the fake response
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global with sharing class VSAccountDetailsMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        Map<String, LBrands_API_Integration_Setting__mdt> endPointMetaData = LBrands_API_Integration_Setting__mdt.getAll();
        HttpResponse res = new HttpResponse();
        String jsonResponse; // use to store fake response and then store in HttpResponse class object and return it to the service class
      
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Generate fake response for Authentication and Getting access token
        * ───────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        if(req.getEndpoint() == 'authenticationEndpoint/apiauthentication/v1/token?grant_type=client_credentials&client_secret=clientSecret&client_id=clientId' ) {
            jsonResponse = '{ "access_token" : "access_token" }';
            res.setBody( jsonResponse );
            res.setStatusCode( 200 );
        }
        
        
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Generate fake response to get Account Details
        * ───────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getBody() == '{"email": "someone200@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{"customerProfile": {"email": "someone@host.com","customerId": "f584304a-68a5-42fc-8b14-c24e764f09dc","custPrefCC": {"ccType": "MASTERCARD", "ccLastFour": "9999", "ccExpiry": "09/20229" }, "address": { "addressName": "sample firstname wang", "streetAddress1": "5 Limited Pkwy E", "city": "Reynoldsburg", "state": "OH", "countryCode": "US", "postalCode": "43068-5300", "phone": "6146265891" }, "onlineHistory": { "sid": "47670f81-ded7-41e3-a7e8-55d70ef81244", "availableLoginAttempts": "5", "failedLoginAttempts": "0", "passwordResetLinkExpireDate": "Wed Feb 3, 17:02:53 PM EST 2029", "lastFailedLoginDate": "Wed Feb 3, 17:02:53 PM EST 2021", "lastSuccessfulLoginDate": "Fri Feb 12, 14:08:00 PM EST 2021", "dateAccountLastUpdated": "Mon Jan 28, 03:59:40 AM EST 49524", "createdAccountDate": "Mon Jan 28, 03:59:40 AM EST 49524" } }, "lineItem": [ { "variantId": "26183588", "colorCode": "Pink Stripe", "sizeCode": "One Size", "adjustedPrice": "15.50", "origPrice": "15.50", "qty": "1" }, { "variantId": "26193599", "colorCode": "Demure Pink/Pink Fizz", "sizeCode": "34D", "adjustedPrice": "49.50", "origPrice": "49.50", "qty": "1" }]}';
            res.setBody( jsonResponse );
            res.setStatusCode( 200 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getBody() == '{"email": "someone500@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody( jsonResponse );
            res.setStatusCode( 500 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getBody() == '{"email": "someone400@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody( jsonResponse );
            res.setStatusCode( 400 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getBody() == '{"email": "someone404@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody( jsonResponse );
            res.setStatusCode( 404 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getBody() == '{"email": "someone503@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 503 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getBody() == '{"email": "someone510@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 510 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/customer' && req.getHeader('Authorization') == 'Bearer Expired_Access_Token') {
            jsonResponse = '{ "Error": "Bad Request"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 401 );
        }
        
        
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Generate fake response for Account Detail Delete request
        * ───────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getBody() == '{"email": "someone200@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "success"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 200 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getBody() == '{"email": "someone500@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 500 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getBody() == '{"email": "someone400@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 400 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getBody() == '{"email": "someone404@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 404 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getBody() == '{"email": "someone503@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 503 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getBody() == '{"email": "someone510@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 510 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/deletecustomeraccount' && req.getHeader('Authorization') == 'Bearer Expired_Access_Token' ) {
            jsonResponse = '{ "Error": "Bad Request"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 401 );
        }
        
        
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Generate fake response to Get Email Pref frequency Details
        * ───────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getBody() == '{"email": "someone200@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{"fq": "04","result": "N"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 200 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getBody() == '{"email": "someone500@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 500 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getBody() == '{"email": "someone400@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 400 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getBody() == '{"email": "someone404@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 404 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getBody() == '{"email": "someone503@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 503 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getBody() == '{"email": "someone510@host.com"}' && req.getHeader('Authorization') == 'Bearer access_token' ) {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 510 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/emailpref' && req.getHeader('Authorization') == 'Bearer Expired_Access_Token') {
            jsonResponse = '{ "Error": "Bad Request"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 401 );
        }
        
     	
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Generate fake response for Email Pref Frequency update
        * ───────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "someone200@host.com", "frequency" : "05", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "optOut"} }') {
            jsonResponse = '{"cid": "0d06159cce8de2e1dbfee4d870041172f28261e73716aa149911a618272089b0"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 200 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "someone500@host.com", "frequency" : "05", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "optOut"} }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 500 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "someone400@host.com", "frequency" : "05", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "optOut"} }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 400 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "someone404@host.com", "frequency" : "05", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "optOut"} }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 404 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "someone503@host.com", "frequency" : "05", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "optOut"} }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 503 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{"brand" : "VS", "consent" : "E", "source" : "VSSFSC", "email" : "someone510@host.com", "frequency" : "05", "optInsVs" : { "smsOptIn" : "notCollected", "mailOptIn" : "notCollected", "emailOptIn" : "optOut"} }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 510 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/ccc/v5/updateemailpref' && req.getHeader('Authorization') == 'Bearer Expired_Access_Token') {
            jsonResponse = '{ "Error": "Bad Request"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 401 );
        }
        
        
        /**
        * ───────────────────────────────────────────────────────────────────────────────────────────────┐
        * * Generate fake response for Direct Mail Marketing Pref Frequency update
        * ───────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "CA", "firstName": "Test", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "200" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "firstName": "Jill", "lastName": "Hamilton", "countryCode": "US", "streetAddress1": "5959 Bigger Rd", "city": "Kettering", "region": "OH", "postalCode": "45440" }';
            res.setBody(jsonResponse);
            res.setStatusCode( 200 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "CA", "firstName": "Tst", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "500" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "error" : "address not found." }';
            res.setBody(jsonResponse);
            res.setStatusCode( 500 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "None", "firstName": "Tst", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "500" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 500 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "CA", "firstName": "Tst", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "400" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 400 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "CA", "firstName": "Tst", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "404" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 404 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "CA", "firstName": "Tst", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "503" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 503 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer access_token' && req.getBody() == '{ "address": { "countryCode": "CA", "firstName": "Tst", "lastName": "User", "streetAddress1": "", "streetAddress2": "", "city": "", "region": "", "postalCode": "510" }, "forceSaveAddress": false, "brand": "VS", "consent": "E", "source": "VSSFSC", "optInsVs": { "mailOptIn": "optOut", "smsOptIn": "notCollected", "emailOptIn": "notCollected" } }') {
            jsonResponse = '{ "result": "service is down"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 510 );
        } else if(req.getEndpoint() == 'apitest.victoriassecret.com/subscriptions/v5/sf/mail' && req.getHeader('Authorization') == 'Bearer Expired_Access_Token') {
            jsonResponse = '{ "Error": "Bad Request"}';
            res.setBody(jsonResponse);
            res.setStatusCode( 401 );
        }
        return res;
    }
}