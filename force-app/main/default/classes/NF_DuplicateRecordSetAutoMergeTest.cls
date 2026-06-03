@isTest
public class NF_DuplicateRecordSetAutoMergeTest {
    // if this number > 5, tests fail due to hitting limits in setup
    static Integer NUMBER_ACCOUNT_PAIRS_TO_CREATE = 5;
	@testSetup
    static void testSetupFunc() {
        // gathers the record types we'll be using
        Id PersonAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id DigitalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Digital_Domestic').getRecordTypeId();
        DuplicateRule dr = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Email_Only_Duplicate_Person_Accounts'];

        Account[] sourceAccounts = new Account[]{};
        Account[] dupeAccounts = new Account[]{};
        Account[] allAccounts = new Account[]{};

        for (Integer i = 0; i<NUMBER_ACCOUNT_PAIRS_TO_CREATE; i++) {
            // create a CID enabled account and related duplicate account
            Account sourceAccount = new Account(
                FirstName = 'Test '+String.valueOf(i),
                LastName = 'Account',
                Phone = '123456789'+i,
                PersonEmail = 'test_account-'+String.valueOf(i)+'@example.com.invalid',
                RecordTypeId = PersonAccountRecordTypeId,
                CID__c = '12345-ABCDE-'+String.valueOf(i)
            );

            Account dupeAccount = sourceAccount.clone(false, true, false, false);
            dupeAccount.CID__c = null;

            insert new Account[] {sourceAccount, dupeAccount};

            // get related contact records for Case creation
            Contact sourceContact = [SELECT Id FROM Contact WHERE AccountId = :sourceAccount.Id];
            Contact dupeContact = [SELECT Id FROM Contact WHERE AccountId = :dupeAccount.Id];
            
            // create related case records (to validate merge)
            Case sourceAccountCase = new Case(
                AccountId = sourceAccount.Id,
                ContactId = sourceContact.Id,
                Subject = sourceAccount.Name + ' - Case',
                RecordTypeId = DigitalCaseRecordTypeId,
                Origin = 'Email'
            );

            Case dupeAccountCase = sourceAccountCase.clone(false, true, false, false);
            dupeAccountCase.AccountId = dupeAccount.Id;
            dupeAccountCase.ContactId = dupeContact.Id;

            insert new Case[]{sourceAccountCase, dupeAccountCase};


            // create Duplicate Record entities as in tests they do not generate automatically
            DuplicateRecordSet drs = new DuplicateRecordSet(
                DuplicateRuleId = dr.Id
            );

            insert drs;
			List<DuplicateRecordItem> lstrecordItem = new List<DuplicateRecordItem>();
            DuplicateRecordItem sourceDRI = new DuplicateRecordItem(
                DuplicateRecordSetId = drs.Id,
                RecordId = sourceAccount.Id
            );
			lstrecordItem.add(sourceDRI);

            DuplicateRecordItem dupeDRI = new DuplicateRecordItem(
                DuplicateRecordSetId = drs.Id,
                RecordId = dupeAccount.Id
            );
            lstrecordItem.add(dupeDRI);

            insert lstrecordItem;
//            insert dupeDRI;

            // force re-run of flow (should set the DRS record to 'Automate Merge')
            drs.Category__c = null;
            drs.Losing_Account__c = dupeAccount.Id;
            drs.Winning_Account__c = sourceAccount.Id;
            update drs;
        }
    }

