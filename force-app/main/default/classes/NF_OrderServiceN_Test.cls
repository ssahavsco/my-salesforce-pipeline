@isTest
public with sharing class NF_OrderServiceN_Test {
    
    @isTest
    static void validate(){
        Test.startTest();
        List<String> remorse = NF_OrderServiceN.REMORSE_STATUSES;

        NF_OrderServiceN.APIResponse apiResp = new NF_OrderServiceN.APIResponse();
        NF_OrderServiceN.ListOfOrderResponse looResp = new NF_OrderServiceN.ListOfOrderResponse();
        looResp.orderStatus = 'RETURNED';
        looResp.isInRemorse();
        looResp.hasShipmentStatus('ORDERPLACED');
        looResp.hasShipmentStatus('Test');
        NF_OrderServiceN.Lshipments lshipments = new NF_OrderServiceN.Lshipments();
        lshipments.status = 'ORDERPLACED';
        looResp.shipments = new List<NF_OrderServiceN.Lshipments>{lshipments};
        looResp.isInRemorse();
        looResp.orderStatus = 'ORDERPLACED';
        looResp.isInRemorse();
        looResp.hasShipmentStatus('ORDERPLACED');
        looResp.hasShipmentStatus('Test');

        NF_OrderServiceN.OrderResponse oresp = new NF_OrderServiceN.OrderResponse();
        oresp.orderStatus = 'RETURNED';
        oresp.isInRemorse();
        oresp.hasShipmentStatus('ORDERPLACED');
        oresp.hasShipmentStatus('Test');
        NF_OrderServiceN.shipments shipments = new NF_OrderServiceN.shipments();
        shipments.status = 'ORDERPLACED';
        oresp.shipments = new List<NF_OrderServiceN.shipments>{shipments};
        oresp.isInRemorse();
        oresp.orderStatus = 'ORDERPLACED';
        oresp.isInRemorse();
        oresp.hasShipmentStatus('ORDERPLACED');
        oresp.hasShipmentStatus('Test');

        Test.stopTest();
    }
}