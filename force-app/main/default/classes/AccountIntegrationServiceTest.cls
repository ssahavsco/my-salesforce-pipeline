/****************************************************************************************************************
* Program Name         : AccountIntegrationServiceTest
* Description          : Provide coverage to AccountIngtegrationService.
* Version              : 1.1
* Modification Log     : 12 May, 2021 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-37893       1.1       Divyanshu Kumar      05/13/2021     Provide coverage to AccountIngtegrationService.   
*                                                                                                                                                                                                 
*****************************************************************************************************************/
@isTest
public with sharing class AccountIntegrationServiceTest {
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
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Account accUpdated = [SELECT id,FirstName FROM Account LIMIT 1];
        accUpdated.FirstName = 'DivTest';
        update accUpdated;
        List<String> changedFields = AccountTriggerHelper.getChangedFields(acc,accUpdated, new List<String>{'FirstName'});
		System.enqueueJob(new AccountIntegrationService(acc,changedFields));   
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
            res.setBody(createGETCustomerResponse());
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
}