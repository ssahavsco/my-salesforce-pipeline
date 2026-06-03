@isTest
public with sharing class BotLoyaltyServiceTest {

    @isTest
    static void callOutLoyaltyService_Test(){

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = '12345';
        insert session;

        LoyaltyAccountIntegrationTest.loyaltyDetailsLookupTest();

        BotLoyaltyService.Input i = new BotLoyaltyService.Input();
        i.chatkey = '12345';
        i.email = 'MSTESTER1AAA1111@VSS-US.COM';
        List<BotLoyaltyService.Input> input = new List<BotLoyaltyService.Input>();
        input.add(i);

        BotLoyaltyService.callOutLoyaltyService(input);
    }
    @isTest
    static void callOutLoyaltyService_Test_multiple_records(){

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = '12345';
        session.Customer_Full_Name__c = 'Test';
        session.Loyalty_Id__c = 'Test';
        session.Loyalty_Status__c = 'Test';

        List<ebotdata__Bot_Session__c> lst = new List<ebotdata__Bot_Session__c>();
        lst.add(session);
        
        insert lst;

        LoyaltyAccountIntegrationTest.loyaltyDetailsLookupTest();

        BotLoyaltyService.Input i = new BotLoyaltyService.Input();
        i.chatkey = '12345';
        i.email = 'MSTESTER1AAA1111@VSS-US.COM';
        List<BotLoyaltyService.Input> input = new List<BotLoyaltyService.Input>();
        input.add(i);

        BotLoyaltyService.callOutLoyaltyService(input);
    }


}