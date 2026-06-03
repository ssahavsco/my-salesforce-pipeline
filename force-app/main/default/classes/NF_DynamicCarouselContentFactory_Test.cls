@isTest
public class NF_DynamicCarouselContentFactory_Test {
  private static List<String> listOfOrderStatus = new List<String>{
    'Shipped',
    'RETURNED',
    'PARTIALLY RETURNED',
    'CANCELED',
    'AWAITING PAYMENT',
    'PARTIALLY RELEASED'
  };
  private static List<String> listOfReturnStatus = new List<String>{
    'RETURNED',
    'PENDING RETURN',
    'CARRIER SCANNED',
    'PENDING APPROVAL',
    'RECEIVED'
  };

  @isTest
  public static void getCarouselPayloadInfo_Test() {
    Test.startTest();
    NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();
    order.orderStatus = 'RETURNED';
    order.orderNumber = 'W000002674';
    order.orderDate = orderDate();
    order.isDisplayDiscounts = true;
    order.orderSummary = new NF_OrderServiceN.OrderSummary();
    order.orderSummary.totalPaymentToBeCharged = '$100.00';
    order.orderSummary.orderTotal = '$100.00';

    order.orderStatus = 'RETURNED';
    order.shipments = new List<NF_OrderServiceN.shipments>(
      addShippedLines(1, 'RETURNED', 'physical')
    );
    NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(
      order,
      true,
      null,
      'en_US'
    );
    order.orderStatus = 'CANCELLED';
    order.cancelled = new List<NF_OrderServiceN.cancelled>(
      addCancelledLines(1)
    );
    NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(
      order,
      true,
      null,
      'en_US'
    );
    Test.stopTest();
  }

  @isTest
  public static void getReturnShipmentCarouselPayload_Test() {
    Test.startTest();
    for (String status : listOfReturnStatus) {
      NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();
      order.orderStatus = status;
      order.orderNumber = 'D000002674';
      order.orderDate = orderDate();
      order.isDisplayDiscounts = true;
      order.orderSummary = new NF_OrderServiceN.OrderSummary();
      order.orderSummary.totalPaymentToBeCharged = '$100.00';
      order.orderSummary.orderTotal = '$100.00';
      order.shipments = new List<NF_OrderServiceN.shipments>(
        addShippedLines(6, status, 'physical')
      );

      String payload = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(
        order,
        true,
        status,
        'en_US'
      );

      payload = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(
        order,
        false,
        status,
        'en_US'
      );

      order.orderNumber = 'W000002674';
      payload = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(
        order,
        true,
        status,
        'en_US'
      );

      payload = NF_DynamicCarouselContentFactory.getReturnShipmentCarouselPayload(
        order,
        false,
        status,
        'en_US'
      );
    }

    Test.stopTest();
  }

  @isTest
  public static void getReturnsCarouselPayload_Test() {
    Test.startTest();
    for (String status : listOfReturnStatus) {
      NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();
      order.orderStatus = status;
      order.orderNumber = 'D000002674';
      order.orderDate = orderDate();
      order.isDisplayDiscounts = true;
      order.orderSummary = new NF_OrderServiceN.OrderSummary();
      order.orderSummary.totalPaymentToBeCharged = '$100.00';
      order.orderSummary.orderTotal = '$100.00';
      order.returns = addReturnLines(3);

      String payload = NF_DynamicCarouselContentFactory.getReturnsCarouselPayload(
        order,
        true,
        status,
        'en_US'
      );

      payload = NF_DynamicCarouselContentFactory.getReturnsCarouselPayload(
        order,
        false,
        status,
        'en_US'
      );

      order.orderNumber = 'W000002674';
      payload = NF_DynamicCarouselContentFactory.getReturnsCarouselPayload(
        order,
        true,
        status,
        'en_US'
      );

      payload = NF_DynamicCarouselContentFactory.getReturnsCarouselPayload(
        order,
        false,
        status,
        'en_US'
      );
    }

    Test.stopTest();
  }

