/**
 * Created by mcasella on 9/21/20.
 */

@IsTest
public with sharing class NF_UpdateBotSessionTest {
    @IsTest
    static void test1() {
        String chatKey = '123';
        String value = 'No Response';

        Test.startTest();

        NF_UpdateBotSessionTest.insertBotSession(chatKey);

        NF_UpdateBotSession.Input input = new NF_UpdateBotSession.Input();
        input.chatKey = chatKey;
        input.field = 'ebotdata__Successful_Resolution__c';
        input.value = 'Yes';
        NF_UpdateBotSession.setField(new List<NF_UpdateBotSession.Input>{
                input
        });
        Test.stopTest();

        ebotdata__Bot_Session__c session = [SELECT Id, ebotdata__Successful_Resolution__c FROM ebotdata__Bot_Session__c];
        System.assertEquals('Yes', session.ebotdata__Successful_Resolution__c, 'should have value');
    }
    
    public static ebotdata__Bot_Session__c insertBotSession(String chatKey){
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = chatKey;
        insert session;
        return session;
    }
}