@isTest(SeeAllData = false)
public class NF_OrderMockAPITest {
    static testMethod void getOrderDetail() {
        
        String email = '123@gmail.com';
        String orderid = 'ADFS001';
        String zip = '001';
        String authToken = '001stpjufjuit4908fgd9';
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
            // NF_APIUtil.getOrderDetail(email, orderid);
            // NF_APIUtil.orderByIdAndEmail(email, orderid);
            // NF_APIUtil.searchOrder(email);
            // NF_APIUtil.searchOrder(email, orderid,zip);
            // NF_APIUtil.getOrderDetailById();
            // NF_APIUtil.getOrderDetailByOrderType();
            // NF_APIUtil.getOrderDetailByBrand();
            // NF_APIUtil.setOrder();
            //NF_APIUtil.orders(authToken);
       
        Test.stopTest();
    }
}