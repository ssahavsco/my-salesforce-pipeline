/**
 * Created by mcasella on 10/12/20.
 */

@IsTest
public with sharing class NF_OrderUtilTest {

    @IsTest
    static void getStatusFromShipments(){
        NF_OrderServiceN.ListOfOrderResponse order = new NF_OrderServiceN.ListOfOrderResponse();
        order.shipments = new List<NF_OrderServiceN.Lshipments>();

        NF_OrderServiceN.Lshipments shipment1 = new NF_OrderServiceN.Lshipments();
        order.shipments.add(createShipment('Canceled'));//priority 10
        order.shipments.add(createShipment('Returned')); //priority 1
        order.shipments.add(createShipment('a fake status')); //no priority
        order.shipments.add(createShipment('Shipped')); //priority 3

        String returnedStatus = NF_OrderUtil.getOrderStatusForMenuItem(order);
        System.assertEquals('Returned', returnedStatus, 'should have correct status');
    }

    static NF_OrderServiceN.Lshipments createShipment(String status){
        NF_OrderServiceN.Lshipments shipment = new NF_OrderServiceN.Lshipments();
        shipment.status = status;
        return shipment;
    }

    @IsTest
    static void orderStatusCompare(){
        System.assertEquals(true, NF_OrderServiceN.compareOrderStatus('Order Placed', new List<String>{'ORDERPLACED'}));
        System.assertEquals(true, NF_OrderServiceN.compareOrderStatus(' back ordered ', new List<String>{'ORDERPLACED', 'BACKORDERED'}));
        System.assertEquals(false, NF_OrderServiceN.compareOrderStatus('BaCkO rderED1', new List<String>{'ORDERPLACED', 'BACKORDERED'}));
    }
}