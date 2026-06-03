/**
 * Created by adamundus on 9/15/20.
 */

@IsTest
private class NF_DisplayRecentOrdersTest {
    static String chatkey = 'abc';

    @IsTest
    static void testBehavior() {
        NF_OrderHistoryService.OrderHistoryResponse o = new NF_OrderHistoryService.OrderHistoryResponse();
        o.orderNumber = '1245';
        o.orderDate = '09/15/20';
        o.isCancelModifyEligible = false;
        o.orderStatus = 'shipped';
        NF_OrderHistoryService.Shipment s = new NF_OrderHistoryService.Shipment();
        NF_OrderHistoryService.Product p = new NF_OrderHistoryService.Product();
        p.shortDescription = 'cute top';
        p.image = 'someurl';
        List<NF_OrderHistoryService.Product> products = new List<NF_OrderHistoryService.Product>();
        products.add(p);
        s.products = products;
        List<NF_OrderHistoryService.Shipment> shipments = new List<NF_OrderHistoryService.Shipment>();
        shipments.add(s);
        o.shipments = shipments;
        List<NF_OrderHistoryService.OrderHistoryResponse> orderList = new List<NF_OrderHistoryService.OrderHistoryResponse>();
        orderList.add(o);
        List<String> inp = new List<String>();
        inp.add(JSON.serialize(orderList));

        Test.startTest();
        List<List<String>> resp = NF_DisplayRecentOrders.displayRecentOrderMenu(inp);
        Test.stopTest();

        System.debug(resp);
        System.assertNotEquals(0, resp.size(), 'should have value');
    }
}