/*****************************************************************************************************@@
Class Name     :  NF_DynamicCarouselContentFactoryTest
Purpose        :  Class to serialize order api response for auth customer.(used by chatbot)
History:
-------
VERSION  AUTHOR                 DATE                	DETAIL                      					TICKET REFERENCE/ NO.
1.       adamundus             09/16/2020             Original Version             									-
2.       Manishi               09/27/2021            Modifying test class for 'canceled' status condition        DP-48512
      
*********************************************************************************************************/
@IsTest
private class NF_DynamicCarouselContentFactoryTest {
    @IsTest
    static void testBehavior() {

        NF_OrderServiceN.OrderResponse oderResponseWithCanc = NF_CreateTestOrder.createTestOrder();
        oderResponseWithCanc.orderStatus = 'CANCELLED';
        List<NF_OrderServiceN.cancelled> cancellOrderList =    new  List<NF_OrderServiceN.cancelled>();
        NF_OrderServiceN.cancelled  cancelOrder = new NF_OrderServiceN.cancelled();
        cancelOrder.family = 'Victorias Secret' ;	
        cancelOrder.name = 'Very Sexy For Him Cologne' ;	
        cancelOrder.variantId = '20031804' ;	
        cancelOrder.productImage = null;	
        cancelOrder.swatchImage = 'cancelled'  ;
        cancelOrder.isAvailable = true  ;
        cancelOrder.status = 'cancelled' ;	
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
        cancelOrder.quantity = quantityData;
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
        cancelOrder.statusDate = stadate;
        cancellOrderList.add(cancelOrder);
        oderResponseWithCanc.cancelled = cancellOrderList;
        Test.startTest();
        String responseValueWithCan = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithCanc, true, '');
        oderResponseWithCanc.cancelled[0].statusDate = null;
        String responseValueWithCan2 = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithCanc, false, '');
        System.assertNotEquals(null, responseValueWithCan, 'should have value');
        Test.stopTest();

    }
     @IsTest
    static void testBehaviorForRetunType(){
        NF_OrderServiceN.OrderResponse oderResponseWithRetu= NF_CreateTestOrder.createTestOrder();
        oderResponseWithRetu.orderStatus = 'RETURNED';
        oderResponseWithRetu.shipments = null;
		NF_OrderServiceN.returns returnData = new NF_OrderServiceN.returns();
        List<NF_OrderServiceN.lineItems> lineItemList = new List<NF_OrderServiceN.lineItems>();
        NF_OrderServiceN.lineItems lineItem = new NF_OrderServiceN.lineItems();
        NF_OrderServiceN.price price = new NF_OrderServiceN.price();
        NF_OrderServiceN.totalPrice totalPrice = new NF_OrderServiceN.totalPrice();
        totalPrice.salePrice = '$12.88';
        price.totalPrice = totalPrice;
        lineItem.family = 'Very Sexy';
        lineItem.name = 'Bombshell Add-2-Cup Push-Up Bra ';
        lineItem.variantId = '22818999';
        lineItem.productImage = null;
        lineItem.isAvailable = true;
        lineItem.status = 'returned';
        lineItem.price = price;
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
        lineItem.quantity = quantityData;
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
		lineItem.statusDate = stadate;
        lineItemList.add(lineItem);
        returnData.lineItems = lineItemList;
        oderResponseWithRetu.returns = returnData;
        Test.startTest();
        String responseValueWithRetu = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, true,  '');
        String responseValueWithRetu2 = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, false, '');
        Test.stopTest();
        System.assertNotEquals(null, responseValueWithRetu, 'should have value');
    }
    @IsTest
    static void testBehaviorForDSSRetunType(){
        NF_OrderServiceN.OrderResponse oderResponseWithRetu= NF_CreateTestOrder.createTestOrder();
        oderResponseWithRetu.orderNumber = 'D000000000';
        oderResponseWithRetu.orderStatus = 'RECEIVED';
        oderResponseWithRetu.shipments = null;
		NF_OrderServiceN.returns returnData = new NF_OrderServiceN.returns();
        List<NF_OrderServiceN.lineItems> lineItemList = new List<NF_OrderServiceN.lineItems>();
        NF_OrderServiceN.lineItems lineItem = new NF_OrderServiceN.lineItems();
        NF_OrderServiceN.price price = new NF_OrderServiceN.price();
        NF_OrderServiceN.totalPrice totalPrice = new NF_OrderServiceN.totalPrice();
        totalPrice.salePrice = '$12.88';
        price.totalPrice = totalPrice;
        lineItem.family = 'Very Sexy';
        lineItem.name = 'Bombshell Add-2-Cup Push-Up Bra ';
        lineItem.variantId = '22818999';
        lineItem.productImage = null;
        lineItem.isAvailable = true;
        lineItem.status = 'returned';
        lineItem.price = price;
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
        lineItem.quantity = quantityData;
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
		lineItem.statusDate = stadate;
        lineItemList.add(lineItem);
        returnData.lineItems = lineItemList;
        oderResponseWithRetu.returns = returnData;
        Test.startTest();
        String responseValueWithRetu = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, true,  '');
        oderResponseWithRetu.orderStatus = 'PENDING RETURN';
        String responseValueWithRetu2 = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, false, '');
        oderResponseWithRetu.orderStatus = 'CARRIER SCANNED';
        String responseValueWithRetu3 = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, true,  '');
        oderResponseWithRetu.orderStatus = 'PENDING APPROVAL';
        String responseValueWithRetu4 = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, false, '');
        oderResponseWithRetu.orderStatus = 'RETURNED';
        String responseValueWithRet5 = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithRetu, true,  '');
        Test.stopTest();
        System.assertNotEquals(null, responseValueWithRetu, 'should have value');
    }
    @IsTest
    static void testBehaviorForOtherType(){
        NF_OrderServiceN.OrderResponse oderResponseWithOther= NF_CreateTestOrder.createTestOrder();
        /* start added cancelled node to the order response DP-48512 */
        List<NF_OrderServiceN.cancelled> cancelledList = new List<NF_OrderServiceN.cancelled>();
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
		NF_OrderServiceN.cancelled cancelled = new NF_OrderServiceN.cancelled();
        cancelled.family = 'Victorias Secret';
        cancelled.name = 'sxsxsxsx';
        cancelled.quantity = quantityData;
        cancelled.statusDate = stadate;
        cancelled.productImage = null;
        cancelledList.add(cancelled);
        oderResponseWithOther.cancelled = cancelledList;
        /* end added cancelled node to the order response DP-48512 */
        Test.startTest();
         String responseValueWithOther = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithOther, true, 'R');
        Test.stopTest();
        System.assertNotEquals(null, responseValueWithOther, 'should have value');
    }
    @IsTest
    static void testBehaviorForOtherTypeForUnouthUser(){
        NF_OrderServiceN.OrderResponse oderResponseWithOther= NF_CreateTestOrder.createTestOrder();
        List<NF_OrderServiceN.shipments> shipmantList = new List<NF_OrderServiceN.shipments>();
        NF_OrderServiceN.shipments shipmantData = new NF_OrderServiceN.shipments(); 
         NF_OrderServiceN.shipments shipmantData2 = new NF_OrderServiceN.shipments(); 
        List<NF_OrderServiceN.lineItems> lineItemList = new List<NF_OrderServiceN.lineItems>();
        List<NF_OrderServiceN.cancelled> cancelledList = new List<NF_OrderServiceN.cancelled>();
        NF_OrderServiceN.lineItems lineItem = new NF_OrderServiceN.lineItems();
        lineItem.family = 'Very Sexy';
        lineItem.name = 'Bombshell Add-2-Cup Push-Up Bra ';
        lineItem.variantId = '22818999';
        lineItem.productImage = null;
        lineItem.isAvailable = true;
        lineItem.status = 'returned';
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
        lineItem.quantity = quantityData;
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
		lineItem.statusDate = stadate;

        NF_OrderServiceN.attributes attributeData = new NF_OrderServiceN.attributes();

        NF_OrderServiceN.sendDate sendDateData = new NF_OrderServiceN.sendDate();
        sendDateData.day = 10;
        sendDateData.month = 3;
        sendDateData.year = 2020;
        attributeData.sendDate = sendDateData;
        lineItem.attributes = attributeData;
        NF_OrderServiceN.price price = new NF_OrderServiceN.price();
        NF_OrderServiceN.totalPrice toPrice = new NF_OrderServiceN.totalPrice();
        toPrice.originalPrice = '200';
        price.totalPrice = toPrice;
        lineItem.price = price;
        lineItemList.add(lineItem);
        shipmantData.lineItems =   lineItemList ;
		shipmantData2.lineItems =   lineItemList ;
        shipmantData.status = 'orderPlaced';
       	shipmantData2.status = 'orderPlaced';
		shipmantData.statusDate = stadate;
        shipmantData2.statusDate = stadate;
        shipmantList.add(shipmantData);
        shipmantList.add(shipmantData2);
        oderResponseWithOther.shipments = shipmantList;
        /* start added cancelled node to the order response DP-48512 */
        NF_OrderServiceN.cancelled cancelled = new NF_OrderServiceN.cancelled();
        cancelled.family = 'Victorias Secret';
        cancelled.name = 'sxsxsxsx';
        cancelled.quantity = quantityData;
        cancelled.statusDate = stadate;
        cancelled.productImage = null;
        cancelledList.add(cancelled);
        oderResponseWithOther.cancelled = cancelledList;
        /* end added cancelled node to the order response DP-48512 */
        Test.startTest();
        String responseValueWithOther = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(oderResponseWithOther, false,  '');
        Test.stopTest();
        System.assertNotEquals(null, responseValueWithOther, 'should have value');
    }

    @IsTest
    static void testReturn(){
        NF_OrderServiceN.OrderResponse oderResponseWithRetu= NF_CreateTestOrder.createTestOrder();
        oderResponseWithRetu.orderStatus = 'RETURNED';
        oderResponseWithRetu.orderNumber = 'D000000000';
        oderResponseWithRetu.shipments = new List<NF_OrderServiceN.shipments>();
        oderResponseWithRetu.orderDate = new NF_OrderServiceN.orderDate();
        oderResponseWithRetu.orderDate.day = 1;
        oderResponseWithRetu.orderDate.month = 10;
        oderResponseWithRetu.orderDate.year = 2023;

        NF_OrderServiceN.returns returnData = new NF_OrderServiceN.returns();
        List<NF_OrderServiceN.lineItems> lineItemList = new List<NF_OrderServiceN.lineItems>();
        NF_OrderServiceN.lineItems lineItem = new NF_OrderServiceN.lineItems();
        NF_OrderServiceN.price price = new NF_OrderServiceN.price();
        NF_OrderServiceN.totalPrice totalPrice = new NF_OrderServiceN.totalPrice();
        totalPrice.salePrice = '$12.88';
        price.totalPrice = totalPrice;
        lineItem.family = 'Very Sexy';
        lineItem.name = 'Bombshell Add-2-Cup Push-Up Bra ';
        lineItem.variantId = '22818999';
        lineItem.productImage = null;
        lineItem.isAvailable = true;
        lineItem.status = 'returned';
        lineItem.price = price;
        lineItem.attributes = new NF_OrderServiceN.attributes();
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
        lineItem.quantity = quantityData;
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
        lineItem.statusDate = stadate;
        lineItemList.add(lineItem);
        returnData.lineItems = lineItemList;
        oderResponseWithRetu.returns = returnData;
        NF_OrderServiceN.shipments s = new NF_OrderServiceN.shipments();
        s.status = 'RETURNED';
        s.lineItems = new List<NF_OrderServiceN.lineItems>{lineItem};
        s.trackingNumber = '120';
        s.statusDate = new NF_OrderServiceN.statusDate();
        oderResponseWithRetu.shipments.add(s);
        Test.startTest();
        String responseValueWithRetu = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, true,  'RETURNED');
        String responseValueWithRetu1 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, true,  'PENDING RETURN');
        String responseValueWithRetu2 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, true,  'PENDING APPROVAL');
        String responseValueWithRetu3 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, true,  'RECEIVED');
        String responseValueWithRetu4 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, true,  'CARRIER SCANNED');
        Test.stopTest();
        System.assertNotEquals(null, responseValueWithRetu, 'should have value');
    }
    
    @IsTest
    static void testReturnUnAuth(){
        NF_OrderServiceN.OrderResponse oderResponseWithRetu= NF_CreateTestOrder.createTestOrder();
        oderResponseWithRetu.orderStatus = 'RETURNED';
        oderResponseWithRetu.orderNumber = 'D000000000';
        oderResponseWithRetu.shipments = new List<NF_OrderServiceN.shipments>();
        oderResponseWithRetu.orderDate = new NF_OrderServiceN.orderDate();
        oderResponseWithRetu.orderDate.day = 1;
        oderResponseWithRetu.orderDate.month = 10;
        oderResponseWithRetu.orderDate.year = 2023;

        NF_OrderServiceN.returns returnData = new NF_OrderServiceN.returns();
        List<NF_OrderServiceN.lineItems> lineItemList = new List<NF_OrderServiceN.lineItems>();
        NF_OrderServiceN.lineItems lineItem = new NF_OrderServiceN.lineItems();
        NF_OrderServiceN.price price = new NF_OrderServiceN.price();
        NF_OrderServiceN.totalPrice totalPrice = new NF_OrderServiceN.totalPrice();
        totalPrice.salePrice = '$12.88';
        price.totalPrice = totalPrice;
        lineItem.family = 'Very Sexy';
        lineItem.name = 'Bombshell Add-2-Cup Push-Up Bra ';
        lineItem.variantId = '22818999';
        lineItem.productImage = null;
        lineItem.isAvailable = true;
        lineItem.status = 'returned';
        lineItem.price = price;
        lineItem.attributes = new NF_OrderServiceN.attributes();
        NF_OrderServiceN.quantity quantityData = new NF_OrderServiceN.quantity();
        quantityData.selected = 3;
        lineItem.quantity = quantityData;
        NF_OrderServiceN.statusDate stadate = new NF_OrderServiceN.statusDate();
        stadate.day = 2;
        stadate.month = 3;
        stadate.year = 2020;
        lineItem.statusDate = stadate;
        lineItemList.add(lineItem);
        returnData.lineItems = lineItemList;
        oderResponseWithRetu.returns = returnData;
        NF_OrderServiceN.shipments s = new NF_OrderServiceN.shipments();
        s.status = 'RETURNED';
        s.lineItems = new List<NF_OrderServiceN.lineItems>{lineItem};
        s.trackingNumber = '120';
        s.statusDate = new NF_OrderServiceN.statusDate();
        oderResponseWithRetu.shipments.add(s);
        Test.startTest();
        String responseValueWithRetu = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, false,  'RETURNED');
        String responseValueWithRetu1 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, false,  'PENDING RETURN');
        String responseValueWithRetu2 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, false,  'RECEIVED');
        String responseValueWithRetu3 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, false,  'PENDING APPROVAL');
        String responseValueWithRetu4 = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(oderResponseWithRetu, false,  'CARRIER SCANNED');
        Test.stopTest();
        //System.assertNotEquals(null, responseValueWithRetu2, 'should have value');
    }


    @IsTest
    static void deliveryDateTest(){
        /* modified response to include multiple shipments DP-48512 */
        String apiRes = '{"orderDate":{"month":10,"day":22,"year":2020},"orderDateTime":"2020-10-22T21:58:22","orderNumber":"W037527334","orderSummary":{"merchandiseSubTotal":"$55.95","orderTotal":"$63.95","salesTax":"$0.00","shippingHandling":"$8.00","isRefundTotal":false,"showTax":true},"orderType":"Internet Order","orderStatus":"shipped","statusDate":{"month":10,"day":24,"year":2020},"isLegacyOrder":false,"isEShop":false,"payments":[{"paymenttype":"visa","itemNumber":"3255","amount":"$63.95"}],"shipments":[{"lineItems":[{"family":"PINK","name":"Everyday Lounge Perfect Full-Zip","variantId":"26159854","productImage":"tif/4c/b8/4cb83faeda5448708e3df590fb6a94c3/F19_PKPDP_057_088","swatchImage":"tif/a4/46/a446a22c150e4219aa886b2905f61ffc/1117252444MS_SW","isAvailable":true,"status":"shipped","statusDate":{"month":10,"day":24,"year":2020},"attributes":{"choice":{"value":"Color - (44MS)"},"size1":{"label":"Size","value":"S"},"size2":{},"sendDate":{}},"quantity":{"selected":1},"price":{"unitPrice":{"originalPrice":"$55.95"},"totalPrice":{"originalPrice":"$55.95"},"priceType":"regular"},"url":"/us/pink/apparel-catalog/pink-everyday-lounge-perfect-full-zip-5000006368"}],"payments":[{"paymenttype":"visa","itemNumber":"3255","amount":"$63.95"}],"status":"shipped","statusDate":{"month":10,"day":24,"year":2020},"shipmentSummary":{"merchandiseSubTotal":"$55.95","orderTotal":"$63.95","salesTax":"$0.00","shippingHandling":"$8.00","isRefundTotal":false,"showTax":true},"address":{"countryCode":"US","streetAddress1":"3301 38TH AVE APT 5N","city":"LONG ISLAND CITY","region":"NY","postalCode":"11101-2254","firstName":"Nicole","lastName":"Troelstrup","phone":"(617) 412-6725"},"pickUpStore":{},"carrier":"Newgistics","method":{"title":"Standard Delivery","estimatedDeliveryDate":"2020-10-28T00:00:00","promisedDeliveryDate":"2020-11-03T05:08:00","code":"S"},"trackingNumber":"9274892700465607295905","shipmentTrackingURL":"https://victoriassecret.narvar.com/victoriassecret/tracking/Newgistics?dzip=11101-2254&order_number=W037527334&promise_date=2020-11-03T00%3A08%3A00-05%3A00&service=S&ship_date=2020-10-24T16%3A43%3A40-04%3A00&tracking_numbers=9274892700465607295905","shipmentType":"physical"},{"lineItems":[{"family":"PINK","name":"Everyday Lounge Perfect Full-Zip","variantId":"26159854","productImage":"tif/4c/b8/4cb83faeda5448708e3df590fb6a94c3/F19_PKPDP_057_088","swatchImage":"tif/a4/46/a446a22c150e4219aa886b2905f61ffc/1117252444MS_SW","isAvailable":true,"status":"shipped","statusDate":{"month":10,"day":24,"year":2020},"attributes":{"choice":{"value":"Color - (44MS)"},"size1":{"label":"Size","value":"S"},"size2":{},"sendDate":{}},"quantity":{"selected":1},"price":{"unitPrice":{"originalPrice":"$55.95"},"totalPrice":{"originalPrice":"$55.95"},"priceType":"regular"},"url":"/us/pink/apparel-catalog/pink-everyday-lounge-perfect-full-zip-5000006368"}],"payments":[{"paymenttype":"visa","itemNumber":"3255","amount":"$63.95"}],"status":"shipped","statusDate":{"month":10,"day":24,"year":2020},"shipmentSummary":{"merchandiseSubTotal":"$55.95","orderTotal":"$63.95","salesTax":"$0.00","shippingHandling":"$8.00","isRefundTotal":false,"showTax":true},"address":{"countryCode":"US","streetAddress1":"3301 38TH AVE APT 5N","city":"LONG ISLAND CITY","region":"NY","postalCode":"11101-2254","firstName":"Nicole","lastName":"Troelstrup","phone":"(617) 412-6725"},"pickUpStore":{},"carrier":"Newgistics","method":{"title":"Standard Delivery","estimatedDeliveryDate":"2020-10-28T00:00:00","promisedDeliveryDate":"2020-11-03T05:08:00","code":"S"},"trackingNumber":"9274892700465607295905","shipmentTrackingURL":"https://victoriassecret.narvar.com/victoriassecret/tracking/Newgistics?dzip=11101-2254&order_number=W037527334&promise_date=2020-11-03T00%3A08%3A00-05%3A00&service=S&ship_date=2020-10-24T16%3A43%3A40-04%3A00&tracking_numbers=9274892700465607295905","shipmentType":"physical"}],"returns":{"returnedSummary":{"isRefundTotal":false,"showTax":false}},"isCancelModifyEligible":false}';
        NF_OrderServiceN.OrderResponse order = (NF_OrderServiceN.OrderResponse)JSON.deserialize(apiRes, NF_OrderServiceN.OrderResponse.class);
        Test.startTest();
        String cards = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(order, false, '');
        System.debug(cards);
        Test.stopTest();
        System.assert(String.isNotEmpty(cards));
    }

    @IsTest
    static void deliveryDateTest_PPD(){
        /* modified response to include multiple shipments DP-48512 */
        String apiRes = '{"orderDate":{"month":5,"day":19,"year":2023},"orderDateTime":"2023-05-19T17:20:56","orderNumber":"W009356819","orderSummary":{"giftWrap":{},"merchandiseSubTotal":"$54.95","orderTotal":"$54.95","salesTax":"$0.00","shippingHandling":"$0.00","isRefundTotal":false,"showTax":true},"orderType":"Internet Order","orderStatus":"Shipped","statusDate":{"month":5,"day":19,"year":2023},"isLegacyOrder":false,"isEShop":false,"payments":[{"displayPaymentType":"Visa","type":"visa","number":"1111","amount":"$54.95"}],"shipments":[{"lineItems":[{"family":"Very Sexy","name":"Bombshell Add-2-Cups Push-Up Bra","variantId":"26475366","productImage":"tif/7b/55/7b5548d38eea4febb8fccf6e102121d7/1119916654A2_OM_F","swatchImage":"tif/37/9d/379df58c6d344c5aae710bce4ad130c3/1119916654A2_SW","isAvailable":true,"status":"Shipped","statusDate":{"month":5,"day":19,"year":2023},"attributes":{"choice":{"value":"Color - (54A2)"},"size1":{"label":"Band","value":"32"},"size2":{"label":"Cup","value":"C"},"sendDate":{}},"quantity":{"selected":1},"price":{"unitPrice":{"originalPrice":"$54.95"},"totalPrice":{"originalPrice":"$54.95"},"priceType":"regular"},"url":"/us/vs/bras-catalog/5000000070"}],"status":"Shipped","statusDate":{"month":5,"day":19,"year":2023},"estDeliveryStart":{"month":5,"day":24,"year":2023},"estDeliveryEnd":{"month":5,"day":26,"year":2023},"shipmentSummary":{"giftWrap":{},"merchandiseSubTotal":"$54.95","orderTotal":"$54.95","salesTax":"$0.00","shippingHandling":"$0.00","isRefundTotal":false,"showTax":true},"address":{"countryCode":"US","streetAddress1":"1234 Any St","city":"APO","region":"AA","postalCode":"56789","firstName":"Lisa","lastName":"McKenna","phone":"(614) 330-5037"},"pickUpStore":{},"carrier":"DFLT","method":{"title":"Standard Delivery","promisedDeliveryDate":"2023-05-26T17:22:00","code":"P"},"trackingNumber":"92202305191392027209459","shipmentTrackingURL":"https://victoriassecret.narvar.com/victoriassecret/tracking/DFLT?dzip=56789&order_number=W009356819&promise_date=2023-05-26T13%3A22%3A00-04%3A00&service=P&ship_date=2023-05-19T14%3A27%3A21-04%3A00&tracking_numbers=92202305191392027209459","shipmentType":"physical"}],"returns":{"returnedSummary":{"giftWrap":{},"isRefundTotal":false,"showTax":false}},"isCancelModifyEligible":false,"multiShippingAddress":false}';
        NF_OrderServiceN.OrderResponse order = (NF_OrderServiceN.OrderResponse)JSON.deserialize(apiRes, NF_OrderServiceN.OrderResponse.class);
        Test.startTest();
        String cards = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(order, false, '');
        System.debug(cards);
        Test.stopTest();
        System.assert(String.isNotEmpty(cards));
    }
}