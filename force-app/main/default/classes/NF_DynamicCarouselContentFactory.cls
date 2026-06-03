/*****************************************************************************************************@@
Class Name     :  NF_DynamicCarouselContentFactory
Purpose        :  Class to serialize order api response for auth customer.(used by chatbot)
History:
-------
VERSION  AUTHOR                 DATE                	DETAIL                      		TICKET REFERENCE/ NO.
1.       apoorv                09/3/2020             Original Version             				-
2.       Manishi               09/27/2021            Adding 'canceled' status condition        DP-48512
3.       Sumit                 07/25/2023            adjusting v5
4.       Himanshu              12/10/2024            RMS changes 							   CCS-509

@Testsuite:  {NF_DynamicCarouselContentFactoryTest}        
*********************************************************************************************************/
public class NF_DynamicCarouselContentFactory {
  public static String getCarouselPayloadInfo(
    NF_OrderServiceN.OrderResponse order,
    Boolean isAuthUser,
    String parentOrderPrefix,
    String language
  ) {
    Boolean isUserAuthenticated = isAuthUser;
    System.debug(
      LoggingLevel.DEBUG,
      'NF_DynamicCarouselContentFactory.getCarouselPayloadInfo: isUserAuthenticated=' +
      isUserAuthenticated
    );
    String finalDynamicPayload;
    String orderStatusType;

    if (order != null && order.orderStatus != null) {
      orderStatusType = order.orderStatus.toUpperCase();
      //for the orders where status is returned but we are getting shipments as well (these are partial orders)
      if (
        orderStatusType == 'RETURNED' ||
        orderStatusType == 'PENDING RETURN' ||
        orderStatusType == 'CARRIER SCANNED' ||
        orderStatusType == 'PENDING APPROVAL' ||
        orderStatusType == 'RECEIVED'
      ) {
        if (order.shipments == null) {
          finalDynamicPayload = getReturnsCarouselPayload(
            order,
            isUserAuthenticated,
            orderStatusType,
            language
          );
        } else if (order.shipments.size() == 1) {
          finalDynamicPayload = getReturnShipmentCarouselPayload(
            order,
            isUserAuthenticated,
            orderStatusType,
            language
          );
        } else {
          finalDynamicPayload = getShipmentsCarouselPayload(
            order,
            isUserAuthenticated,
            orderStatusType,
            language
          );
        }
      }
      //when order status = cancelled.
      //added condition to include 'canceled' status as well DP-48512
      else if (
        orderStatusType == 'CANCELLED' ||
        orderStatusType == 'CANCELED'
      ) {
        finalDynamicPayload = getCancelledCarouselPayload(
          order,
          isUserAuthenticated,
          language
        );
      }
      //for all other status types.
      else {
        finalDynamicPayload = getShipmentsCarouselPayload(
          order,
          isUserAuthenticated,
          orderStatusType,
          language
        );
      }
    }

    return finalDynamicPayload;
  }

