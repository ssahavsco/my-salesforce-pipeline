@isTest
public with sharing class BotLoyaltyExperienceServicesTest {
    @isTest
    static void get_PointBalance_Test(){

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = '12345';
        insert session;

        BotLoyaltyExperienceServices.Input i = new BotLoyaltyExperienceServices.Input();
        // i.chatkey = '12345';
        i.loyaltyId = '14069418859';
        List<BotLoyaltyExperienceServices.Input> input = new List<BotLoyaltyExperienceServices.Input>();
        input.add(i);
        VS_LoyaltyExperienceServicesCalloutsTest.setupData();
        VS_LoyaltyExperienceServicesCalloutsTest.testSuccessGetPointsBalance_BOT();
        BotLoyaltyExperienceServices.get_PointBalance(input);
    }
    @isTest
    static void get_PointBalance_Failure(){

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = '12345';
        insert session;

        BotLoyaltyExperienceServices.Input i = new BotLoyaltyExperienceServices.Input();
        i.chatkey = '12345';
        i.loyaltyId = '14069418859';
        List<BotLoyaltyExperienceServices.Input> input = new List<BotLoyaltyExperienceServices.Input>();
        input.add(i);
        VS_LoyaltyExperienceServicesCalloutsTest.setupData();
        VS_LoyaltyExperienceServicesCalloutsTest.testSuccessGetPointsBalance_BOT_Failure();
        BotLoyaltyExperienceServices.get_PointBalance(input);
    }
}