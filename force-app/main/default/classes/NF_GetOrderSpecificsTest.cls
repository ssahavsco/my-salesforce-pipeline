/**
* Created by adamundus on 9/16/20.
*/

@IsTest
private class NF_GetOrderSpecificsTest {
    static String chatkey = '0Mw';
    @TestSetup public static void setup(){
        
        LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
        LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.Client_Secret__c = 'eJv4s59Hd7Y7lzIjJboqJwhTIVS4';
        LBrandCustomS.Client_ID__c = 'sfccs';
        LBrandCustomS.Live_Agent_Site_Url__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.orderdetails__c = 'orderdetails/v5/orders';
        insert LBrandCustomS;
        
        //chatKey = NF_UtilTest.createMessagingSession();
    }
    @IsTest
    static void testBehaviorForSingleOrder() {
        List<NF_OrderServiceN.OrderResponse> orderList = new List<NF_OrderServiceN.OrderResponse>();
        
        NF_OrderServiceN.OrderResponse orderObj = NF_CreateTestOrder.createTestOrder();
        orderObj.parentOrder = new NF_OrderServiceN.parentOrder();
        orderObj.parentOrder.email = 'test@gmail.com';
        orderObj.parentOrder.itemNumber = 'W033926602';
        orderObj.orderDateTime = '2025-07-18T';
        orderObj.orderStatus = 'canceled';
        orderList.add(orderObj);
        
        String serial = JSON.serialize(orderObj);
        NF_OrderServiceN.OrderResponse orders = (NF_OrderServiceN.OrderResponse) JSON.deserialize(serial, NF_OrderServiceN.OrderResponse.class);
        
        NF_GetOrderSpecifics.Input inp = new NF_GetOrderSpecifics.Input();
        List<NF_GetOrderSpecifics.Input> inputs = new List<NF_GetOrderSpecifics.Input>();
        inp.serializedOrders = JSON.serialize(orderObj);
        inp.order = orderObj;
        inp.chatKey = chatkey;
        inp.orderResponseSize = 1;
        inp.isUserAuthenticated = true;
        inp.chatUserLanguage = 'e_US';
        inputs.add(inp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        List<NF_GetOrderSpecifics.Output> out = NF_GetOrderSpecifics.isClaimProcessed(inputs);
        Test.stopTest();
        System.debug(LoggingLevel.DEBUG,'out[0]>>>'+out);
        System.assertNotEquals(null, out, 'should have value');
        //System.assertEquals(true, out[0].hasParentOrder);
        
    }
    
    @IsTest
    static void testBehaviorForSingleOrder90Days() {
        List<NF_OrderServiceN.OrderResponse> orderList = new List<NF_OrderServiceN.OrderResponse>();
        
        NF_OrderServiceN.OrderResponse orderObj = NF_CreateTestOrder.createTestOrder90Days();
        orderObj.parentOrder = new NF_OrderServiceN.parentOrder();
        orderObj.parentOrder.email = 'test@gmail.com';
        orderObj.parentOrder.itemNumber = 'W033926602';
        orderList.add(orderObj);
        
        String serial = JSON.serialize(orderObj);
        NF_OrderServiceN.OrderResponse orders = (NF_OrderServiceN.OrderResponse) JSON.deserialize(serial, NF_OrderServiceN.OrderResponse.class);
        
        NF_GetOrderSpecifics.Input inp = new NF_GetOrderSpecifics.Input();
        List<NF_GetOrderSpecifics.Input> inputs = new List<NF_GetOrderSpecifics.Input>();
        inp.serializedOrders = JSON.serialize(orderObj);
        inp.order = orderObj;
        inp.chatKey = chatkey;
        inp.orderResponseSize = 1;
        inp.isUserAuthenticated = true;
        inputs.add(inp);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        List<NF_GetOrderSpecifics.Output> out = NF_GetOrderSpecifics.isClaimProcessed(inputs);
        Test.stopTest();
        System.debug(LoggingLevel.DEBUG,'out[0]>>>'+out);
        System.assertNotEquals(null, out, 'should have value');
        //System.assertEquals(true, out[0].hasParentOrder);
        
    }
    @IsTest
    static void testBehaviorForMultipleOrders() {
        NF_OrderServiceN.OrderResponse orderObj = NF_CreateTestOrder.createTestOrder();
        
        List<NF_OrderServiceN.ListOfOrderResponse> orderList = new List<NF_OrderServiceN.ListOfOrderResponse>();
        NF_OrderServiceN.ListOfOrderResponse orderObjItem = new NF_OrderServiceN.ListOfOrderResponse();
        orderObjItem.orderStatus = 'pending';
        orderObjItem.orderNumber = 'W033926602'; //'C300009902';
        orderObjItem.isCancelModifyEligible = true;
        orderObjItem.orderDateTime = '2025-07-18T';
        orderObjItem.orderDate = '2025-07-18';
        orderList.add(orderObjItem);
        
        List<NF_GetOrderSpecifics.Input> inputs = new List<NF_GetOrderSpecifics.Input>();
        NF_GetOrderSpecifics.Input inp = new NF_GetOrderSpecifics.Input();
        inp.serializedOrders = JSON.serialize(orderList);
        inp.order = orderObj;
        inp.listOrder = orderObjItem;
        inp.chatKey = chatkey;
        inp.orderResponseSize = 2;
        inp.isUserAuthenticated = true;
        inp.email = 'test@gmail.com';
        inputs.add(inp);
        
        List<NF_OrderJumpListManipulation.Input> inputList = new List<NF_OrderJumpListManipulation.Input>();
        NF_OrderJumpListManipulation.Input input = new NF_OrderJumpListManipulation.Input();
        input.serializedOrders = JSON.serialize(orderList);
        inputList.add(input);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        List<NF_GetOrderSpecifics.Output> out = NF_GetOrderSpecifics.isClaimProcessed(inputs);
        NF_OrderJumpListManipulation.getManipulatedOrderList(inputList);
        Test.stopTest();
        System.assertNotEquals(null, out, 'should have value');
        //System.assertEquals(false, out[0].hasParentOrder);
    }
    
    @IsTest
    static void testBehaviorForMultipleOrders90Days() {
        NF_OrderServiceN.OrderResponse orderObj = NF_CreateTestOrder.createTestOrder90Days();
        
        List<NF_OrderServiceN.ListOfOrderResponse> orderList = new List<NF_OrderServiceN.ListOfOrderResponse>();
        NF_OrderServiceN.ListOfOrderResponse orderObjItem = new NF_OrderServiceN.ListOfOrderResponse();
        orderObjItem.orderStatus = 'pending';
        orderObjItem.orderNumber = 'W033926602'; //'C300009902';
        orderObjItem.isCancelModifyEligible = true;
        orderObjItem.orderDateTime = '2019-10-21T';
        orderObjItem.orderDate = '2019-10-21';
        orderList.add(orderObjItem);
        
        List<NF_GetOrderSpecifics.Input> inputs = new List<NF_GetOrderSpecifics.Input>();
        NF_GetOrderSpecifics.Input inp = new NF_GetOrderSpecifics.Input();
        chatKey = NF_UtilTest.createMessagingSession();
        inp.serializedOrders = JSON.serialize(orderList);
        inp.order = orderObj;
        inp.listOrder = orderObjItem;
        inp.chatKey = chatkey;
        inp.orderResponseSize = 2;
        inp.isUserAuthenticated = true;
        inp.email = 'test@gmail.com';
        inputs.add(inp);
        
        List<NF_OrderJumpListManipulation.Input> inputList = new List<NF_OrderJumpListManipulation.Input>();
        NF_OrderJumpListManipulation.Input input = new NF_OrderJumpListManipulation.Input();
        input.serializedOrders = JSON.serialize(orderList);
        inputList.add(input);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        List<NF_GetOrderSpecifics.Output> out = NF_GetOrderSpecifics.isClaimProcessed(inputs);
        NF_OrderJumpListManipulation.getManipulatedOrderList(inputList);
        Test.stopTest();
        System.assertNotEquals(null, out, 'should have value');
        //System.assertEquals(false, out[0].hasParentOrder);
    }
}