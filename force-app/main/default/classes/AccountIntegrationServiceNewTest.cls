/****************************************************************************************************************
* Program Name         : AccountIntegrationServiceNewTest
* Description          : Provide coverage to AccountIngtegrationServiceNew.
* Version              : 1.1
* Modification Log     : 3 July, 2023
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          CCS-13       1.1       Himanshu Mishra      07/03/2023     Provide coverage to AccountIngtegrationServiceNew.   
*                                                                                                                                                                                                 
*****************************************************************************************************************/
@isTest
public with sharing class AccountIntegrationServiceNewTest {
    
    @IsTest
    public static void sendAccountDataTest() {
        Account acc = new Account();
        acc.FirstName = 'Divyanshu';
        acc.LastName = 'Kumar';
        acc.PersonEmail = 'thuwaldk@gmail.com';
        acc.Phone = '9699876542';
        acc.PersonMailingCity = 'Coffeyville';
        acc.PersonMailingCountry = 'United States';
        acc.PersonMailingState = 'Kansas';
        acc.PersonMailingStreet = 'East\n North\n Street';
        acc.PersonMailingPostalCode = '67337';
        acc.ShippingCity = 'Coffeyville';
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Kansas';
        acc.ShippingStreet = 'East\n North\n Street';
        acc.ShippingPostalCode = '67337';
        acc.CID__c = 'aaa6c118-4601-4bee-8fdc-a6e22e069db5';
        insert acc;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        AccountIntegrationServiceNew.Input input = new AccountIntegrationServiceNew.Input();
        input.firstName = acc.FirstName;
        input.lastName = acc.LastName;
        input.email = acc.PersonEmail;
        input.phone = acc.PersonMobilePhone;
        input.street = acc.PersonMailingStreet;
        input.city = acc.PersonMailingCity;
        input.postalCode = acc.PersonMailingPostalCode;
        input.country = acc.PersonMailingCountry;
        input.state = acc.PersonMailingState;
        input.CID = acc.CID__c;
        
        List<AccountIntegrationServiceNew.Input> inputList = new List<AccountIntegrationServiceNew.Input>();
        inputList.add(input);
        AccountIntegrationServiceNew.getCustomer(inputList);
        Test.stopTest();
    }

    /*
        This is mock response generator for c-grid apis.
    */
    private class MockHttpResponseGenerator implements HttpCalloutMock {
    
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if(req.getEndpoint().endsWith('/customer/')) {
                System.debug('>>>>>>>> GET ENDPOINT');
                System.debug(req.getEndpoint());
                res.setBody(createGETCustomerResponse());
            }
            else if(req.getEndpoint().endsWith('/customer/save')) {
                System.debug('>>>>>>>> SAVE ENDPOINT');
                System.debug(req.getEndpoint());
                res.setBody(createSAVECustomerResponse());
            }
            else {    
                System.debug('>>>>>>>> UNKNOWN ENDPOINT');
                System.debug(req.getEndpoint());
                res.setBody('{"example":"test"}');
            }
            return res;
        }

        String createGETCustomerResponse() {
            String testString=		'[{'+
		'	"id": "aaa6c118-4601-4bee-8fdc-a6e22e069db5",'+
		'	"rid": "569bae8e-bdcd-4e78-8cc4-d5225560a89e",'+
		'	"brand": "VS",'+
		'	"email": "thuwaldk@gmail.com",'+
		'	"phone": "9699876542",'+
		'	"firstName": "Divyanshu",'+
		'	"lastName": "Kumar",'+
		'	"direct": true,'+
		'	"address": {'+
		'		"streetAddress1": "East",'+
		'		"streetAddress2": "North",'+
		'		"streetAddress3": "Street",'+
		'		"pobox": "billing pobox",'+
		'		"city": "Coffeyville",'+
		'		"state": "Kansas",'+
		'		"postalCode": "67337",'+
		'		"country": "United States"'+
		'	},'+
		'	"shipAddress": {'+
		'		"streetAddress1": "East",'+
		'		"streetAddress2": "North",'+
		'		"streetAddress3": "Street",'+
		'		"pobox": "shipping pobox",'+
		'		"city": "Coffeyville",'+
		'		"state": "Kansas",'+
		'		"postalCode": "67337",'+
		'		"country": "United States"'+
		'	},'+
		'	"lastUpdateTime": "2021-02-12T17:20:21.999334"'+
		'}]';
            return testString;
	    }

        String createSAVECustomerResponse() {
            String testString=		'{'+
		'	"customerID": "aaa6c118-4601-4bee-8fdc-a6e22e069db5",'+
		'	"customerRID": "569bae8e-bdcd-4e78-8cc4-d5225560a89e"'+
		'}';
            return testString;
        }
    }
    public class Input{
        public String firstName;
	    public String lastName;
        public String email;
        public String phone;
        public String street;
        public String city;
        public String postalCode;
        public String country;
        public String state;
        public String CID;
    }
}