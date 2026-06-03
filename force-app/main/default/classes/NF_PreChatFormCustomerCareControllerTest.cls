/**
 * Created by mcasella on 10/21/20.
 */

@IsTest
public with sharing class NF_PreChatFormCustomerCareControllerTest {

    @IsTest
    public static void checkAvailability(){
        System.assertNotEquals(Null, NF_PreChatFormCustomerCareController.checkAgentAvailable('test@testing.com','Testing page url'));
    }
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
        //con1.AccountId=objAcc.Id;
        con1.Email='x@y.com';
        insert con1;
        
        /*Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(con1, insertDML);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = sr.id, RecordId=con1.id);
        insert dup;*/
        
        Contact con2 = new Contact();
        con2.FirstName = 'test';
        con2.LastName='account';
        con2.Email='X@Y.com';
        //con2.AccountId=objAcc1.Id;
        //insert con2;
        
        NF_PreChatFormCustomerCareController.checkContact('Test','account','x@y.com');
    }

}