    // negative test on getFullAccountFieldsSingle
    @isTest 
    static void negativeTestGetAccount() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Account nullAccount = NF_DuplicateRecordSetAccountAutoMerge.getFullAccountFieldsSingle(c.Id);
        System.assertEquals(null, nullAccount);
    }

    // tests that if the losing account is more recently updated, then the values are mapped to the winning account
    @isTest
    static void testUpdateLosingAccount() {
        Datetime dtPast = Datetime.now().addHours(-2);

        DuplicateRecordSet[] drsList = [SELECT Losing_Account__c FROM DuplicateRecordSet];
        List<Id> accountIdList = new List<Id>{};
        for (DuplicateRecordSet drs:drsList) {
            accountIdList.add(drs.Losing_Account__c);
        }
        List<Account> losingAccountList = [SELECT Id, PersonOtherState, PersonMailingState FROM Account WHERE Id IN :accountIdList];
        for (Account losingAccount:losingAccountList) {
            losingAccount.PersonOtherState = 'CA';
            losingAccount.PersonMailingState = 'CA';
            //update losingAccount;
        }
        update losingAccountList;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        NF_DuplicateRecordSetAccountAutoMerge batch = new NF_DuplicateRecordSetAccountAutoMerge(dtPast); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
        System.debug(batch);
        Account[] listMergedAccounts = [SELECT Id, Merge_Requested_CGrid_Update__c, PersonOtherState, PersonMailingState FROM Account];
        for (Account mergeAccount:listMergedAccounts) {
            System.assertEquals('CA', mergeAccount.PersonMailingState, 'Merged Account PersonMailingState should be updated to CA');
            System.assertEquals('CA', mergeAccount.PersonOtherState, 'Merged Account PersonOtherState should be updated to CA');
            //System.assertEquals(false, mergeAccount.Merge_Requested_CGrid_Update__c, 'Merged account should no longer be flagged for an update in cgrid');
        }
        System.assertEquals(NUMBER_ACCOUNT_PAIRS_TO_CREATE, listMergedAccounts.size());

        Logger__c[] allLogs = [SELECT Id, Log_Type__c, Class_Name__c, Source_Method__c, Message__c FROM Logger__c ORDER BY CreatedDate ASC];
       // System.assert(allLogs.size() == 2, 'there should be two log entries');
        System.assert(allLogs[0].Message__c.contains('Starting'), 'first log entry should be for the start');
        //System.assert(allLogs[1].Message__c.contains('DRS Records processed: '+listMergedAccounts.size()), 'log should say all drs got processed');
      //  System.assert(allLogs[1].Message__c.contains('Accounts flagged to update in CGrid: '+listMergedAccounts.size()), 'log should say all accounts were flagged to update');
     //   System.assert(allLogs[1].Message__c.contains('Accounts updated in CGrid: '+listMergedAccounts.size()), 'log should say all accounts were updated in cgrid');
    }

    // tests that if the losing account is more recently updated, then the values are mapped to the winning account
    @isTest
    static void testUpdateLosingAccountCGridDown() {
        Datetime dtPast = Datetime.now().addHours(-2);

        DuplicateRecordSet[] drsList = [SELECT Losing_Account__c FROM DuplicateRecordSet];
        List<Id> accountIdList = new List<Id>{};
        for (DuplicateRecordSet drs:drsList) {
            accountIdList.add(drs.Losing_Account__c);
        }
        List<Account> losingAccountList = [SELECT Id, PersonOtherState, PersonMailingState FROM Account WHERE Id IN :accountIdList];
        for (Account losingAccount:losingAccountList) {
            losingAccount.PersonOtherState = 'CA';
            losingAccount.PersonMailingState = 'CA';
            //update losingAccount;
        }
        update losingAccountList;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpFailUpdateResponseGenerator());
        NF_DuplicateRecordSetAccountAutoMerge batch = new NF_DuplicateRecordSetAccountAutoMerge(dtPast); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
        System.debug(batch);
        Account[] listMergedAccounts = [SELECT Id, Merge_Requested_CGrid_Update__c, Merge_Requested_CGrid_Field_Updates__c, PersonOtherState, PersonMailingState FROM Account];
        for (Account mergeAccount:listMergedAccounts) {
            System.assertEquals('CA', mergeAccount.PersonMailingState, 'Merged Account PersonMailingState should be updated to CA');
            System.assertEquals('CA', mergeAccount.PersonOtherState, 'Merged Account PersonOtherState should be updated to CA');
            System.assertEquals(true, mergeAccount.Merge_Requested_CGrid_Update__c, 'Merged account should be flagged for an update in cgrid');
            System.assert(mergeAccount.Merge_Requested_CGrid_Field_Updates__c.contains('PersonMailingState'), 'Merged account should be flagged to update PersonMailingState');
        }
        System.assertEquals(NUMBER_ACCOUNT_PAIRS_TO_CREATE, listMergedAccounts.size());

        Logger__c[] allLogs = [SELECT Id, Log_Type__c, Class_Name__c, Source_Method__c, Message__c FROM Logger__c ORDER BY CreatedDate ASC];
        Logger__c[] allProcessLogs = new Logger__c[]{};
        Logger__c[] allExceptionLogs = new Logger__c[]{};
        for (Logger__c logEntry:allLogs) {
            if (logEntry.Log_Type__c == 'Process Log') {
                allProcessLogs.add(logEntry);
            } else {
                allExceptionLogs.add(logEntry);
            }
        }
        System.debug(allLogs);
        System.debug(allProcessLogs);
        System.debug(allExceptionLogs);
        System.assert(allProcessLogs.size() == 2, 'there should be two process log entries');
        System.assert(allExceptionLogs.size() == 5, 'there should be five exception log entries');
        System.assert(allProcessLogs[0].Message__c.contains('Starting'), 'first log entry should be for the start');
        System.assert(allProcessLogs[1].Message__c.contains('DRS Records processed: '+listMergedAccounts.size()), 'log should say all drs got processed');
        System.assert(allProcessLogs[1].Message__c.contains('Accounts flagged to update in CGrid: '+listMergedAccounts.size()), 'log should say all accounts were flagged to update');
        System.assert(allProcessLogs[1].Message__c.contains('Accounts updated in CGrid: 0'), 'log should say no accounts were updated in cgrid');
    }

    // tests that if the losing account is more recently updated, then the values are mapped to the winning account
    @isTest
    static void testUpdateLosingAccountCGridPostFail() {
        Datetime dtPast = Datetime.now().addHours(-2);

        DuplicateRecordSet[] drsList = [SELECT Losing_Account__c FROM DuplicateRecordSet];
        List<Id> accountIdList = new List<Id>{};
        for (DuplicateRecordSet drs:drsList) {
            accountIdList.add(drs.Losing_Account__c);
        }
        List<Account> losingAccountList = [SELECT Id, PersonOtherState, PersonMailingState FROM Account WHERE Id IN :accountIdList];
        for (Account losingAccount:losingAccountList) {
            losingAccount.PersonOtherState = 'CA';
            losingAccount.PersonMailingState = 'CA';
            //update losingAccount;
        }
        update losingAccountList;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpFailUpdateResponseGenerator());
        NF_DuplicateRecordSetAccountAutoMerge batch = new NF_DuplicateRecordSetAccountAutoMerge(dtPast); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
        System.debug(batch);
        Account[] listMergedAccounts = [SELECT Id, Merge_Requested_CGrid_Update__c, Merge_Requested_CGrid_Field_Updates__c, PersonOtherState, PersonMailingState FROM Account];
        for (Account mergeAccount:listMergedAccounts) {
            System.assertEquals('CA', mergeAccount.PersonMailingState, 'Merged Account PersonMailingState should be updated to CA');
            System.assertEquals('CA', mergeAccount.PersonOtherState, 'Merged Account PersonOtherState should be updated to CA');
            System.assertEquals(true, mergeAccount.Merge_Requested_CGrid_Update__c, 'Merged account should be flagged for an update in cgrid');
            System.assert(mergeAccount.Merge_Requested_CGrid_Field_Updates__c.contains('PersonMailingState'), 'Merged account should be flagged to update PersonMailingState');
        }
        System.assertEquals(NUMBER_ACCOUNT_PAIRS_TO_CREATE, listMergedAccounts.size());

        Logger__c[] allLogs = [SELECT Id, Log_Type__c, Class_Name__c, Source_Method__c, Message__c FROM Logger__c ORDER BY CreatedDate ASC];
        Logger__c[] allProcessLogs = new Logger__c[]{};
        Logger__c[] allExceptionLogs = new Logger__c[]{};
        for (Logger__c logEntry:allLogs) {
            if (logEntry.Log_Type__c == 'Process Log') {
                allProcessLogs.add(logEntry);
            } else {
                allExceptionLogs.add(logEntry);
            }
        }
        System.debug(allLogs);
        System.debug(allProcessLogs);
        System.debug(allExceptionLogs);
        System.assert(allProcessLogs.size() == 2, 'there should be two process log entries');
        System.assert(allExceptionLogs.size() == 5, 'there should be five exception log entries');
        System.assert(allProcessLogs[0].Message__c.contains('Starting'), 'first log entry should be for the start');
        System.assert(allProcessLogs[1].Message__c.contains('DRS Records processed: '+listMergedAccounts.size()), 'log should say all drs got processed');
        System.assert(allProcessLogs[1].Message__c.contains('Accounts flagged to update in CGrid: '+listMergedAccounts.size()), 'log should say all accounts were flagged to update');
        System.assert(allProcessLogs[1].Message__c.contains('Accounts updated in CGrid: 0'), 'log should say no accounts were updated in cgrid');
    }

    // tests that if the winning account is more recently updated, then the values are not overridden by the losing account
    @isTest
    static void testUpdateWinningAccount() {
        AccountTriggerHandler.TriggerDisabled = true;
        Datetime dtPast = Datetime.now().addHours(-2);
        DuplicateRecordSet[] drsList = [SELECT Winning_Account__c FROM DuplicateRecordSet];
        List<Id> accountIdList = new List<Id>{};
        for (DuplicateRecordSet drs:drsList) {
            accountIdList.add(drs.Winning_Account__c);
        }
        List<Account> winningAccountList = [SELECT Id, PersonOtherState, PersonMailingState FROM Account WHERE Id IN :accountIdList];
        for (Account winningAccount:winningAccountList) {
            winningAccount.PersonOtherState = 'CA';
            winningAccount.PersonMailingState = 'CA';
        }
        update winningAccountList;

        Test.startTest();
        NF_DuplicateRecordSetAccountAutoMerge batch = new NF_DuplicateRecordSetAccountAutoMerge(dtPast); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
        Account[] listMergedAccounts = [SELECT Id, PersonOtherState, PersonMailingState FROM Account];
        for (Account mergeAccount:listMergedAccounts) {
            System.assertEquals('CA', mergeAccount.PersonMailingState, 'Merged Account PersonMailingState should be updated to CA');
            System.assertEquals('CA', mergeAccount.PersonOtherState, 'Merged Account PersonOtherState should be updated to CA');
        }
        System.assertEquals(NUMBER_ACCOUNT_PAIRS_TO_CREATE, listMergedAccounts.size());
    }

    // validates the batch process can run with one parameter
    @isTest
    static void confirmSuccessBatchRun() {
        Datetime dtPast = Datetime.now().addHours(-2);
        Test.startTest();
        NF_DuplicateRecordSetAccountAutoMerge batch = new NF_DuplicateRecordSetAccountAutoMerge(dtPast); 
        Database.executeBatch(batch, 20);
        Test.stopTest();
    }

    // validates the batch process can run with two parameters
    @isTest
    static void confirmSuccessBatchRunDualParam() {
        Datetime dtPast = Datetime.now().addHours(-2);
        Datetime dtFuture = Datetime.now().addHours(1);
        Test.startTest();
        NF_DuplicateRecordSetAccountAutoMerge batch = new NF_DuplicateRecordSetAccountAutoMerge(dtPast, dtFuture); 
        Database.executeBatch(batch, 20);
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
    
    private class MockHttpFailUpdateResponseGenerator implements HttpCalloutMock {
    
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().endsWith('/customer/')) {
                res.setStatusCode(200);
                System.debug('>>>>>>>> GET ENDPOINT');
                System.debug(req.getEndpoint());
                res.setBody(createGETCustomerResponse());
            }
            else if(req.getEndpoint().endsWith('/customer/save')) {
                res.setStatusCode(404);
                System.debug('>>>>>>>> SAVE ENDPOINT');
                System.debug(req.getEndpoint());
                res.setBody(createSAVECustomerResponse());
            }
            else {    
                res.setStatusCode(404);
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

    /*
        This is mock response generator for c-grid apis for a failure scenario.
    */
    private class MockFailHttpResponseGenerator implements HttpCalloutMock {
    
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(404);
            res.setBody('{"example":"test"}');
            return res;
        }
    }
}