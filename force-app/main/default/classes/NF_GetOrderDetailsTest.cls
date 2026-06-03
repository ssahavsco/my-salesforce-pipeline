/**
 * Created by adamundus on 9/15/20.
 */

@IsTest
private class NF_GetOrderDetailsTest {

    static String chatkey = 'abc';
    @IsTest
    static void testBehavior() {
        NF_OrderServiceN.OrderResponse orderResponse = new NF_OrderServiceN.OrderResponse();

        List<NF_OrderServiceN.Shipments> shipmentObjLst = new List<NF_OrderServiceN.Shipments>();
        NF_OrderServiceN.Shipments shipmentObj = new NF_OrderServiceN.Shipments();
        shipmentObj.status = 'Pending';
        shipmentObj.StatusDate = new NF_OrderServiceN.StatusDate();
        shipmentObj.StatusDate.month = 05;
        shipmentObj.StatusDate.day = 05;
        shipmentObj.StatusDate.year = 2020;
        shipmentObjLst.add(shipmentObj);
        
        orderResponse.shipments = shipmentObjLst;
        orderResponse.orderNumber = 'W033926602';
        orderResponse.parentOrder = new NF_OrderServiceN.parentOrder();
         orderResponse.parentOrder.email = 'test@gmail.com';
         orderResponse.parentOrder.itemNumber = 'W033926602';
        orderResponse.orderStatus = 'Pending';
        orderResponse.orderSummary = new NF_OrderServiceN.orderSummary();
        orderResponse.orderSummary.merchandiseSubTotal = '$225.00';
        orderResponse.orderSummary.orderTotal = '$241.88';
        orderResponse.orderSummary.salesTax = '$16.88';
        orderResponse.orderSummary.shippingHandling = '$0.00';
        orderResponse.orderSummary.isRefundTotal = false;
        orderResponse.orderSummary.showTax = true; 
        
        orderResponse.orderDate = new NF_OrderServiceN.orderDate();
        orderResponse.orderDate.month = 02;
        orderResponse.orderDate.day= 02;
        orderResponse.orderDate.year = 2020;
            
        List<NF_OrderServiceN.Payments> payments = new List<NF_OrderServiceN.Payments>();
        NF_OrderServiceN.Payments paymnt = new NF_OrderServiceN.Payments();
        paymnt.paymentType = 'visa';
        paymnt.itemNumber = '0119';
        paymnt.amount = '$91.88';
        payments.add(paymnt);    
        orderResponse.payments = payments;
        
         List<NF_OrderServiceN.Shipments> shipmentList = new  List<NF_OrderServiceN.Shipments>();
        NF_OrderServiceN.Shipments shipmnt = new NF_OrderServiceN.Shipments();
        shipmnt.status = 'Pending';
        shipmnt.StatusDate = new NF_OrderServiceN.StatusDate();
        shipmnt.StatusDate.month = 05;
        shipmnt.StatusDate.day = 05;
        shipmnt.StatusDate.year = 2020;
        
        List<NF_OrderServiceN.Payments> paymentList2 = new List<NF_OrderServiceN.Payments>();
        paymnt.amount = '5465';
        paymnt.itemNumber = '4659';
        paymnt.paymentType = 'COD';
        paymentList2.add(paymnt);    
        
        List<NF_OrderServiceN.LineItems> lineItemList = new List<NF_OrderServiceN.LineItems>();
        NF_OrderServiceN.LineItems lineitm = new NF_OrderServiceN.LineItems();
        lineitm.family = 'Very Sexy';
        lineitm.isAvailable = false;
        lineitm.status = 'Pending';
        lineitm.variantId = '1BS54';
        
        
        lineitm.quantity = new NF_OrderServiceN.Quantity();
        lineitm.quantity.selected = 05; 
        lineitm.price = new NF_OrderServiceN.Price();
        lineitm.price.unitPrice =  new NF_OrderServiceN.UnitPrice();
        lineitm.price.unitPrice.originalPrice = '02524';
        lineitm.price.totalPrice = new NF_OrderServiceN.TotalPrice();
        lineitm.price.totalPrice.originalPrice = '2545';
        lineitm.price.priceType = 'realPrice';
        
        NF_OrderServiceN.StatusDate statusDateForLin   = new NF_OrderServiceN.StatusDate();
        statusDateForLin.month = 05;
        statusDateForLin.day = 05;
        statusDateForLin.year = 2020;
        lineitm.statusDate = statusDateForLin;
        
        NF_OrderServiceN.Attributes attribute = new NF_OrderServiceN.Attributes();
        attribute.choice =  new NF_OrderServiceN.Choice();
        attribute.choice.value = 'armani';
        attribute.size1 = new NF_OrderServiceN.Size1();
        attribute.size1.label = 'length';
        attribute.size1.value = '50cm';
        lineitm.attributes = attribute;
        lineItemList.add(lineitm);
        
        shipmnt.lineItems = lineItemList;
        shipmnt.address = new NF_OrderServiceN.Address();
        shipmnt.address.streetAddress1 = 'mansarovar';
        shipmentList.add(shipmnt);
        orderResponse.shipments = shipmentList;
        
        List<NF_GetOrderDetails.Input> inputs = new List<NF_GetOrderDetails.Input>();
        NF_GetOrderDetails.Input inp = new NF_GetOrderDetails.Input();
        inp.chatKey = chatkey;
        inp.serializedOrder = JSON.serialize(orderResponse);
        //inp.shipments = orderResponse.shipments;

        inputs.add(inp);
		 Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        Test.startTest();
        List<NF_GetOrderDetails.Output> out = NF_GetOrderDetails.getOrderDetails(inputs);
        Test.stopTest();
        
        //System.assertEquals(orderResponse.shipments, out[0].shipments);
        System.assertEquals(false, out[0].isClaimProcessed, 'should have false value');

    }
}