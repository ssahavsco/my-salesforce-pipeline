/*****************************************************************************************************@@
Class Name     :  NF_PreChatController
Purpose        :  Controller of the NF_CustomerCareBot_PreChatForm aura component
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      	TICKET REFERENCE/ NO.
1.       Tara                02/24/2021            Original Version             			DP-36414
2.       Manishi             03/09/2021            Modifying orderFlow paramter             DP-47309
3.       Himanshu            07/17/2025            MIAW changes                       DP-95647

@Testsuite:  {NF_PreChatControllerTest}        
*********************************************************************************************************/
public without sharing class NF_PreChatController {
  /**
   * @name getOrderHistoryForAuthenticatedUser
   *@description get the order history for logged in user
   */
  @AuraEnabled
  public static String getOrderHistoryForAuthenticatedUser(
    String email,
    Boolean isOrderFlow
  ) {
    NF_AuthUserOrderLookup.Output output = new NF_AuthUserOrderLookup.Output();
    try {
      /* DP-47309 starts modifying orderFlow parameter for pre-chat form */
      if (!Test.isRunningTest()) {
        isOrderFlow = false;
      }

      /* DP-47309 starts */
      NF_OrderServiceN.APIResponse apiResponse = NF_OrderHistoryAPI.searchOrderX(
        email
      );
      System.debug(
        LoggingLevel.DEBUG,
        'NF_PreChatController apiResponse:' + apiResponse
      );
      if (String.isNotBlank(apiResponse.responseError)) {
        if (
          apiResponse.responseError.contains('Please re-enter the information')
        ) {
          output.failReason = 'NO_ORDERS_FOUND';
        }
        output.returnCode = -1;
      } else {
        Integer orderCount = 0;

        for (
          NF_OrderServiceN.ListOfOrderResponse eachOrder : apiResponse.orders
        ) {
          if (orderCount == 4 && !isOrderFlow) {
            output.listOfRecent5Orders.add(
              NF_OrderUtil.formatOrderForMenu(eachOrder)
            );
            break;
          } else if (orderCount == 5 && isOrderFlow) {
            break;
          } else {
            String[] orderDateArray = eachOrder.orderDate.split(',');
            eachOrder.orderDate = orderDateArray[0].remove('.');
            eachOrder.orderDate = eachOrder.orderDate.toUpperCase();

            String[] orderDateTimeArray = eachOrder.orderDateTime.split('T');
            Date convertedDate = Date.valueOf(orderDateTimeArray[0]);
            Date todayDate = System.today();
            if (isOrderFlow) {
              if (
                convertedDate.daysBetween(todayDate) >= 0 &&
                convertedDate.daysBetween(todayDate) < 90
              ) {
                orderCount = orderCount + 1;
                output.listOfOrders.add(
                  NF_OrderUtil.formatOrderForMenu(eachOrder)
                );
              }
            } else {
              //means it is at greeting flow
              if (
                convertedDate.daysBetween(todayDate) >= 0 &&
                convertedDate.daysBetween(todayDate) < 14
              ) {
                orderCount = orderCount + 1;
                output.listOfOrders.add(
                  NF_OrderUtil.formatOrderForMenu(eachOrder)
                );
                output.listOfRecent5Orders.add(
                  NF_OrderUtil.formatOrderForMenu(eachOrder)
                );
              }
            }
          }
        }
        if (!isOrderFlow && output.listOfOrders.size() > 1) {
          NF_OrderServiceN.ListOfOrderResponse eachOrder2 = new NF_OrderServiceN.ListOfOrderResponse();
          eachOrder2.orderPlaceholder1 = 'Home ';
          eachOrder2.orderPlaceholder2 = 'Try On ';
          eachOrder2.orderPlaceholder3 = 'Orders';
          output.listOfOrders.add(eachOrder2);
        }
        if (!isOrderFlow && output.listOfOrders.size() > 1) {
          //|| (isOrderFlow && output.listOfOrders.size() <5)
          NF_OrderServiceN.ListOfOrderResponse eachOrder = new NF_OrderServiceN.ListOfOrderResponse();
          eachOrder.orderPlaceholder1 = 'Ask ';
          eachOrder.orderPlaceholder2 = 'something ';
          eachOrder.orderPlaceholder3 = 'else';
          output.listOfOrders.add(eachOrder);
        }
        if (isOrderFlow && output.listOfOrders.size() > 1) {
          //|| (isOrderFlow && output.listOfOrders.size() <5)
          NF_OrderServiceN.ListOfOrderResponse eachOrder = new NF_OrderServiceN.ListOfOrderResponse();
          eachOrder.orderPlaceholder1 = 'Check a ';
          eachOrder.orderPlaceholder2 = 'different ';
          eachOrder.orderPlaceholder3 = 'order';
          output.listOfOrders[output.listOfOrders.size() - 1] = eachOrder;
        }

        //output.listOfOrders.addAll(apiResponse);
        output.serializedString = JSON.serialize(output.listOfOrders, false);
        output.recent5OrdersSerializedString = JSON.serialize(
          output.listOfRecent5Orders,
          false
        );
        output.orderResponseSize = output.listOfOrders.size();
        if (output.orderResponseSize == 1) {
          //output.order = apiResponse.orders.get(0);

          NF_OrderServiceN.ListOfOrderResponse order = output.listOfOrders.get(
            0
          );
          String orderStatus = order.orderStatus;
          output.isOnHold = order.isOnHold;
          output.isCancelEligible = order.isCancelEligible;
          output.isModifyEligible = order.isModifyEligible;
          output.holdType = order.holdTypeId;
          output.isAwaitingPaymentProcess = order.isAwaitingPaymentProcess;
          NF_OrderServiceN.APIResponse apiResponseSingle;

          /*added OrderFlow condition for LBRAN-253, if her has just single Canceled order and
           wanted to ask about Cancel order, we want to show the card unlike greeting.*/
          if ('Canceled'.equalsIgnoreCase(orderStatus) && !isOrderFlow) {
            //we don't want to look up order details for a canceled order, so lets fake out the response object
            apiResponseSingle = new NF_OrderServiceN.APIResponse();
            apiResponseSingle.order = new NF_OrderServiceN.OrderResponse();
            apiResponseSingle.order.orderStatus = orderStatus;

            //fake out a success response
            apiResponseSingle.statusCode = 200;
            //output.order = new NF_OrderServiceN.APIResponse().OrderResponse();
          } else {
            apiResponseSingle = NF_OrderHistoryAPI.orderByIdAndEmail(
              order.orderNumber,
              email,
              false
            );
            NF_OrderHistoryAPI.chatKey = null;
          }

          if (apiResponseSingle.statusCode == 200) {
            output.order = apiResponseSingle.order;
            output.serializedOrder = JSON.serialize(output.order, false);
          } else {
            output.orderResponseSize = 0;
          }
        }
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.DEBUG,
        'NF_AuthUserOrderLookup: exception= Line (' +
          e.getLineNumber() +
          '): ' +
          e.getMessage()
      );
      //if something went wrong, we'll treat it as if we have no orders
      output.orderResponseSize = 0;
    }

    Pre_Chat_Detail__c pcd = new Pre_Chat_Detail__c();
    /*String tokenValue;
    if (encryptedToken.length() > 240) {
      tokenValue =
        encryptedToken.substring(0, 120) +
        encryptedToken.substring(
          encryptedToken.length() - 120,
          encryptedToken.length()
        );
    } else {
      tokenValue = encryptedToken;
    }*/
    pcd.Email__c = email;
    List<Pre_Chat_Detail__c> existingPCDList = [
      SELECT Id
      FROM Pre_Chat_Detail__c
      WHERE Email__c = :email
      ORDER BY createdDate DESC
      LIMIT 1
    ];
    if (existingPCDList != null && !existingPCDList.isEmpty()) {
      pcd.Id = existingPCDList[0].Id;
    }
    pcd.Order_History_Response__c = JSON.serialize(output);
    upsert pcd;

    return pcd.Order_History_Response__c;
  }
}