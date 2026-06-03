/*****************************************************************************************************@@
Class Name     :  NF_AuthUserOrderLookup
Purpose        :  Class to serialize order api response for auth customer.(used by chatbot)
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      	TICKET REFERENCE/ NO.
1.       apoorv                09/3/2020             Original Version             			-
2.       Manishi               09/03/2021            Adding new api paramters               DP-39915
3.       Manishi               09/08/2021            mapping new api paramters for 
													 single orders                			DP-47463
4.       Himanshu              02/28/2025            Adding MIAW Changes                    DP-91108

@Testsuite:  {NF_AuthUserOrderLookupTest}        
*********************************************************************************************************/
public with sharing class NF_AuthUserOrderLookup {
  public class Input {
    @InvocableVariable(required=false)
    public String routableId;

    @InvocableVariable(required=false)
    public String emailAddress;

    @InvocableVariable(required=false)
    public Boolean isOrderFlow = false;
  }

  public class Output {
    @invocableVariable
    public Integer returnCode;

    @InvocableVariable
    public String failReason;

    @InvocableVariable
    public List<NF_OrderServiceN.ListOfOrderResponse> listOfOrders = new List<NF_OrderServiceN.ListOfOrderResponse>();

    @InvocableVariable
    public String serializedString;

    @InvocableVariable
    public Integer orderResponseSize = 0;

    @InvocableVariable
    public String serializedOrder;

    @InvocableVariable
    public NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();

    @InvocableVariable
    public List<NF_OrderServiceN.ListOfOrderResponse> listOfRecent5Orders = new List<NF_OrderServiceN.ListOfOrderResponse>();

    @InvocableVariable
    public String recent5OrdersSerializedString;

    /* DP-39915 adding new api parameters starts */
    @InvocableVariable
    public Boolean isOnHold;

    @InvocableVariable
    public Boolean isCancelEligible;

    @InvocableVariable
    public Boolean isModifyEligible;

    @InvocableVariable
    public String holdType;

    @InvocableVariable
    public Boolean isAwaitingPaymentProcess;
    /* DP-39915 adding new api parameters ends */

    //NF_OrderServiceN.OrderResponse
  }

  @InvocableMethod(label='Neuraflash - Get Order History Authenticated User')
  public static List<Output> getOrderHistoryForAuthenticatedUser(
    List<Input> input
  ) {
    System.debug(LoggingLevel.DEBUG, 'In the method to get order details');
    List<Output> outputList = new List<Output>();
    Output output = new Output();

    Boolean isOrderFlow = input[0].isOrderFlow;
    System.debug(
      LoggingLevel.DEBUG,
      'NF_AuthUserOrderLookup: isOrderFlow=' + isOrderFlow
    );

    String email = input[0].emailAddress;
    System.debug(LoggingLevel.DEBUG, 'NF_AuthUserOrderLookup: email=' + email);

    try {
      MessagingSession transcript = NF_Util.getMessagingSession(
        input[0].routableId
      );

      if (transcript != null) {
        String encryptedToken = transcript.JWT_Token__c;
        System.debug(
          LoggingLevel.DEBUG,
          'NF_AuthUserOrderLookup: encryptedToken=' + encryptedToken
        );
        NF_OrderHistoryAPI.chatKey = input[0] != null
          ? input[0].routableId
          : null;
        // NF_OrderServiceN.APIResponse apiResponse = NF_OrderHistoryAPI.orders(
        //   encryptedToken,
        //   75
        // );

        NF_OrderServiceN.APIResponse apiResponse = NF_OrderHistoryAPI.searchOrderX(
          email
        );

        NF_OrderHistoryAPI.chatKey = null;
        System.debug(LoggingLevel.DEBUG, 'apiResponse:' + apiResponse);
        if (String.isNotBlank(apiResponse.responseError)) {
          if (
            apiResponse.responseError.contains(
              'Please re-enter the information'
            )
          ) {
            output.failReason = 'NO_ORDERS_FOUND';
          }
          System.debug(LoggingLevel.INFO, 'Lookup did not return any orders.');
          output.returnCode = -1;
        } else {
          Integer orderCount = 0;
          System.debug(LoggingLevel.DEBUG, 'size:' + apiResponse.orders.size());

          for (
            NF_OrderServiceN.ListOfOrderResponse eachOrder : apiResponse.orders
          ) {
            System.debug(
              LoggingLevel.DEBUG,
              'NF_AuthUserOrderLookup: eachOrder=' + eachOrder
            );

            if (orderCount == 4 && !isOrderFlow) {
              output.listOfRecent5Orders.add(
                NF_OrderUtil.formatOrderForMenu(eachOrder)
              );
              break;
            } else if (orderCount == 5 && isOrderFlow) {
              break;
            } else {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: eachOrder.orderDate=' +
                eachOrder.orderDate
              );

              /* start of LBRAN-64 */
              String[] orderDateArray = eachOrder.orderDate.split(',');
              eachOrder.orderDate = orderDateArray[0].remove('.');
              eachOrder.orderDate = eachOrder.orderDate.toUpperCase();
              /* end of LBRAN-64 */

              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: eachOrder.orderDateTime=' +
                eachOrder.orderDateTime
              );
              String[] orderDateTimeArray = eachOrder.orderDateTime.split('T');
              Date convertedDate = Date.valueOf(orderDateTimeArray[0]);
              Date todayDate = System.today();
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: daysBetween=' +
                convertedDate.daysBetween(todayDate)
              );
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
          system.debug(
            'output.listOfOrders>>>' +
              output.listOfOrders.size() +
              'isOrderFlow>>>>' +
              isOrderFlow
          );
          //   if (!isOrderFlow && output.listOfOrders.size() > 1) {
          //     //|| (isOrderFlow && output.listOfOrders.size() <5)
          //     NF_OrderServiceN.ListOfOrderResponse eachOrder = new NF_OrderServiceN.ListOfOrderResponse();
          //     eachOrder.orderPlaceholder1 = 'Ask ';
          //     eachOrder.orderPlaceholder2 = 'something ';
          //     eachOrder.orderPlaceholder3 = 'else';
          //     output.listOfOrders.add(eachOrder);
          //   }
          //Home Try On addition
          if (!isOrderFlow && output.listOfOrders.size() > 1) {
            NF_OrderServiceN.ListOfOrderResponse eachOrder2 = new NF_OrderServiceN.ListOfOrderResponse();
            eachOrder2.orderPlaceholder1 = 'Home';
            eachOrder2.orderPlaceholder2 = 'Try-On ';
            eachOrder2.orderPlaceholder3 = 'Orders';
            output.listOfOrders.add(eachOrder2);
          }
          if (isOrderFlow && output.listOfOrders.size() > 1) {
            //|| (isOrderFlow && output.listOfOrders.size() <5)
            NF_OrderServiceN.ListOfOrderResponse eachOrder = new NF_OrderServiceN.ListOfOrderResponse();
            eachOrder.orderPlaceholder1 = 'Check a ';
            eachOrder.orderPlaceholder2 = 'different ';
            eachOrder.orderPlaceholder3 = 'order';
            output.listOfOrders[output.listOfOrders.size() - 1] = eachOrder;
          }

          System.debug(
            LoggingLevel.DEBUG,
            'NF_AuthUserOrderLookup: output.listOfOrders size>>>' +
            output.listOfOrders.size()
          );
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
            /* DP-47463 mapping of new api parameters */
            output.isOnHold = order.isOnHold;
            output.isCancelEligible = order.isCancelEligible;
            output.isModifyEligible = order.isModifyEligible;
            output.holdType = order.holdTypeId;
            output.isAwaitingPaymentProcess = order.isAwaitingPaymentProcess;
            System.debug(
              LoggingLevel.DEBUG,
              'NF_AuthUserOrderLookup: get single order details, orderStatus=[' +
                orderStatus +
                '], orderNumber=[' +
                order.orderNumber +
                '], email=[' +
                email +
                ']'
            );

            NF_OrderServiceN.APIResponse apiResponseSingle;

            /*added OrderFlow condition for LBRAN-253, if her has just single Canceled order and
             wanted to ask about Cancel order, we want to show the card unlike greeting.*/
            if ('Canceled'.equalsIgnoreCase(orderStatus) && !isOrderFlow) {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: canceled order, do not look up details'
              );

              //we don't want to look up order details for a canceled order, so lets fake out the response object
              apiResponseSingle = new NF_OrderServiceN.APIResponse();
              apiResponseSingle.order = new NF_OrderServiceN.OrderResponse();
              apiResponseSingle.order.orderStatus = orderStatus;

              //fake out a success response
              apiResponseSingle.statusCode = 200;
              //output.order = new NF_OrderServiceN.APIResponse().OrderResponse();
            } else {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: get single order details, perform lookup'
              );
              NF_OrderHistoryAPI.chatKey = input[0] != null
                ? input[0].routableId
                : null;
              apiResponseSingle = NF_OrderHistoryAPI.orderByIdAndEmail(
                order.orderNumber,
                email,
                false
              );
              NF_OrderHistoryAPI.chatKey = null;
              System.debug(
                LoggingLevel.DEBUG,
                'apiResponseSingle' + apiResponseSingle
              );
            }

            System.debug(
              LoggingLevel.DEBUG,
              'NF_AuthUserOrderLookup: apiResponseSingle.statusCode=' +
              apiResponseSingle.statusCode
            );
            if (apiResponseSingle.statusCode == 200) {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: apiResponseSingle>>>' +
                apiResponseSingle
              );
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: apiResponseSingle.order>>>' +
                apiResponseSingle.order
              );
              output.order = apiResponseSingle.order;
              output.serializedOrder = JSON.serialize(output.order, false);
              System.debug(
                LoggingLevel.DEBUG,
                'output.serializedOrder>>>' + output.serializedOrder
              );
            } else {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_AuthUserOrderLookup: details failed, return 0 orders'
              );
              output.orderResponseSize = 0;
            }
          }
          System.debug(
            LoggingLevel.DEBUG,
            'NF_AuthUserOrderLookup >> listOfOrders=' +
            output.listOfOrders.toString()
          );
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

    outputList.add(output);
    return outputList;
  }
}