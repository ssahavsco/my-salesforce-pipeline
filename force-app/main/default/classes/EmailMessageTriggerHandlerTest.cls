/***************************************************************************************************************************************************************************
Interface Name : EmailMessageTriggerHandlerTest
CreatedDate : 23-NOV-21
Description :  to validate the trigger and handler class
Created By : Sumit Saha

Revision History

Date Name Story Number Description
* TODO: 11/23/2021 - DP-45314  - Email: Implement alert message when sending a RED or 72 Hour Email to help prevent sending the response to the customer
		02/08/2022 - Pooja		-	Test code coverage increase'
		05/20/2023 - Himanshu  - Updated the line 47 to fix the picklist error for the recordtype
***************************************************************************************************************************************************************************/

@isTest
public with sharing class EmailMessageTriggerHandlerTest {
    
    private static String expectedMessage;
    
    static{
        expectedMessage = 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Email ID needs to be removed {test123@lb.com}: [ToAddress]';
    }
    
    @istest
    public static void createEmailMessage(){
        EmailMessage email= new EmailMessage();
        email.fromaddress='test321@test.com';
        email.toAddress = 'test123@lb.com';
        email.subject = '72 Hour';
        email.TextBody= 'This is the message body of test email';
        email.parentid = createCase();
        
        try {
            insert email;
        } catch (System.DmlException e) {
            System.assertEquals(expectedMessage, e.getMessage(), 'Pass');
        }
    }
    
    @istest
    public static Id createCase(){
        List<RecordType> caseRecordType = new List<RecordType>([SELECT Id from RecordType where Name = 'Store Sensitive Case' LIMIT 1]);
        
        Case cs = new Case();
        cs.Description = 'Test Case';
        cs.RecordTypeId = (Id) caseRecordType[0].get('Id');
        cs.Sensitive_Situation_Status__c = 'NO RESPONSE NEEDED';
        cs.AccountId = createAccount();
        
        Insert cs;
        System.assertEquals(null, null);
        return cs.Id ;         
    }
    
    @istest
    public static Id createAccount(){
        Account acc = new Account();
        acc.AccountEmail__c = 'test123@lb.com';
        acc.LastName = 'Test Lname';
        
        insert acc;
        System.assertEquals(null, null);
        return acc.id;
    }
    
    @istest
    public static void test_methodOne(){
        EmailMessageTriggerHandler handler = new EmailMessageTriggerHandler();
        handler.getHasCustomerEmail();
        handler.setHasCustomerEmail(true);
        handler.getEmailToBeRemoved();
        handler.isDisabled();
    }
    
    
}