  //get carousel payload for all other status.
  public static String getShipmentsCarouselPayload(
    NF_OrderServiceN.OrderResponse order,
    Boolean isUserAuthenticated,
    String orderStatusType,
    String language
  ) {
    String finalDynamicPayload;
    List<String> payloads = new List<String>();
    VSCCS_CarouselOrderDetails.Carousel carousel = new VSCCS_CarouselOrderDetails.Carousel(
      language
    );
    Integer counter = 1;
    String overwriteOrderStatus = null;
    String NO_IMAGE_URL;
    LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
    if (lbAPI != null && lbAPI.Community_Base_URL__c != null) {
      NO_IMAGE_URL =
        lbAPI.Community_Base_URL__c +
        '/resource/LbrandsResources/img/No_Image_Icon.png';
    }
    for (NF_OrderServiceN.shipments shipment : order.shipments) {
      Integer items = 0;
      String imageHTMLCompiled = '';
      List<String> imageHTML = new List<String>();
      String shipmentButton = '';
      if (
        String.isNotBlank(shipment.shipmentTrackingURL) &&
        orderStatusType != 'RETURNED'
      ) {
        shipmentButton =
          '<a href=\'' +
          shipment.shipmentTrackingURL +
          '\' target=\'_blank\' class=\'button1\'>TRACK SHIPMENT</a>';
      }

      //LBRAN-197
      String orderHistoryButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' target=\'_blank\' class=\'button2\'>VIEW ORDER HISTORY</a>';
      String callUsButton = '<a href=\'#\' class=\'button3\'>CALL US</a>';

      String viewAllShipmentsButton = '<a href=\'#\' class=\'button2\'>VIEW ALL SHIPMENTS</a>';
      String payloadCard = '';
      /* start of LBRAN-107 */
      String baseUrl = (NF_Util.getLBrandAPISettings() != null)
        ? NF_Util.getLBrandAPISettings().Live_Agent_Site_Url__c
        : System.URL.getSalesforceBaseUrl().toExternalForm();
      /* end of LBRAN-107 */
      String truckHtml =
        '<img src=\'' +
        baseUrl +
        '/resource/NF_CCARE_Bot/img/shipment_truck.png\' width=\'42\' height=\'55\'>';
      if (counter > 3) {
        // if more than 4 shipments, give the truck image and the View order button based on the auth and unauth user.
        if (isUserAuthenticated) {
          VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
          v.orderNumber = order.orderNumber;
          v.orderPlacedDate = monthDateFormat(
            order.orderDate.year,
            order.orderDate.month,
            order.orderDate.day
          );
          v.displayStatus = 'Your order contains more than 4 shipments';
          v.truckHtml = truckHtml;
          v.orderHistoryButton = orderHistoryButton;
          v.Id = counter;
          carousel.isAuthorized = true;
          carousel.details.add(v);
          System.debug('Carousel ==> ' + JSON.serialize(carousel));
        } else {
          VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
          v.orderNumber = order.orderNumber;
          v.orderPlacedDate = monthDateFormat(
            order.orderDate.year,
            order.orderDate.month,
            order.orderDate.day
          );
          v.displayStatus = 'Your order contains more than 4 shipments';
          v.truckHtml = truckHtml;
          v.Id = counter;
          carousel.isAuthorized = false;
          carousel.details.add(v);
          System.debug('Carousel ==> ' + JSON.serialize(carousel));
        }

        // payloads.add(payloadCard);
        break;
      }
      // String totalItemPrice = order.orderSummary.orderTotal;
      String totalItemPrice = order.isDisplayDiscounts == true
        ? order.orderSummary.totalPaymentToBeCharged
        : order.orderSummary.orderTotal;
      Decimal totalPrice = 0.00;
      String itemCurrency;

      for (NF_OrderServiceN.lineItems item : shipment.lineItems) {
        items = items + item.quantity.selected;
        if (item.productImage == null) {
          // item.productImage = 'tif/c0/c4/c0c4a82db61949b49ffbd2875c0315ac/406009M7H_OM_F';
          imageHTML.add(
            '<img src=\'' + NO_IMAGE_URL + '\' width=\'75\' height=\'55\'>'
          );
        } else {
          imageHTML.add(
            '<img src=\'https://www.victoriassecret.com/p/404x539/' +
              item.productImage +
              '.jpg\' width=\'42\' height=\'55\'>'
          );
        }
        //if multiple shipment : Total will be based on individual shipment's lineitems prices.
        if (order.shipments.size() > 1) {
          /* LBRAN-219: Check for the sale price instead of total price for multiple shipments */
          String lineItemPrice = (item.price.totalPrice.salePrice != null)
            ? item.price.totalPrice.salePrice
            : item.price.totalPrice.originalPrice;
          lineItemPrice = lineItemPrice.deleteWhitespace();
          lineItemPrice = lineItemPrice.replaceAll('[^0-9.]', '');

          Decimal individualPrice = Decimal.valueOf(lineItemPrice);
          totalPrice = totalPrice + individualPrice.setScale(2);
          itemCurrency = '$';
        }

        // LBRAN-234: Checking for mathcing orders in the returned object of the order.
        // If they match this shipment, its status will be overwritten by the returned order.
        if (
          order.returns != null &&
          order.returns.lineItems != null &&
          order.returns.lineItems.size() > 0
        ) {
          for (NF_OrderServiceN.lineItems li : order.returns.lineItems) {
            if (li.variantId == item.variantId) {
              overwriteOrderStatus = li.status.capitalize();
            }
          }
        }
      }

      if (order.shipments.size() > 1) {
        totalItemPrice = itemCurrency + String.valueOf(totalPrice);
      }

      String deliveryDate;
      String delivertStartDate;
      String delivertEndtDate;
      Datetime dt1;
      Datetime dt2;

      if (shipment.shipmentType == 'electronic') {
        // deliveryDate = shipment.estDeliveryEnd.month+ '/' +shipment.estDeliveryEnd.day + '/' +shipment.estDeliveryEnd.year;
        delivertEndtDate =
          shipment.estDeliveryEnd.month +
          '/' +
          shipment.estDeliveryEnd.day +
          '/' +
          shipment.estDeliveryEnd.year;
        dt2 = Date.parse(delivertEndtDate);
        dt2 = dt2.addDays(1);
        deliveryDate = dt2.format('MMM') + ' ' + dt2.format('dd');
      } else if (
        shipment.estDeliveryStart != null &&
        shipment.estDeliveryEnd != null
      ) {
        try {
          delivertStartDate =
            shipment.estDeliveryStart.month +
            '/' +
            shipment.estDeliveryStart.day +
            '/' +
            shipment.estDeliveryStart.year;
          dt1 = date.parse(delivertStartDate);
          dt1 = dt1.addDays(1);
        } catch (Exception e) {
          System.debug('Exception for start date :: ' + e.getCause());
        }
        try {
          delivertEndtDate =
            shipment.estDeliveryEnd.month +
            '/' +
            shipment.estDeliveryEnd.day +
            '/' +
            shipment.estDeliveryEnd.year;
          dt2 = Date.parse(delivertEndtDate);
          dt2 = dt2.addDays(1);
          deliveryDate = (dt1 == null)
            ? (dt2.format('MMM') + ' ' + dt2.format('dd'))
            : (dt1.format('MMM') +
              ' ' +
              dt1.format('dd') +
              ' - ' +
              dt2.format('MMM') +
              ' ' +
              dt2.format('dd'));
          // System.debug(deliveryDate);
        } catch (Exception e) {
          System.debug('Excdeption for End Date :: ' + e.getCause());
        }
        // deliveryDate = shipment.estDeliveryStart.month + '/' + shipment.estDeliveryStart.day + '/' + shipment.estDeliveryStart.year + '-' + shipment.estDeliveryEnd.month+ '/' +shipment.estDeliveryEnd.day + '/' +shipment.estDeliveryEnd.year;
      } else {
        deliveryDate = 'N/A';
      }

      Integer totalItems = order.shipments.size();
      Integer totalImagesToShow = 0;
      for (String HTML : imageHTML) {
        totalImagesToShow = totalImagesToShow + 1;
        imageHTMLCompiled = imageHTMLCompiled + HTML;
        if (totalImagesToShow == 3) {
          break;
        }
      }
      String orderStatus = overwriteOrderStatus == null
        ? shipment.status.capitalize()
        : overwriteOrderStatus;
      if (isUserAuthenticated) {
        switch on orderStatusType {
          when 'RETURNED' {
            if (shipment.status.toUpperCase() == 'RETURNED') {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Return Processed on:' +
                shipment.statusDate.month +
                '/' +
                shipment.statusDate.day +
                '/' +
                shipment.statusDate.year;
              v.estimatedDeliveryDate = deliveryDate;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            } else {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Status: ' +
                orderStatus +
                ' on ' +
                monthDateFormat(
                  shipment.statusDate.year,
                  shipment.statusDate.month,
                  shipment.statusDate.day
                );
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
          when 'PARTIALLY RETURNED' {
            if (shipment.status.toUpperCase() == 'RETURNED') {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Return Processed on:' +
                shipment.statusDate.month +
                '/' +
                shipment.statusDate.day +
                '/' +
                shipment.statusDate.year;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            } else {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Status: ' +
                orderStatus +
                ' on ' +
                monthDateFormat(
                  shipment.statusDate.year,
                  shipment.statusDate.month,
                  shipment.statusDate.day
                );
              v.estimatedDeliveryDate = deliveryDate;
              v.shipmentButton = shipmentButton;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
          when 'CANCELED' {
            VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
            v.orderNumber = order.orderNumber;
            v.orderPlacedDate = monthDateFormat(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day
            );
            v.itemQuantity = items.toString();
            v.imageHTMLCompiled = imageHTMLCompiled;
            v.totalItemPrice = totalItemPrice;
            v.displayStatus = 'Cancelled';
            v.orderHistoryButton = orderHistoryButton;
            v.Id = counter;
            carousel.isAuthorized = true;
            carousel.details.add(v);
            System.debug('Carousel ==> ' + JSON.serialize(carousel));
          }
          when 'HOLD' {
            // no carousel
          }
          when 'AWAITING PAYMENT' {
            VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
            v.orderNumber = order.orderNumber;
            v.orderPlacedDate = monthDateFormat(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day
            );
            v.itemQuantity = items.toString();
            v.imageHTMLCompiled = imageHTMLCompiled;
            v.totalItemPrice = totalItemPrice;
            v.displayStatus = 'Awaiting Payment';
            v.callUsButton = callUsButton;
            v.Id = counter;
            carousel.isAuthorized = true;
            carousel.details.add(v);
            System.debug('Carousel ==> ' + JSON.serialize(carousel));
          }
          when 'PARTIALLY RELEASED' {
            VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
            v.orderNumber = order.orderNumber;
            v.orderPlacedDate = monthDateFormat(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day
            );
            v.itemQuantity = items.toString();
            v.imageHTMLCompiled = imageHTMLCompiled;
            v.totalItemPrice = totalItemPrice;
            v.displayStatus =
              'Status: ' +
              orderStatus +
              ' on ' +
              monthDateFormat(
                shipment.statusDate.year,
                shipment.statusDate.month,
                shipment.statusDate.day
              );
            v.estimatedDeliveryDate = deliveryDate;
            v.shipmentButton = shipmentButton;
            v.orderHistoryButton = orderHistoryButton;
            v.Id = counter;
            carousel.isAuthorized = true;
            carousel.details.add(v);
            System.debug('Carousel ==> ' + JSON.serialize(carousel));
          }
          when else {
            if (counter >= 1) {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              // v.displayStatus = (deliveryDate == null ||
              //   deliveryDate == 'N/A')
              //   ? 'Status: ' +
              //     orderStatus +
              //     ' on ' +
              //     monthDateFormat(
              //       shipment.statusDate.year,
              //       shipment.statusDate.month,
              //       shipment.statusDate.day
              //     )
              //   : '';
              v.displayStatus =
                orderStatusUIText(orderStatus) +
                monthDateFormat(
                  shipment.statusDate.year,
                  shipment.statusDate.month,
                  shipment.statusDate.day
                );
              v.estimatedDeliveryDate = deliveryDate;
              v.shipmentButton = shipmentButton;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            } else {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus = (deliveryDate == null ||
                deliveryDate == 'N/A')
                ? 'Status: ' +
                  orderStatus +
                  ' on ' +
                  monthDateFormat(
                    shipment.statusDate.year,
                    shipment.statusDate.month,
                    shipment.statusDate.day
                  )
                : '';
              v.estimatedDeliveryDate = deliveryDate;
              v.shipmentButton = shipmentButton;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
        }
      } else {
        // System.debug(LoggingLevel.DEBUG, orderStatusType);
        switch on orderStatusType {
          when 'RETURNED' {
            if (shipment.status.toUpperCase() == 'RETURNED') {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Return Processed on ' +
                shipment.statusDate.month +
                '/' +
                shipment.statusDate.day +
                '/' +
                shipment.statusDate.year;
              v.shipmentButton = shipmentButton;
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            } else {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Status: ' +
                orderStatus +
                ' on ' +
                monthDateFormat(
                  shipment.statusDate.year,
                  shipment.statusDate.month,
                  shipment.statusDate.day
                );
              v.Id = counter;
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
          when 'PARTIALLY RETURNED' {
            if (shipment.status.toUpperCase() == 'RETURNED') {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                'Return Processed on:' +
                shipment.statusDate.month +
                '/' +
                shipment.statusDate.day +
                '/' +
                shipment.statusDate.year;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            } else {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus = (deliveryDate == null ||
                deliveryDate == 'N/A')
                ? 'Status: ' +
                  orderStatus +
                  ' on ' +
                  monthDateFormat(
                    shipment.statusDate.year,
                    shipment.statusDate.month,
                    shipment.statusDate.day
                  )
                : '';
              v.estimatedDeliveryDate = deliveryDate;
              v.shipmentButton = shipmentButton;
              v.orderHistoryButton = orderHistoryButton;
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
          when 'CANCELED' {
            VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
            v.orderNumber = order.orderNumber;
            v.orderPlacedDate = monthDateFormat(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day
            );
            v.itemQuantity = items.toString();
            v.imageHTMLCompiled = imageHTMLCompiled;
            v.totalItemPrice = totalItemPrice;
            v.displayStatus = 'Cancelled';
            v.orderHistoryButton = orderHistoryButton;
            v.Id = counter;
            carousel.isAuthorized = false;
            carousel.details.add(v);
            System.debug('Carousel ==> ' + JSON.serialize(carousel));
          }
          when 'HOLD' {
            // no carousel
          }
          when 'AWAITING PAYMENT' {
            VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
            v.orderNumber = order.orderNumber;
            v.orderPlacedDate = monthDateFormat(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day
            );
            v.itemQuantity = items.toString();
            v.imageHTMLCompiled = imageHTMLCompiled;
            v.totalItemPrice = totalItemPrice;
            v.displayStatus = 'Awaiting Payment';
            v.callUsButton = callUsButton;
            v.Id = counter;
            carousel.isAuthorized = false;
            carousel.details.add(v);
            System.debug('Carousel ==> ' + JSON.serialize(carousel));
          }
          when 'PARTIALLY RELEASED' {
            VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
            v.orderNumber = order.orderNumber;
            v.orderPlacedDate = monthDateFormat(
              order.orderDate.year,
              order.orderDate.month,
              order.orderDate.day
            );
            v.itemQuantity = items.toString();
            v.imageHTMLCompiled = imageHTMLCompiled;
            v.totalItemPrice = totalItemPrice;
            v.displayStatus =
              'Status: ' +
              orderStatus +
              ' on ' +
              monthDateFormat(
                shipment.statusDate.year,
                shipment.statusDate.month,
                shipment.statusDate.day
              );
            v.estimatedDeliveryDate = deliveryDate;
            v.shipmentButton = shipmentButton;
            v.orderHistoryButton = orderHistoryButton;
            v.Id = counter;
            carousel.isAuthorized = false;
            carousel.details.add(v);
            System.debug('Carousel ==> ' + JSON.serialize(carousel));
          }
          when else {
            if (counter >= 1) {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                orderStatusUIText(orderStatus) +
                monthDateFormat(
                  shipment.statusDate.year,
                  shipment.statusDate.month,
                  shipment.statusDate.day
                );
              v.estimatedDeliveryDate = deliveryDate;
              v.shipmentButton = shipmentButton;
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            } else {
              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = items.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = totalItemPrice;
              v.displayStatus =
                orderStatusUIText(orderStatus) +
                monthDateFormat(
                  shipment.statusDate.year,
                  shipment.statusDate.month,
                  shipment.statusDate.day
                );
              v.estimatedDeliveryDate = deliveryDate;
              v.shipmentButton = shipmentButton;
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
        }
      }

      //   payloads.add(payloadCard);
      counter++;
    }

    finalDynamicPayload = JSON.serialize(carousel, true);
    System.debug(
      LoggingLevel.DEBUG,
      'printing the payload' + finalDynamicPayload
    );
    return finalDynamicPayload;
  }

  //get carousel payload speciifc to 'RETURNED' status and no shipments.
  public static String getReturnsCarouselPayload(
    NF_OrderServiceN.OrderResponse order,
    Boolean isUserAuthenticated,
    String status,
    String language
  ) {
    String finalDynamicPayload;
    VSCCS_CarouselOrderDetails.Carousel carousel = new VSCCS_CarouselOrderDetails.Carousel(
      language
    );
    List<String> payloads = new List<String>();
    if (order.returns != null) {
      NF_OrderServiceN.returns eachReturn = order.returns;
      Integer counter = 1;
      Integer items = 0;
      String imageHTMLCompiled = '';
      List<String> imageHTML = new List<String>();
      String orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; font-size: 12px; color: #4e3844;\' class=\'button2\'>VIEW ORDER HISTORY</a>';
      String payloadCard = '';

      // String totalItemPrice = order.orderSummary.orderTotal;
      String totalItemPrice = order.isDisplayDiscounts == true
        ? order.orderSummary.totalPaymentToBeCharged
        : order.orderSummary.orderTotal;
      Decimal totalPrice = 0.00;
      String itemCurrency;
      Integer totalItems = order.returns.lineItems.size();
      for (NF_OrderServiceN.lineItems item : eachReturn.lineItems) {
        items = items + item.quantity.selected;
        if (item.productImage == null) {
          item.productImage = 'tif/c0/c4/c0c4a82db61949b49ffbd2875c0315ac/406009M7H_OM_F';
        }
        imageHTML.add(
          '<img src=\'https://www.victoriassecret.com/p/404x539/' +
            item.productImage +
            '.jpg\' width=\'42\' height=\'55\'>'
        );
        imageHTMLCompiled = getImagesArray(imageHTML, 3);
        String lineItemPrice = (item.price.totalPrice.salePrice != null)
          ? item.price.totalPrice.salePrice
          : item.price.totalPrice.originalPrice;
        lineItemPrice = lineItemPrice.deleteWhitespace();
        lineItemPrice = lineItemPrice.replaceAll('[^0-9.]', '');

        Decimal individualPrice = Decimal.valueOf(lineItemPrice);
        totalPrice = totalPrice + individualPrice.setScale(2);
        itemCurrency = '$';
        totalItemPrice = itemCurrency + String.valueOf(totalPrice);
        if (isUserAuthenticated) {
          //display order details button else not.
          // RMS Changes -- CCS-509
          if (order.orderNumber.startsWith('D')) {
            switch on status {
              when 'RETURNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refunded';
                v.orderDetailsButton = orderDetailsButton;
                carousel.isAuthorized = true;
                v.Id = counter;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING RETURN' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Return Initiated';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'CARRIER SCANNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Package with Carrier';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING APPROVAL' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refund Pending';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'RECEIVED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refund in Process';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          } else {
            switch on status {
              when 'RETURNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.orderPlacedDate = monthDateFormat(
                  order.orderDate.year,
                  order.orderDate.month,
                  order.orderDate.day
                );
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus =
                  'Return Processed on ' +
                  item.statusDate.month +
                  '/' +
                  item.statusDate.day +
                  '/' +
                  item.statusDate.year;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          }
        } else {
          if (order.orderNumber.startsWith('D')) {
            switch on status {
              when 'RETURNED' {
                orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refunded';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING RETURN' {
                orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Return Initiated';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'CARRIER SCANNED' {
                orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Package with Carrier';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING APPROVAL' {
                orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refund Pending';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'RECEIVED' {
                orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refund in Process';
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          } else {
            switch on status {
              when 'RETURNED' {
                orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.orderPlacedDate = monthDateFormat(
                  order.orderDate.year,
                  order.orderDate.month,
                  order.orderDate.day
                );
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus =
                  'Return Processed on ' +
                  item.statusDate.month +
                  '/' +
                  item.statusDate.day +
                  '/' +
                  item.statusDate.year;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          }
        }
      }

      // payloads.add(payloadCard);
      counter++;

      finalDynamicPayload = JSON.serialize(carousel, true);
      System.debug(
        LoggingLevel.DEBUG,
        'printing the payload' + finalDynamicPayload
      );
    }
    return finalDynamicPayload;
  }

  //get carousel payload speciifc to 'CANCELLED' status
  public static String getCancelledCarouselPayload(
    NF_OrderServiceN.OrderResponse order,
    Boolean isUserAuthenticated,
    String language
  ) {
    VSCCS_CarouselOrderDetails.Carousel carousel = new VSCCS_CarouselOrderDetails.Carousel(
      language
    );
    String finalDynamicPayload;
    String payloadCard = '';
    Integer items = 1;
    String imageHTMLCompiled = '';
    Integer counter = 0;
    Integer totalItems = 0;
    List<String> imageHTML = new List<String>();
    String orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';
    List<String> payloads = new List<String>();
    if (order.cancelled != null && order.cancelled.size() > 0) {
      for (NF_OrderServiceN.cancelled eachCancelOrder : order.cancelled) {
        // String totalItemPrice = order.orderSummary.orderTotal;
        String totalItemPrice = order.isDisplayDiscounts == true
          ? order.orderSummary.totalPaymentToBeCharged
          : order.orderSummary.orderTotal;
        Integer totalPrice = 0;
        String itemCurrency;
        totalItems = order.cancelled.size();
        items = items + eachCancelOrder.quantity.selected;
        if (eachCancelOrder.productImage == null) {
          eachCancelOrder.productImage = 'tif/c0/c4/c0c4a82db61949b49ffbd2875c0315ac/406009M7H_OM_F';
        }
        imageHTML.add(
          '<img src=\'https://www.victoriassecret.com/p/404x539/' +
            eachCancelOrder.productImage +
            '.jpg\' width=\'42\' height=\'55\'>'
        );
        imageHTMLCompiled = getImagesArray(imageHTML, 3);
      }
      String deliveryDate;
      if (order.cancelled.get(0).statusDate != null) {
        if (order.cancelled.get(0).statusDate.month != null) {
          deliveryDate =
            order.cancelled.get(0).statusDate.month +
            '/' +
            order.cancelled.get(0).statusDate.day +
            '/' +
            order.cancelled.get(0).statusDate.year;
        } else {
          deliveryDate = 'N/A';
        }
      } else {
        deliveryDate = 'N/A';
      }
      if (isUserAuthenticated) {
        if (order.orderNumber.startsWith('D')) {
          switch on order.orderStatus.toUpperCase() {
            when 'CANCELLED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.orderDetailsButton = orderDetailsButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
            //added condition to include 'canceled' status as well to show carousel card DP-48512
            when 'CANCELED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;
              orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.orderDetailsButton = orderDetailsButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
        } else {
          switch on order.orderStatus.toUpperCase() {
            when 'CANCELLED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.orderDetailsButton = orderDetailsButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
            //added condition to include 'canceled' status as well to show carousel card DP-48512
            when 'CANCELED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;
              orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' style=\'width: 190px; color: #4e3844; font-size: 12px;\' class=\'button2\'>VIEW ORDER HISTORY</a>';

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.orderDetailsButton = orderDetailsButton;
              v.Id = counter;
              carousel.isAuthorized = true;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
        }
      } else {
        if (order.orderNumber.startsWith('D')) {
          switch on order.orderStatus.toUpperCase() {
            when 'CANCELLED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.displayPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
            //added condition to include 'canceled' status as well to show carousel card DP-48512
            when 'CANCELED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.displayPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel, true));
            }
          }
        } else {
          switch on order.orderStatus.toUpperCase() {
            when 'CANCELLED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
            //added condition to include 'canceled' status as well to show carousel card DP-48512
            when 'CANCELED' {
              String displayPrice = order.isDisplayDiscounts == true
                ? order.orderSummary.totalPaymentToBeCharged
                : order.orderSummary.orderTotal;

              VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
              v.orderNumber = order.orderNumber;
              v.orderPlacedDate = monthDateFormat(
                order.orderDate.year,
                order.orderDate.month,
                order.orderDate.day
              );
              v.itemQuantity = totalItems.toString();
              v.imageHTMLCompiled = imageHTMLCompiled;
              v.totalItemPrice = displayPrice;
              v.displayStatus = 'Cancelled';
              v.Id = counter;
              carousel.isAuthorized = false;
              carousel.details.add(v);
              System.debug('Carousel ==> ' + JSON.serialize(carousel));
            }
          }
        }
      }

      // payloads.add(payloadCard);
      counter++;

      finalDynamicPayload = JSON.serialize(carousel, true);
      System.debug(
        LoggingLevel.DEBUG,
        'printing the payload' + finalDynamicPayload
      );
    }
    return finalDynamicPayload;
  }
  //for parent order carousels

  //method will return the images array to be displayed on carousel.
  // total no of images to display = imageCounter
  private static String getImagesArray(
    List<String> imageHTML,
    integer imageCounter
  ) {
    String imageHTMLCompiled = '';
    Integer totalImagesToShow = 0;
    for (String HTML : imageHTML) {
      totalImagesToShow = totalImagesToShow + 1;
      imageHTMLCompiled = imageHTMLCompiled + HTML;
      if (totalImagesToShow == imageCounter) {
        break;
      }
    }
    return imageHTMLCompiled;
  }

  //get carousel payload speciifc to 'RETURNED' status and one shipment.
  public static String getReturnShipmentCarouselPayload(
    NF_OrderServiceN.OrderResponse order,
    Boolean isUserAuthenticated,
    String status,
    String language
  ) {
    String finalDynamicPayload;
    VSCCS_CarouselOrderDetails.Carousel carousel = new VSCCS_CarouselOrderDetails.Carousel(
      language
    );
    List<String> payloads = new List<String>();
    if (order.shipments != null) {
      Integer counter = 1;
      Integer items = 0;
      String imageHTMLCompiled = '';
      List<String> imageHTML = new List<String>();
      String orderDetailsButton = '<a href=\'https://www.victoriassecret.com/us/account/profile#orders\' class=\'button2\'>VIEW ORDER HISTORY</a>';
      String payloadCard = '';

      for (NF_OrderServiceN.shipments shipment : order.shipments) {
        // String totalItemPrice = order.orderSummary.orderTotal;
        String totalItemPrice = order.isDisplayDiscounts == true
          ? order.orderSummary.totalPaymentToBeCharged
          : order.orderSummary.orderTotal;
        Decimal totalPrice = 0.00;
        String itemCurrency;
        String shipmentButton = '';
        String overwriteOrderStatus = null;
        if (
          String.isNotBlank(shipment.shipmentTrackingURL) &&
          status != 'RETURNED'
        )
          shipmentButton =
            '<a href=\'' +
            shipment.shipmentTrackingURL +
            '\' target=\'_blank\' class=\'button1\'>TRACK SHIPMENT</a>';
        for (NF_OrderServiceN.lineItems item : shipment.lineItems) {
          items = items + item.quantity.selected;
          if (item.productImage == null) {
            item.productImage = 'tif/c0/c4/c0c4a82db61949b49ffbd2875c0315ac/406009M7H_OM_F';
          }
          imageHTML.add(
            '<img src=\'https://www.victoriassecret.com/p/404x539/' +
              item.productImage +
              '.jpg\' width=\'42\' height=\'55\'>'
          );
          //if multiple shipment : Total will be based on individual shipment's lineitems prices.
          if (order.shipments.size() > 1) {
            String lineItemPrice = item.price.totalPrice.originalPrice;
            lineItemPrice = lineItemPrice.deleteWhitespace();
            lineItemPrice = lineItemPrice.replaceAll('[^0-9.]', '');

            Decimal individualPrice = Decimal.valueOf(lineItemPrice);
            totalPrice = totalPrice + individualPrice.setScale(2);
            itemCurrency = '$';
          }
        }

        if (order.shipments.size() > 1) {
          totalItemPrice = itemCurrency + String.valueOf(totalPrice);
        }
        Integer totalImagesToShow = 0;
        for (String HTML : imageHTML) {
          totalImagesToShow = totalImagesToShow + 1;
          imageHTMLCompiled = imageHTMLCompiled + HTML;
          if (totalImagesToShow == 3) {
            break;
          }
        }
        if (isUserAuthenticated) {
          if (order.orderNumber.startsWith('D')) {
            switch on status {
              when 'RETURNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING RETURN' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'CARRIER SCANNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING APPROVAL' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'RECEIVED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          } else {
            switch on status {
              when 'RETURNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.orderPlacedDate = monthDateFormat(
                  order.orderDate.year,
                  order.orderDate.month,
                  order.orderDate.day
                );
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus =
                  'Return Processed on:' +
                  shipment.statusDate.month +
                  '/' +
                  shipment.statusDate.day +
                  '/' +
                  shipment.statusDate.year;
                v.orderDetailsButton = orderDetailsButton;
                v.Id = counter;
                carousel.isAuthorized = true;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          }
        } else {
          if (order.orderNumber.startsWith('D')) {
            switch on status {
              when 'RETURNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refunded';
                v.shipmentButton = shipmentButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING RETURN' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Return Initiated';
                v.shipmentButton = shipmentButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'CARRIER SCANNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Package with Carrier';
                v.shipmentButton = shipmentButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'PENDING APPROVAL' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refund Pending';
                v.shipmentButton = shipmentButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
              when 'RECEIVED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus = 'Refund in Process';
                v.shipmentButton = shipmentButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          } else {
            switch on status {
              when 'RETURNED' {
                VSCCS_CarouselOrderDetails.OrderDetails v = new VSCCS_CarouselOrderDetails.OrderDetails();
                v.orderNumber = order.orderNumber;
                v.orderPlacedDate = monthDateFormat(
                  order.orderDate.year,
                  order.orderDate.month,
                  order.orderDate.day
                );
                v.itemQuantity = items.toString();
                v.imageHTMLCompiled = imageHTMLCompiled;
                v.totalItemPrice = totalItemPrice;
                v.displayStatus =
                  'Return Processed on ' +
                  shipment.statusDate.month +
                  '/' +
                  shipment.statusDate.day +
                  '/' +
                  shipment.statusDate.year;
                v.shipmentButton = shipmentButton;
                v.Id = counter;
                carousel.isAuthorized = false;
                carousel.details.add(v);
                System.debug('Carousel ==> ' + JSON.serialize(carousel));
              }
            }
          }
        }
      }

      // payloads.add(payloadCard);
      counter++;

      finalDynamicPayload = JSON.serialize(carousel, true);
      System.debug(
        LoggingLevel.DEBUG,
        'printing the payload' + finalDynamicPayload
      );
    }
    return finalDynamicPayload;
  }

  public static String monthDateFormat(
    Integer year,
    Integer month,
    Integer day
  ) {
    Datetime d1 = Datetime.newInstance(year, month, day);
    return (d1.format('MMM') + ' ' + d1.format('dd'));
  }

  public static string orderStatusUIText(string orderStatus) {
    String uiText;
    uiText = (orderStatus == 'Backordered'
      ? (orderStatus + ' until ')
      : (orderStatus + ' on '));
    return uiText;
  }
}