  @isTest
  public static void getShipmentsCarouselPayload_Test() {
    Test.startTest();
    for (String status : listOfOrderStatus) {
      NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();
      order.orderStatus = status;
      order.orderNumber = 'W000002674';
      order.orderDate = orderDate();
      order.shipments = new List<NF_OrderServiceN.shipments>(
        addShippedLines(6, status, 'physical')
      );
      order.isDisplayDiscounts = true;
      order.orderSummary = new NF_OrderServiceN.OrderSummary();
      order.orderSummary.totalPaymentToBeCharged = '$100.00';
      order.orderSummary.orderTotal = '$100.00';

      /** Start - Autheticated Flow */

      String payload = NF_DynamicCarouselContentFactory.getShipmentsCarouselPayload(
        order,
        false,
        status,
        'en_US'
      );
      /** End - Autheticated Flow */

      /** Start - Un-Autheticated Flow */
      payload = NF_DynamicCarouselContentFactory.getShipmentsCarouselPayload(
        order,
        true,
        status,
        'en_US'
      );
      /** End - Un-Autheticated Flow */

      /** Start - Gift Card */
      order.shipments = new List<NF_OrderServiceN.shipments>(
        addShippedLines(1, status, 'electronic')
      );
      payload = NF_DynamicCarouselContentFactory.getShipmentsCarouselPayload(
        order,
        true,
        status,
        'en_US'
      );
    }
    /** End - Gift Card */
    Test.stopTest();
  }

