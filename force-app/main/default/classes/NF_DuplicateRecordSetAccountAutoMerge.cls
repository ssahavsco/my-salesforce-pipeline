/****************************************************************************************************************
* Program Name         : NF_DuplicateRecordSetAccountAutoMerge
* Description          : This batch class can handle merging accounts listed in DuplicateRecordSet
*                        entities, flagged as Automatic merges for a provided timeframe
*                        Maximum batch size: 50 (potential for 2 callouts per Account)
* Version              : 1.0
* Created Date (YMD)   : 2021 / 08 / 31
* Modified Date (YMD)  : 2021 / 08 / 31
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version         Developer             Date          Description 
*------------------------------------------------------------------------------------------------------------------------------
* N/A (PPD)         DP-46916      1.0             Peter Waddington      2021/08/31    First version
*
*****************************************************************************************************************/

// this class follows the Batchable process listed at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_batch_interface.htm
global with sharing class NF_DuplicateRecordSetAccountAutoMerge implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public final DateTime earliestRecord;
    public final DateTime latestRecord;
    public Boolean useCreatedTime;
    public Integer accountsToUpdate;
    public Integer accountsUpdated;
    public Integer processedDRSRecords;
    // these fields need to be added to the query in the execute function

    // standardFieldsToMerge will map values from losing -> winning if winning field is null
    static String[] nullFieldsToMerge = new String[]{
        'Description', 
        'JWT_Token__pc', 
        'Case_Subject__pc',
        'PersonDoNotCall',
        'PersonHasOptedOutOfEmail',
        'PersonHasOptedOutOfFax',
        'PersonHomePhone',
        'PersonBirthdate',
        'PersonOtherState',
        'PersonOtherStreet', 
        'PersonOtherPostalCode', 
        'PersonOtherCity', 
        'PersonOtherCountry',
        'PersonOtherPhone'
    };
    
    // verificationFieldsToMerge will map values from the account with the more recent last verification to the elder one, if last verification != created date
    static String[] verificationFieldsToMerge = new String[]{
        'BillingState',
        'BillingStreet', 
        'BillingPostalCode', 
        'BillingCity', 
        'BillingCountry',
        'ShippingState',
        'ShippingStreet', 
        'ShippingPostalCode', 
        'ShippingCity', 
        'ShippingCountry',
        'Phone',
        'PersonMailingState',
        'PersonMailingStreet', 
        'PersonMailingPostalCode', 
        'PersonMailingCity', 
        'PersonMailingCountry',
        'PersonMobilePhone'
    };

    // process all records in a given timeframe
    public NF_DuplicateRecordSetAccountAutoMerge(DateTime startTime, DateTime endTime, Boolean useCreatedTime) {
        earliestRecord = startTime;
        latestRecord = endTime;
        useCreatedTime = useCreatedTime;
        processedDRSRecords = 0;
        accountsToUpdate = 0;
        accountsUpdated = 0;
    }

    // process all records in a given timeframe
    public NF_DuplicateRecordSetAccountAutoMerge(DateTime startTime, DateTime endTime) {
        earliestRecord = startTime;
        latestRecord = endTime;
        useCreatedTime = true;
        processedDRSRecords = 0;
        accountsToUpdate = 0;
        accountsUpdated = 0;
    }

    // set a point in time from which all DRS records which match the criteria should be processed
    public NF_DuplicateRecordSetAccountAutoMerge(DateTime startTime) {
        earliestRecord = startTime;
        latestRecord = DateTime.now();
        useCreatedTime = true;
        processedDRSRecords = 0;
        accountsToUpdate = 0;
        accountsUpdated = 0;
    }

    // gather the set of accounts that we intend to merge
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('>>>>>>>>>>>> START');
        LoggerUtility.insertProcessLog('NF_DuplicateRecordSetAccountAutoMerge', 'start', 'Starting Auto Merge process for timeframe: '+this.earliestRecord.format()+' to '+this.latestRecord.format());
        if (useCreatedTime == true) {
            return Database.getQueryLocator([
                SELECT
                    Id,
                    Losing_Account__c,
                    Winning_Account__c
                FROM DuplicateRecordSet
                WHERE
                    CreatedDate <= :this.latestRecord
                    AND CreatedDate > :this.earliestRecord
                    AND Category__c = 'Automate Merge'
                    AND Duplicate_Rule_Object__c = 'Account'
                    AND Losing_Account__c != NULL
                    AND Winning_Account__c != NULL
                    AND DuplicateRule.DeveloperName = 'Email_Only_Duplicate_Person_Accounts'
                    AND Emails_Still_Match__c = 'Yes'
            ]);
        } else {
            return Database.getQueryLocator([
                SELECT
                    Id,
                    Losing_Account__c,
                    Winning_Account__c
                FROM DuplicateRecordSet
                WHERE
                    LastModifiedDate <= :this.latestRecord
                    AND LastModifiedDate > :this.earliestRecord
                    AND Category__c = 'Automate Merge'
                    AND Duplicate_Rule_Object__c = 'Account'
                    AND Losing_Account__c != NULL
                    AND Winning_Account__c != NULL
                    AND DuplicateRule.DeveloperName = 'Email_Only_Duplicate_Person_Accounts'
                    AND Emails_Still_Match__c = 'Yes'
            ]);
        }
        
    }

    // checks which account has more recently been validated
    @TestVisible
    private static Boolean isLosingAccountVerificationDateMoreRecent(Account losingAccount, Account winningAccount) {
        if (losingAccount.get('Last_Verification_Date_Time__c') == null) {
            return false;
        }
        if (winningAccount.get('Last_Verification_Date_Time__c') == null) {
            return true;
        }
        if (losingAccount.Last_Verification_Date_Time__c > winningAccount.Last_Verification_Date_Time__c) {
            return true;
        }
        return false;
    }

    // set fields on the winning account following the logic laid out in DP-46916
    public static Account mergeAccountFieldData(Account losingAccount, Account winningAccount) {
        for (String fieldName:nullFieldsToMerge) {
            if(winningAccount.isSet(fieldName) && losingAccount.isSet(fieldName)) {
                if (winningAccount.get(fieldName) == null && losingAccount.get(fieldName) != null) {
                    winningAccount.put(fieldName, losingAccount.get(fieldName));
                }
            }
        }
        if (isLosingAccountVerificationDateMoreRecent(losingAccount, winningAccount)) {
            for (String fieldName:verificationFieldsToMerge) {
                if(winningAccount.isSet(fieldName) && losingAccount.isSet(fieldName)) {
                    winningAccount.put(fieldName, losingAccount.get(fieldName));
                }
            }
        }
        return winningAccount;
    }

    // updates the winning account with values form the losing account
    // if any CGrid significant fields have been updated, flag the account as needing a CGrid update and which fields need updating
    @TestVisible
    private static Account updateWinningAccount(Account losingAccount, Account winningAccount) {
        // apply field delta if needed
        Account winningAccountBefore = winningAccount.clone(false, true, true, true);
        winningAccount = mergeAccountFieldData(losingAccount, winningAccount);

        // check if relevant fields changed so we can flag it not to update through the Account Trigger mechanism
        List<String> changedFields = AccountTriggerHelper.getChangedFields(winningAccount, winningAccountBefore, new List<String>{'FirstName','LastName','MiddleName','PersonEmail','Phone',
                                            'PersonMailingStreet','PersonMailingCity','PersonMailingState','PersonMailingPostalCode','PersonMailingCountry',
                                            'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry'});

        if (!changedFields.isEmpty()) {
            winningAccount.Merge_Requested_CGrid_Update__c = true;
            winningAccount.Merge_Requested_CGrid_Field_Updates__c = JSON.serialize(changedFields);
        }

        return winningAccount;
    }

    // useful for getting an individual records with all the fields required by the class, more useful for testing purposes
    @TestVisible
    private static Account getFullAccountFieldsSingle(Id accountId) {
        Id[] accountIdAsList = new Id[]{accountId};
        Account[] accountAsList = getFullAccountFieldsList(accountIdAsList);
        if (accountAsList.size() > 0) {
            return accountAsList[0];
        }
        return null;
    }

    // get the set of Accounts with all the fields required for merging
    @TestVisible
    private static Account[] getFullAccountFieldsList(Id[] accountIds) {
        return [
            SELECT 
                Id,
                FirstName,
                MiddleName,
                LastName,
                PersonEmail,
                CID__c,
                Last_Verification_Date_Time__c,
                Description,
                JWT_Token__pc,
                Case_Subject__pc,
                BillingState,
                BillingStreet,
                BillingPostalCode,
                BillingCity,
                BillingCountry,
                ShippingState,
                ShippingStreet,
                ShippingPostalCode,
                ShippingCity,
                ShippingCountry,
                Phone,
                PersonMailingState,
                PersonMailingStreet,
                PersonMailingPostalCode,
                PersonMailingCity,
                PersonMailingCountry,
                PersonMobilePhone,
                PersonDoNotCall,
                PersonHasOptedOutOfEmail,
                PersonHasOptedOutOfFax,
                PersonHomePhone,
                PersonBirthdate,
                PersonOtherState,
                PersonOtherStreet,
                PersonOtherPostalCode,
                PersonOtherCity,
                PersonOtherCountry,
                Merge_Requested_CGrid_Update__c,
                Merge_Requested_CGrid_Field_Updates__c,
                PersonOtherPhone
            FROM Account
            WHERE Id IN :accountIds
        ];
    }
    
    /*
        process data for cgrid update
    */

    private static AccountIntegrationService.SaveCustomerRequestWrapper createSaveCallRequest(List<String> changedFields, Account sfdcAccount, AccountIntegrationService.GetAccountResponseWrapper cGridAccount){
        AccountIntegrationService.SaveCustomerRequestWrapper objSaveReq = new AccountIntegrationService.SaveCustomerRequestWrapper();
        objSaveReq.id = sfdcAccount.CID__c;
        objSaveReq.firstName = changedFields.contains('FirstName') ? sfdcAccount.FirstName : cGridAccount.firstName;
        objSaveReq.lastName = changedFields.contains('LastName') ? sfdcAccount.LastName : cGridAccount.lastName;
        objSaveReq.email = changedFields.contains('PersonEmail') ? sfdcAccount.PersonEmail : cGridAccount.email;
        objSaveReq.brand = cGridAccount.brand;
        objSaveReq.direct = cGridAccount.direct;
        objSaveReq.phone = changedFields.contains('Phone') ? sfdcAccount.Phone : cGridAccount.phone;
        objSaveReq.channel = 'SALESFORCE';
        objSaveReq.middleName = changedFields.contains('MiddleName') ? sfdcAccount.MiddleName : null;
        //-----------Match Address-----------------
        objSaveReq.address.state = changedFields.contains('BillingState') ? sfdcAccount.BillingState : cGridAccount.address.state;
        objSaveReq.address.city = changedFields.contains('BillingCity') ? sfdcAccount.BillingCity : cGridAccount.address.city;
        objSaveReq.address.country = changedFields.contains('BillingCountry') ? sfdcAccount.BillingCountry : cGridAccount.address.country;
        objSaveReq.address.postalCode = changedFields.contains('BillingPostalCode') ? sfdcAccount.BillingPostalCode : cGridAccount.address.postalCode;
        objSaveReq.address.pobox = cGridAccount.address.pobox;
        //----------------Match Shipping Address------------
        objSaveReq.shipAddress.state = changedFields.contains('PersonMailingState') ? sfdcAccount.PersonMailingState : cGridAccount.shipAddress.state;
        objSaveReq.shipAddress.city = changedFields.contains('PersonMailingCity') ? sfdcAccount.PersonMailingCity : cGridAccount.shipAddress.city;
        objSaveReq.shipAddress.country = changedFields.contains('PersonMailingCountry') ? sfdcAccount.PersonMailingCountry : cGridAccount.shipAddress.country;
        objSaveReq.shipAddress.postalCode = changedFields.contains('PersonMailingPostalCode') ? sfdcAccount.PersonMailingPostalCode : cGridAccount.shipAddress.postalCode;
        objSaveReq.shipAddress.pobox = cGridAccount.shipAddress.pobox;
        objSaveReq = processAccountStreetDetails(changedFields, sfdcAccount, cGridAccount, objSaveReq);
        return objSaveReq;
    }

    private static AccountIntegrationService.SaveCustomerRequestWrapper processAccountStreetDetails(List<String> changedFields, Account sfdcAccount, AccountIntegrationService.GetAccountResponseWrapper cGridAccount, AccountIntegrationService.SaveCustomerRequestWrapper objSaveReq){
        List<String> lstMailingStreet;
        List<String> lstBillingStreet;
        if(changedFields.contains('PersonMailingStreet')){
            lstMailingStreet = sfdcAccount.PersonMailingStreet.split('\n');
        }
        if(changedFields.contains('BillingStreet')){
            lstBillingStreet = sfdcAccount.BillingStreet.split('\n');
        }
        //-----Address Street------------
        objSaveReq.address.streetAddress1 = (lstBillingStreet != null && lstBillingStreet[0] != null) ?  lstBillingStreet[0] : cGridAccount.address.streetAddress1;
        //---Ship Address Street----------
        objSaveReq.shipAddress.streetAddress1 = (lstMailingStreet != null && lstMailingStreet[0] != null) ?   lstMailingStreet[0] : cGridAccount.shipAddress.streetAddress1;
        try{
            objSaveReq.address.streetAddress2 = (lstBillingStreet != null && lstBillingStreet[1] != null) ?  lstBillingStreet[1] : cGridAccount.address.streetAddress2;
            objSaveReq.address.streetAddress3 = (lstBillingStreet != null && lstBillingStreet[2] != null) ?  lstBillingStreet[2] : cGridAccount.address.streetAddress3;
        }
        catch(Exception e){
            System.debug('ADDRESS EXCEPTION :: LIST INDEX OUT OF BOUNDS FOR STREET BILLING ADDRESS '+ e.getMessage());
        }
        try{
            objSaveReq.shipAddress.streetAddress2 = (lstMailingStreet != null && lstMailingStreet[1] != null) ?   lstMailingStreet[1] : cGridAccount.shipAddress.streetAddress2;
            objSaveReq.shipAddress.streetAddress3 = (lstMailingStreet != null && lstMailingStreet[2] != null) ?  lstMailingStreet[2] : cGridAccount.shipAddress.streetAddress3;
        }
        catch(Exception e){
            System.debug('ADDRESS EXCEPTION :: LIST INDEX OUT OF BOUNDS FOR STREET SHIPPING ADDRESS '+ e.getMessage());
        }
        return objSaveReq;
    }

    /*
        callouts to external services
    */

    // prepare submission to update an account in CGrid
    private static HttpRequest preparePostRequest(AccountIntegrationService.SaveCustomerRequestWrapper postData) {
        C_Grid_API_Config__mdt saveCustomerMetadata = C_Grid_API_Config__mdt.getInstance('SAVECustomer');
        HttpRequest calloutRequest = new HttpRequest();
        calloutRequest.setMethod('POST');
        calloutRequest.setEndpoint( saveCustomerMetadata.Endpoint__c );
        calloutRequest.setBody( JSON.serialize( postData ) );

        return calloutRequest;
    }

    // prepare request for an account in CGrid
    private static HttpRequest prepareFetchRequest(String cgridID) {
        AccountIntegrationService.GetCustomerByIdWrapper objReq = new AccountIntegrationService.GetCustomerByIdWrapper();
        objReq.brand = 'VS';
        objReq.id = cgridID;

        C_Grid_API_Config__mdt getCustomerMetadata = C_Grid_API_Config__mdt.getInstance('GETCustomer');

        HttpRequest calloutRequest = new HttpRequest();
        calloutRequest.setMethod('POST');
        calloutRequest.setEndpoint( getCustomerMetadata.Endpoint__c );
        calloutRequest.setBody( JSON.serialize( objReq ) );

        return calloutRequest;
    }
    
    // post an update to CGrid
    public static Boolean postCGridAccountData(AccountIntegrationService.SaveCustomerRequestWrapper payload, String workedId) {
        HttpRequest calloutRequest = preparePostRequest(payload);
        HTTPResponse resp = new Http().send( calloutRequest );
        Integer statusCode = resp.getStatusCode();
        if( statusCode == 200 ){
            return true;
        } else {
            CalloutException e = new CalloutException();
            e.setMessage('status code: '+String.valueOf(StatusCode) + ' - response to posting cgrid data for account id: '+workedId+' - '+resp.getBody());
            throw e;
        }
    }

    // get account data from CGrid
    public static AccountIntegrationService.GetAccountResponseWrapper getCGridAccountData(Account winningAccount) {
        String cgridID = winningAccount.CID__c;
        AccountIntegrationService.GetAccountResponseWrapper accountDetailsFromCGrid;
        HttpRequest calloutRequest = prepareFetchRequest(cgridID);
        System.debug(calloutRequest.getEndpoint());
        HTTPResponse resp = new Http().send(calloutRequest);
        Integer statusCode = resp.getStatusCode();
        if( statusCode == 200 ){
            System.debug('>>>>>>>> RESPONSE');
            System.debug(resp.getBody());
            List<AccountIntegrationService.GetAccountResponseWrapper> resGetApiObj = ( List<AccountIntegrationService.GetAccountResponseWrapper>)JSON.deserialize(String.valueOf( resp.getBody() ), List<AccountIntegrationService.GetAccountResponseWrapper>.class);
            if(!resGetApiObj.isEmpty()){
                return resGetApiObj[0];
            } else {
                return null;
            }
        } else {
            CalloutException e = new CalloutException();
            e.setMessage('status code: '+String.valueOf(StatusCode) + ' - response to getting cgrid data for account id: '+winningAccount.Id+' - '+resp.getBody());
            throw e;
        }
    }

    /*
        execute and finish methods
    */
    // get a batch of accounts and run merges on them
    public void execute(Database.BatchableContext BC, List<DuplicateRecordSet> drsList) {
        System.debug('>>>>>>>>>>>> BATCH SIZE: '+drsList.size());

        // disable the account trigger, otherwise undesired CGrid update attempts will be queued up causing issues
        //AccountTriggerHandler.TriggerDisabled = true;

        // populate list of accounts we'll process
        List<Id> BatchAccountIds = new List<Id>();
        for (DuplicateRecordSet drs:drsList) {
            processedDRSRecords++;
            System.debug(processedDRSRecords);
            BatchAccountIds.add(drs.Losing_Account__c);
            BatchAccountIds.add(drs.Winning_Account__c);
        }
        
        // build a map of the accounts we'll process
        Account[] BatchAccountList = getFullAccountFieldsList(BatchAccountIds);
        Map<Id, Account> BatchAccountMap = new Map<Id, Account>();
        for (Account acc:BatchAccountList) {
            BatchAccountMap.put(acc.Id, acc);
        }
        
        System.debug('>>>>>>>>>before account map');
        System.debug(BatchAccountMap);
        
        // do field merges on winning accounts
        for (DuplicateRecordSet drs:drsList) {
            System.debug(drs);
            System.debug('>> losing');
            System.debug(BatchAccountMap.get(drs.Losing_Account__c));
            System.debug(BatchAccountMap.get(drs.Losing_Account__c).BillingCity);
            System.debug(BatchAccountMap.get(drs.Losing_Account__c).PersonMailingCity);
            System.debug('>> winning');
            System.debug(BatchAccountMap.get(drs.Winning_Account__c));
            System.debug(BatchAccountMap.get(drs.Winning_Account__c).BillingCity);
            System.debug(BatchAccountMap.get(drs.Winning_Account__c).PersonMailingCity);
            Account updatedAccount = updateWinningAccount(BatchAccountMap.get(drs.Losing_Account__c), BatchAccountMap.get(drs.Winning_Account__c));
            System.debug('>> updated');
            System.debug(updatedAccount);
            System.debug(updatedAccount.BillingCity);
            System.debug(updatedAccount.PersonMailingCity);
            System.debug(updatedAccount.Merge_Requested_CGrid_Update__c);
            System.debug(updatedAccount.Merge_Requested_CGrid_Field_Updates__c);
            BatchAccountMap.put(drs.Winning_Account__c, updatedAccount);
        }
        
        System.debug('>>>>>>>>>after account map');
        System.debug(BatchAccountMap);

        // do CGrid gets on updated accounts if they're flagged as needing an update
        Map<Id, AccountIntegrationService.GetAccountResponseWrapper> BatchCGridAccountMap = new Map<Id, AccountIntegrationService.GetAccountResponseWrapper>();
        Exception[] eList = new Exception[]{};
        List<Id> failedCGridUpdates = new List<Id>{};
        for (DuplicateRecordSet drs:drsList) {
            Account winningAccount = BatchAccountMap.get(drs.Winning_Account__c);
            // did winning account get flagged as needing a cgrid update?
            if (winningAccount.Merge_Requested_CGrid_Update__c) {
                this.accountsToUpdate++;
                try {
                    AccountIntegrationService.GetAccountResponseWrapper winningAccountCGridData = getCGridAccountData(winningAccount);
                    BatchCGridAccountMap.put(winningAccount.Id, winningAccountCGridData);
                } catch (Exception e) {
                    System.debug(e);
                    eList.add(e);
                    failedCGridUpdates.add(winningAccount.Id);
                }
            }
        }
        

        // do CGrid updates on updated accounts if they're flagged as needing an update
        for (DuplicateRecordSet drs:drsList) {
            Account winningAccount = BatchAccountMap.get(drs.Winning_Account__c);
            // did winning account get flagged as needing a cgrid update, and were we able to get data?
            if (winningAccount.Merge_Requested_CGrid_Update__c && BatchCGridAccountMap.containsKey(winningAccount.Id)) {
                try {
                    List<String> changedFields = (List<String>)JSON.deserialize(winningAccount.Merge_Requested_CGrid_Field_Updates__c, List<String>.class);
                    AccountIntegrationService.GetAccountResponseWrapper cGridAccountData = BatchCGridAccountMap.get(winningAccount.Id);
                    AccountIntegrationService.SaveCustomerRequestWrapper objSaveReq = createSaveCallRequest(changedFields, winningAccount, cGridAccountData);
                    Boolean saveSuccess = postCGridAccountData(objSaveReq, winningAccount.Id);
                    this.accountsUpdated++;
                } catch (Exception e) {
                    eList.add(e);
                    if (!failedCGridUpdates.contains(winningAccount.Id)) {
                        failedCGridUpdates.add(winningAccount.Id);
                    }
                }
            }
            if (!winningAccount.Merge_Requested_CGrid_Update__c) {
                winningAccount.Merge_Requested_CGrid_Update__c = true;
            }
        }

        System.debug('>>>>>>>>> ERROR LIST');
        System.debug(eList);

        // because we do potentially multiple queries we can't insert logs until all queries are run
        // otherwise the system gets upset that there are callouts being run after data is inserted
        for (Exception e:eList) {
            LoggerUtility.insertLog('AccountIntegrationService','execute',e);
        }

        // update the winning account, then merge the losing account onto the winning one, then finally if a CGrid update was required, unflag it
        
        for (DuplicateRecordSet drs:drsList) {
            System.debug(drs);
            Account winningAccount = BatchAccountMap.get(drs.Winning_Account__c);
            Account losingAccount = BatchAccountMap.get(drs.Losing_Account__c);
            System.debug('>>> WINNING BEFORE UPDATE');
            System.debug(winningAccount.Id);
            System.debug(winningAccount.BillingCity);
            System.debug(winningAccount.PersonMailingCity);
            System.debug(winningAccount.Merge_Requested_CGrid_Update__c);
            System.debug('>>> LOSING BEFORE UPDATE');
            System.debug(losingAccount.Id);
            System.debug(losingAccount.BillingCity);
            System.debug(losingAccount.PersonMailingCity);
            System.debug(losingAccount.Merge_Requested_CGrid_Update__c);
            update winningAccount;
            System.debug('>>>>> MERGE');
            merge winningAccount losingAccount;
            if (winningAccount.Merge_Requested_CGrid_Update__c && !failedCGridUpdates.contains(winningAccount.Id)) {
                winningAccount.Merge_Requested_CGrid_Update__c = false;
                update winningAccount;
            }
        }
        
    }

    // runs at the completion of a batch process, cleanup should be mostly handled by the flow
    public void finish(Database.BatchableContext BC){
        System.debug('FINISH >>>>>>>>>>>>');
        String logMessage = 'Auto Merge process complete. DRS Records processed: '+String.valueOf(processedDRSRecords)+' - Accounts flagged to update in CGrid: '+String.valueOf(accountsToUpdate)+' - Accounts updated in CGrid: '+String.valueOf(accountsUpdated);
        System.debug(logMessage);
        LoggerUtility.insertProcessLog('NF_DuplicateRecordSetAccountAutoMerge', 'finish', logMessage);
    }
}