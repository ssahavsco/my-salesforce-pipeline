/** International Project to Integrate with GE Service
 *  Created By:  ssaha@victoria.com | Date: 19-APR-24
 *  Modified By:  
 */


@isTest
public with sharing class VS_GetOrderTypeTest {
    @isTest
    public static void getOrderTypeGE(){
        VS_GetOrderType.getOrderType('G000002674');
    }
    @isTest
    public static void getOrderTypeHome(){
        VS_GetOrderType.getOrderType('T000002674');
    }
    @isTest
    public static void getOrderTypeEshop(){
        VS_GetOrderType.getOrderType('E7412589933');
        VS_GetOrderType.getOrderType('XXXXXX');
    }

    @isTest
    public static void processOrderNumberTest(){
        VS_GetOrderType.Input i = new VS_GetOrderType.Input();
        i.orderNumber = 'G000002674';
        i.chatkey = NF_UtilTest.createMessagingSession();
        Messaging_Insight__c msgInsight = NF_UtilTest.insertMessagingInsight(i.chatkey);
        MessagingSession msgSession = [Select Location__c From MessagingSession Where Id =: i.chatKey];
        msgSession.Location__c = 'SS, Delhi, India';
        update msgSession;
        List<VS_GetOrderType.Input> input = new List<VS_GetOrderType.Input>();
        input.add(i);
        VS_GetOrderType.processOrderNumber(input);
    }
    
    
    @isTest
    public static void processTikTokOrderNumberTest(){
        VS_GetOrderType.Input i = new VS_GetOrderType.Input();
        i.orderNumber = '977148723765088759';
        i.chatkey = NF_UtilTest.createMessagingSession();
        Messaging_Insight__c msgInsight = NF_UtilTest.insertMessagingInsight(i.chatkey);
        MessagingSession msgSession = [Select Location__c From MessagingSession Where Id =: i.chatKey];
        msgSession.Location__c = 'SS, Delhi, India';
        update msgSession;
        List<VS_GetOrderType.Input> input = new List<VS_GetOrderType.Input>();
        input.add(i);
        VS_GetOrderType.processOrderNumber(input);
    }
    
    
        
    @isTest
    public static void processTOrderNumberTest(){
        VS_GetOrderType.Input i = new VS_GetOrderType.Input();
        VS_GetOrderType.getOrderType('T');
        VS_GetOrderType.getOrderType('R');
        VS_GetOrderType.getOrderType('H');
        VS_GetOrderType.getOrderType('K');
    }
    
  
    
}