  @isTest
  public static void getCancelledCarouselPayload_Test() {
    NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();
    order.orderStatus = 'CANCELLED';
    order.orderNumber = 'W143975589';
    order.orderDate = orderDate();
    order.isDisplayDiscounts = true;
    order.orderSummary = new NF_OrderServiceN.OrderSummary();
    order.orderSummary.totalPaymentToBeCharged = '$0.00';
    order.orderSummary.orderTotal = '$0.00';

    order.cancelled = new List<NF_OrderServiceN.cancelled>(
      addCancelledLines(3)
    );

    Test.startTest();

    /** Start - Authenticated with W  */
    order.orderStatus = 'CANCELLED';
    order.orderNumber = 'W143975589';
    String payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      true,
      'en_US'
    );
    order.orderStatus = 'CANCELED';
    order.orderNumber = 'W143975589';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      true,
      'en_US'
    );

    /** End - Authenticated with W  */

    /** Start - Un-Authenticated with W  */

    order.orderStatus = 'CANCELLED';
    order.orderNumber = 'W143975589';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      false,
      'en_US'
    );
    order.orderStatus = 'CANCELED';
    order.orderNumber = 'W143975589';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      false,
      'en_US'
    );

    /** End - Un-Authenticated with W  */

    /** Start - Authenticated with D  */

    order.orderNumber = 'D143975589';
    order.orderStatus = 'CANCELLED';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      true,
      'en_US'
    );
    order.orderNumber = 'D143975589';
    order.orderStatus = 'CANCELED';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      true,
      'en_US'
    );

    /** End - Authenticated with D  */

    /** Start - Un-Authenticated with D  */

    order.orderNumber = 'D143975589';
    order.orderStatus = 'CANCELLED';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      false,
      'en_US'
    );
    order.orderNumber = 'D143975589';
    order.orderStatus = 'CANCELED';
    payload = NF_DynamicCarouselContentFactory.getCancelledCarouselPayload(
      order,
      false,
      'en_US'
    );

    /** End - Un-Authenticated with D  */
    Test.stopTest();
  }

  public static List<NF_OrderServiceN.shipments> addShippedLines(
    Integer noOfLines,
    String status,
    String shipmentType
  ) {
    List<NF_OrderServiceN.shipments> shipments = new List<NF_OrderServiceN.shipments>();
    List<String> listOfShipmentStatus = new List<String>{
      'RETURNED',
      'Shipped'
    };

    for (Integer i = 0; i < noOfLines; i++) {
      for (String shipmentStatus : listOfShipmentStatus) {
        NF_OrderServiceN.shipments shipment = new NF_OrderServiceN.shipments();
        shipment.status = shipmentStatus; // status;
        shipment.shipmentTrackingURL = 'https://victoriassecret.narvar.com/victoriassecret/tracking/DHL';
        List<NF_OrderServiceN.lineItems> lineItems = new List<NF_OrderServiceN.lineItems>();
        for (Integer j = 0; j < noOfLines; j++) {
          NF_OrderServiceN.lineItems line = new NF_OrderServiceN.lineItems();
          line.productImage = 'png/zz/24/11/19/01/1123947272ZE_OM_F';
          line.statusDate = statusDate();
          line.quantity = new NF_OrderServiceN.quantity();
          line.quantity.selected = 1;
          line.price = new NF_OrderServiceN.price();
          line.price.priceType = 'sale';
          line.price.totalPrice = new NF_OrderServiceN.totalPrice();
          line.price.totalPrice.salePrice = '$1.00';
          line.price.totalPrice.originalPrice = '$1.00';
          line.status = status;
          lineItems.add(line);
        }
        shipment.statusDate = statusDate();
        shipment.shipmentType = shipmentType;
        shipment.estDeliveryStart = estimatedDeliveryStart();
        shipment.estDeliveryEnd = estimatedDeliveryEnd();
        shipment.lineItems = lineItems;
        shipments.add(shipment);
      }
    }
    return shipments;
  }

  public static List<NF_OrderServiceN.cancelled> addCancelledLines(
    Integer noOfLines
  ) {
    List<NF_OrderServiceN.cancelled> cancelled = new List<NF_OrderServiceN.cancelled>();
    for (Integer i = 0; i < noOfLines; i++) {
      NF_OrderServiceN.cancelled c = new NF_OrderServiceN.cancelled();
      c.quantity = new NF_OrderServiceN.quantity();
      c.productImage = 'png/zz/24/11/19/01/1123947272ZE_OM_F';
      c.quantity.selected = 1;
      c.statusDate = statusDate();
      cancelled.add(c);
    }
    return cancelled;
  }

  public static NF_OrderServiceN.returns addReturnLines(Integer noOfLines) {
    NF_OrderServiceN.returns returnData = new NF_OrderServiceN.returns();
    List<NF_OrderServiceN.lineItems> lineItems = new List<NF_OrderServiceN.lineItems>();
    for (Integer i = 0; i < noOfLines; i++) {
      NF_OrderServiceN.lineItems line = new NF_OrderServiceN.lineItems();
      line.productImage = 'png/zz/24/11/19/01/1123947272ZE_OM_F';
      line.statusDate = statusDate();
      line.quantity = new NF_OrderServiceN.quantity();
      line.quantity.selected = 1;
      line.price = new NF_OrderServiceN.price();
      line.price.priceType = 'sale';
      line.price.totalPrice = new NF_OrderServiceN.totalPrice();
      line.price.totalPrice.salePrice = '$1.00';
      line.price.totalPrice.originalPrice = '$1.00';
      line.status = 'RETURNED';
      lineItems.add(line);
    }
    returnData.lineItems = lineItems;
    return returnData;
  }

  public static NF_OrderServiceN.OrderDate orderDate() {
    NF_OrderServiceN.OrderDate dt = new NF_OrderServiceN.OrderDate();
    dt.year = 2022;
    dt.month = 4;
    dt.day = 30;
    return dt;
  }

  public static NF_OrderServiceN.statusDate statusDate() {
    NF_OrderServiceN.statusDate dt = new NF_OrderServiceN.statusDate();
    dt.year = 2022;
    dt.month = 4;
    dt.day = 30;
    return dt;
  }
  public static NF_OrderServiceN.estimatedDeliveryStart estimatedDeliveryStart() {
    NF_OrderServiceN.estimatedDeliveryStart dt = new NF_OrderServiceN.estimatedDeliveryStart();
    dt.year = '2022';
    dt.month = '4';
    dt.day = '30';
    return dt;
  }
  public static NF_OrderServiceN.estimatedDeliveryEnd estimatedDeliveryEnd() {
    NF_OrderServiceN.estimatedDeliveryEnd dt = new NF_OrderServiceN.estimatedDeliveryEnd();
    dt.year = '2022';
    dt.month = '4';
    dt.day = '30';
    return dt;
  }
}