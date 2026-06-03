public with sharing class NF_CalloutTestPageController {

    @AuraEnabled
    public static String searchOrder(String email){
        return NF_OrderHistoryAPI.searchOrder(email);
    }

    @AuraEnabled
    public static String searchOrder_1(String email, String phone, String zipCode){
        return NF_OrderHistoryAPI.searchOrder(email, phone, zipCode);
    }

    @AuraEnabled
    public static String searchOrderWithLimit(String email, String phone, String zipCode, Integer noOfOrders){
        return NF_OrderHistoryAPI.searchOrderWithLimit(email, phone, zipCode, noOfOrders);
    }

    @AuraEnabled
    public static String orders(String encrypted_auth_token, Integer noOfOrders){
        return JSON.serialize(NF_OrderHistoryAPI.orders(encrypted_auth_token, noOfOrders));
    }

    @AuraEnabled
    public static String orderByIdAndEmail(String orderId,String email){
        return NF_OrderHistoryAPI.orderByIdAndEmail(orderId, email);
    }
}