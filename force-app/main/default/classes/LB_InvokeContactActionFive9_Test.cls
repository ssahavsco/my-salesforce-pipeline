/**
 * Created by mcasella on 10/21/20.
 */

@IsTest
public with sharing class LB_InvokeContactActionFive9_Test {
 
    @isTest
    static void checkContactTest(){
        Id personAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account objAcc = new Account();
            objAcc.FirstName = 'test';
            objAcc.LastName = 'account';
            objAcc.PersonEmail = 'x@y.com';
            objAcc.Type = 'Personal';
            objAcc.RecordTypeId = personAccRecordTypeId;
            insert objAcc;
            
        Account objAcc1 = new Account();
            objAcc1.FirstName = 'TEST';
            objAcc1.LastName = 'ACCOUNT';
            objAcc1.PersonEmail = 'x@y.com';
            objAcc1.Type = 'Personal';
            objAcc1.RecordTypeId = personAccRecordTypeId;
            insert objAcc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'TEST';
        con1.LastName='ACCOUNT';
        con1.Phone='9999999999';
        //con1.AccountId=objAcc.Id;
        con1.Email='x@y.com';
        insert con1;
         
        Contact con2 = new Contact();
        con2.FirstName = 'test123';
        con2.LastName='account12233';
        con2.Phone='99999999991';
        con2.CID__c='123456789';
        con2.Email='X@Yaa.com';
        insert con2;
        
        
        con2.Phone='9999999999';
        update con2;
        
        List<LB_InvokeContactActionFive9.FlowRequestWrapper> inputWrpLst = new List<LB_InvokeContactActionFive9.FlowRequestWrapper>();

        LB_InvokeContactActionFive9.FlowRequestWrapper inputWrp = new LB_InvokeContactActionFive9.FlowRequestWrapper();
        inputWrp.aniNumber = '9999999999';
        
        inputWrpLst.add(inputWrp);
           Id [] fixedSearchResults= new Id[2];
       fixedSearchResults[0] = con2.id;
       fixedSearchResults[1] = con1.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        
         List<List<SObject>> searchList = [FIND :'9999999999' IN PHONE FIELDS Returning Contact(Id, Name, CID__c  ORDER BY LastModifiedDate DESC) ];
         List<Contact> contacts =  (List<Contact>) searchList[0];
        
        system.debug('contacts'+contacts);
        system.debug('contacts'+[Select id from contact where phone = '9999999999']);
        LB_InvokeContactActionFive9.getContact(inputWrpLst);
    }
    
}