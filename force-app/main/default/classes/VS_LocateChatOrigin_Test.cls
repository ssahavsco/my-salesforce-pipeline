/**
 * Created by Sumit Saha | Date: 11-Nov-2024
 */ 


@isTest
public class VS_LocateChatOrigin_Test {
    @isTest   
    public static void getChatCountry_Test(){
        String sessionId = NF_UtilTest.createMessagingSession();
        MessagingSession session = [Select Location__c, Language_Code__c From MessagingSession where Id =: sessionId];
        session.Location__c = 'Bartlesville, OK, United States';
        session.Language_Code__c = 'en_US';
        update session;
        
        List<VS_LocateChatOrigin.Input> input = new List<VS_LocateChatOrigin.Input>();
        VS_LocateChatOrigin.Input i = new VS_LocateChatOrigin.Input();
        i.chatkey = sessionId;
        input.add(i);
        VS_LocateChatOrigin.getChatCountry(input);
    }
    
    @isTest   
    public static void getNullChatCountry_Test(){
        String sessionId = NF_UtilTest.createMessagingSession();       
        List<VS_LocateChatOrigin.Input> input = new List<VS_LocateChatOrigin.Input>();
        VS_LocateChatOrigin.Input i = new VS_LocateChatOrigin.Input();
        i.chatkey = sessionId;
        input.add(i);
        VS_LocateChatOrigin.getChatCountry(input);
    }
}