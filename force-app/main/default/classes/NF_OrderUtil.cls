/**
 * Created by mcasella on 10/12/20.
 */

public with sharing class NF_OrderUtil {
    //Calculates the shipping status of the order by interrogating the status of each shipment and checking its priority
    //Also, determines if an order is in remorse
    @TestVisible
    private static String getOrderStatusForMenuItem(NF_OrderServiceN.ListOfOrderResponse order){
        String calculatedOrderStatus = '';

        if(order != null) {
            calculatedOrderStatus = String.isNotEmpty(order.orderStatus) ? order.orderStatus : '';

            try {
                if (order != null && order.shipments != null) {
                    List<String> shipmentStatuses = new List<String>();
                    //grab all shipment statuses for the order
                    for (NF_OrderServiceN.Lshipments shipment : order.shipments) {
                        shipmentStatuses.add(shipment.status);
                    }

                    calculatedOrderStatus = calculateShipmentStatus(shipmentStatuses);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG,'NF_OrderUtil.getOrderStatusForMenuItem: error=' + e.getMessage());
            }
        }

        System.debug(LoggingLevel.DEBUG,'NF_OrderUtil.getOrderStatusForMenuItem: calculatedOrderStatus=' + calculatedOrderStatus);
        return calculatedOrderStatus;
    }

//    @TestVisible
//    private static String getOrderStatusForMenuItem(NF_OrderServiceN.OrderResponse order){
//        String calculatedOrderStatus = '';
//
//        if(order != null) {
//            calculatedOrderStatus = String.isNotEmpty(order.orderStatus) ? order.orderStatus : '';
//
//            try {
//                if (order != null && order.shipments != null) {
//                    List<String> shipmentStatuses = new List<String>();
//                    //grab all shipment statuses for the order
//                    for (NF_OrderServiceN.shipments shipment : order.shipments) {
//                        shipmentStatuses.add(shipment.status);
//                    }
//
//                    calculatedOrderStatus = calculateShipmentStatus(shipmentStatuses);
//                }
//            } catch (Exception e) {
//                System.debug(LoggingLevel.DEBUG,'NF_AuthUserOrderLookup.getOrderStatusFromShipments: error=' + e.getMessage());
//            }
//        }
//
//        return calculatedOrderStatus;
//    }

    @TestVisible
    private static String calculateShipmentStatus(List<String> shipmentStatuses){
        //get the lowest ranking priority
        NF_Order_Status_Shipment_Priority__mdt[] shipmentPriorities = [SELECT Id, Shipment_Status__c, Priority__c
                                                                        FROM NF_Order_Status_Shipment_Priority__mdt
                                                                        WHERE Shipment_Status__c IN :shipmentStatuses
                                                                        ORDER BY Priority__c ASC LIMIT 1];
        System.debug(LoggingLevel.DEBUG,'NF_AuthUserOrderLookup.getOrderStatusFromShipments: shipmentPriorities='+shipmentPriorities);

        return shipmentPriorities.size() > 0 ? shipmentPriorities[0].Shipment_Status__c : '';
    }

    public static NF_OrderServiceN.ListOfOrderResponse formatOrderForMenu(NF_OrderServiceN.ListOfOrderResponse order) {
        if (order != null) {
            //DP-32073: auth orders list not returning orderTotal
            //eachOrder.orderPlaceholder1 = eachOrder.orderSummary != null ? eachOrder.orderSummary.orderTotal + ' ' : '';

            order.orderPlaceholder1 = 'Order on ';
            order.orderPlaceholder2 = order.orderDate;
            String calculatedOrderStatus = getOrderStatusForMenuItem(order);
            order.orderPlaceholder3 = String.isNotEmpty(calculatedOrderStatus) ? ' (' + calculatedOrderStatus + ')' : '';
        }

        return order;
    }
}