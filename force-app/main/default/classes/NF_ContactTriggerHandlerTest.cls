/**
 *  @description NF Contact Trigger - clean up phone number formats for SCV search
 *  @author 	 NeuraFlash
 *  @date        2021-01-05
 */
@IsTest
public with sharing class NF_ContactTriggerHandlerTest {
    static testMethod void ContactPhoneUpdate_Insert(){
        Contact c = new Contact(FirstName='First', LastName='Last', Email='test@test.com', Phone='222-222-2222');
        test.startTest();
        insert c;
        test.stopTest();
    }

    static testMethod void ContactPhoneUpdate_Update(){
        Contact c = new Contact(FirstName='First', LastName='Last', Email='test@test.com', Phone='222-222-2222');
        insert c;
        test.startTest();
        c.Phone = '333.333.2222';
        c.Phone_Search_Reset__c = true;
        update c;
        test.stopTest();
    }

    static testMethod void cleanInsertTest() {
        test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='test@test.com', Phone='222-222-2222');
        List<Contact> newList = new List<Contact>();
        newList.add(c);
        insert newList;
        test.stopTest();
    }

    static testMethod void cleanUpdateTest() {
        test.startTest();
        Contact c = new Contact(FirstName='First', LastName='Last', Email='test@test.com', Phone='222-222-2222');
        List<Contact> newList = new List<Contact>();
        newList.add(c);
        insert newList;


        Contact oldC = new Contact(FirstName='First', LastName='Last', Email='test@test.com', Phone='222-222-2223', id = newList[0].id);
        List<Contact> oldList = new List<Contact>();
	 
        oldList.add(oldC);
        update oldList;
        test.stopTest();

    }
}