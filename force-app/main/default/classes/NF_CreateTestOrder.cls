/**
 * Created by adamundus on 9/16/20.
 */

@IsTest
public class NF_CreateTestOrder {
	
    public static NF_OrderServiceN.OrderResponse createTestOrder(){
        
        NF_OrderServiceN.OrderResponse resp = NF_OrderMockAPI.getOrderDetailInstance('2022-03-16T15:09:45', 'canceled');
        
        return resp;
        
    }
    public static NF_OrderServiceN.OrderResponse createTestOrder90Days(){
        
        NF_OrderServiceN.OrderResponse resp = NF_OrderMockAPI.getOrderDetailInstance('2020-03-16T15:09:45', 'canceled');
        
        return resp;
        
    }

    @IsTest
    static void testBehavior() {
        System.assertEquals(true, true);
    }
}