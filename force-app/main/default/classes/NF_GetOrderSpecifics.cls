/*****************************************************************************************************@@
Class Name     :  NF_GetOrderSpecifics
Purpose        :  Class to serialize and get the order deatils from the order api response (used by order status flow in chatbot)
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      	TICKET REFERENCE/ NO.
1.       apoorv                08/31/2020             Original Version             			-
2.       Manishi               09/03/2021            Adding new api paramters               DP-39915

@Testsuite:  {NF_GetOrderSpecificsTest}        
*********************************************************************************************************/
public with sharing class NF_GetOrderSpecifics {
  public class Input {
    @InvocableVariable(required=false)
    public String chatKey;

    @InvocableVariable(required=false)
    public String email;

    @InvocableVariable(required=false)
    public String serializedOrders;

    @InvocableVariable
    public NF_OrderServiceN.OrderResponse order;

    @InvocableVariable
    public NF_OrderServiceN.ListOfOrderResponse listOrder;

    @InvocableVariable(required=false)
    public Integer orderResponseSize;

    @InvocableVariable
    public Boolean isUserAuthenticated;

    @InvocableVariable
    public String chatUserLanguage;
  }

  public class Output {
    @InvocableVariable
    public Boolean isClaimProcessed;

    //@InvocableVariable
    //public Boolean hasParentOrder;

    @InvocableVariable
    public String orderPrefix;
    //@InvocableVariable
    //public String parentOrderStatus;

    @InvocableVariable
    public String orderStatus;

    @InvocableVariable
    public List<NF_OrderServiceN.shipments> shipments = new List<NF_OrderServiceN.shipments>();

    @InvocableVariable
    public List<NF_OrderServiceN.Lshipments> listOfShipments = new List<NF_OrderServiceN.Lshipments>();

    @InvocableVariable
    public Boolean isOrderRemorse;

    @InvocableVariable
    public Boolean isBackordered;

    @InvocableVariable
    public Boolean isReturned;

    @invocableVariable
    public Integer returnCode;

    @InvocableVariable
    public Boolean isCanceled;

    @InvocableVariable
    public String orderNumber;

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

    @InvocableVariable
    public String carouselPayload;
  }

  @InvocableMethod(label='Neuraflash - Get Order Specifics')
  public static List<Output> isClaimProcessed(List<Input> input) {
    List<Output> outputs = new List<Output>();
    try {
      Output out = new Output();

      String chatKey = input[0].chatKey;

      String email = input[0].email;

      out.isOrderRemorse = false;

      System.debug('orderResponseSize :: ' + input[0].orderResponseSize);

      if (input[0].orderResponseSize == 1) {
        NF_OrderServiceN.OrderResponse orderResponse = (NF_OrderServiceN.OrderResponse) JSON.deserialize(
          input[0].serializedOrders,
          NF_OrderServiceN.OrderResponse.class
        );
        if (orderResponse.orderNumber == input[0].order.orderNumber) {
          out.orderNumber = orderResponse.orderNumber;
          out.orderStatus = orderResponse.orderStatus.toUpperCase();

          /* DP-39915 mapping new api parameters starts */
          out.isOnHold = orderResponse.isOnHold;
          out.isCancelEligible = orderResponse.isCancelEligible;
          out.isModifyEligible = orderResponse.isModifyEligible;
          out.holdType = orderResponse.holdTypeId;
          out.isAwaitingPaymentProcess = orderResponse.isAwaitingPaymentProcess;

          /* DP-39915 mapping new api parameters ends */

          if (
            'CANCELED'.equalsIgnoreCase(orderResponse.orderStatus) ||
            'CANCELLED'.equalsIgnoreCase(orderResponse.orderStatus)
          ) {
            System.debug(
              LoggingLevel.DEBUG,
              'NF_GetOrderDetails: Canceled order, returning'
            );
            out.isCanceled = true;
          }

          // LBRAN-256
          String[] orderDateTimeArray = orderResponse.orderDateTime.split('T');
          Date orderDate = Date.valueOf(orderDateTimeArray[0]);
          Date today = System.today();
          if (orderDate.daysBetween(today) > 90) {
            System.debug(
              LoggingLevel.DEBUG,
              'NF_GetOrderSpecifics >> Attempted to get order older than 90 days, returning failure'
            );
            out.returnCode = -1;
            outputs.add(out);
            return outputs;
          }

          // add the order to the response.
          out.shipments = orderResponse.shipments;
          out.isClaimProcessed = false;

          /* DP-32473 */
          out.isOrderRemorse = orderResponse.isInRemorse();
          out.isBackordered = orderResponse.hasShipmentStatus('backordered');
          out.isReturned = orderResponse.hasShipmentStatus('returned');
          // outputs.add(out);

          // generate the Carousal payload
          String carousalPayload = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(
            orderResponse,
            input[0].isUserAuthenticated,
            out.orderPrefix,
            input[0].chatUserLanguage
          );

          out.carouselPayload = carousalPayload;
          System.debug('---> ' + out.carouselPayload);
          outputs.add(out);

          //   setCarouselOnSession(input[0].chatKey, carousalPayload);
          // System.debug(
          //   'Is Messaging Session :: ' +
          //   chatKey.startswith(
          //     MessagingSession.sobjecttype.getDescribe().getKeyPrefix()
          //   )
          // );

          if (
            chatKey.startswith(
              MessagingSession.sobjecttype.getDescribe().getKeyPrefix()
            )
          ) {
            setCarouselOnMessagingSessionInsight(
              input[0].chatKey,
              carousalPayload
            );
          } else {
            setCarouselOnSession(input[0].chatKey, carousalPayload);
          }
        }
      } else if (input[0].orderResponseSize > 1) {
        System.debug(
          LoggingLevel.DEBUG,
          'NF_GetOrderSpecifics: multiple orders'
        );
        List<NF_OrderServiceN.ListOfOrderResponse> listOfOrders = (List<NF_OrderServiceN.ListOfOrderResponse>) JSON.deserialize(
          input[0].serializedOrders,
          List<NF_OrderServiceN.ListOfOrderResponse>.class
        );
        for (NF_OrderServiceN.ListOfOrderResponse eachOrder : listOfOrders) {
          if (eachOrder.orderNumber == input[0].listOrder.orderNumber) {
            System.debug(
              LoggingLevel.DEBUG,
              'NF_GetOrderSpecifics: eachOrder=' + eachOrder
            );
            out.orderStatus = eachOrder.orderStatus.toUpperCase();
            out.orderNumber = eachOrder.orderNumber;

            /* DP-39915 mapping new api parameters starts */
            out.isOnHold = eachOrder.isOnHold;
            out.isCancelEligible = eachOrder.isCancelEligible;
            out.isModifyEligible = eachOrder.isModifyEligible;
            out.holdType = eachOrder.holdTypeId;
            out.isAwaitingPaymentProcess = eachOrder.isAwaitingPaymentProcess;
            /* DP-39915 mapping new api parameters ends */

            if (
              'CANCELED'.equalsIgnoreCase(eachOrder.orderStatus) ||
              'CANCELLED'.equalsIgnoreCase(eachOrder.orderStatus)
            ) {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_GetOrderDetails: Canceled order, returning'
              );
              out.isCanceled = true;
            }

            out.listOfShipments = eachOrder.shipments;
            out.isClaimProcessed = false;

            System.debug(
              LoggingLevel.DEBUG,
              'NF_GetOrderSpecifics: calculated orderStatus=' +
              eachOrder.calculatedOrderStatus
            );

            out.isOrderRemorse = eachOrder.isInRemorse();
            out.isBackordered = eachOrder.hasShipmentStatus('backordered');
            out.isReturned = eachOrder.hasShipmentStatus('returned');

            System.debug(
              LoggingLevel.DEBUG,
              'NF_GetOrderSpecifics: out=' + out
            );

            // generate the Carousal payload
            String carousalPayload = '';
            if (String.isBlank(email)) {
              System.debug(
                LoggingLevel.ERROR,
                'Email is required. Lookup cannot be performed'
              );
              out.returnCode = -1;
              return null;
            }
            // LBRAN-256
            String[] orderDateTimeArray = eachOrder.orderDateTime.split('T');
            Date orderDate = Date.valueOf(orderDateTimeArray[0]);
            Date today = System.today();
            if (orderDate.daysBetween(today) > 90) {
              System.debug(
                LoggingLevel.DEBUG,
                'NF_GetOrderSpecifics >> Attempted to get order older than 90 days, returning failure'
              );
              out.returnCode = -1;
              outputs.add(out);
              return outputs;
            }

            System.debug(
              LoggingLevel.DEBUG,
              'NF_GetOrderSpecifics: lookup order by email=[' +
                email +
                '], orderNumber=[' +
                eachOrder.orderNumber +
                ']'
            );
            NF_OrderHistoryAPI.chatKey = chatKey;
            NF_OrderServiceN.APIResponse newApiResponse = NF_OrderHistoryAPI.orderByIdAndEmail(
              eachOrder.orderNumber,
              email,
              true
            );
            NF_OrderHistoryAPI.chatKey = null;
            System.debug(
              LoggingLevel.DEBUG,
              'newApiResponse>>>' + newApiResponse
            );
            NF_OrderServiceN.OrderResponse apiResponse = newApiResponse.order;
            System.debug(
              LoggingLevel.DEBUG,
              'apiResponse.responseError>>>' + newApiResponse.responseError
            );
            if (String.isNotBlank(newApiResponse.responseError)) {
              System.debug(
                LoggingLevel.INFO,
                'Lookup did not return any orders.'
              );
              out.returnCode = -1;
            } else {
              carousalPayload = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(
                apiResponse,
                input[0].isUserAuthenticated,
                out.orderPrefix,
                input[0].chatUserLanguage
              );
            }

            out.carouselPayload = carousalPayload;
            System.debug('---> ' + out.carouselPayload);

            // setCarouselOnSession(input[0].chatKey, carousalPayload);

            if (
              chatKey.startswith(
                MessagingSession.sobjecttype.getDescribe().getKeyPrefix()
              )
            ) {
              setCarouselOnMessagingSessionInsight(
                input[0].chatKey,
                carousalPayload
              );
            } else {
              setCarouselOnSession(input[0].chatKey, carousalPayload);
            }
          }
        }
        outputs.add(out);
      }

      System.debug(
        LoggingLevel.DEBUG,
        'NF_GetOrderSpecifics: outputs=' + outputs
      );

      return outputs;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.DEBUG,
        'Exception occured>>>' +
          e.getMessage() +
          '>>>' +
          e.getStackTraceString()
      );
      return null;
    }
  }

  public static void setCarouselOnSession(String chatKey, String payload) {
    System.debug(
      LoggingLevel.DEBUG,
      'NF_GetOrderSpecifics: setSessionCarousel: chatKey=' + chatKey
    );
    System.debug(
      LoggingLevel.DEBUG,
      'NF_GetOrderSpecifics: setSessionCarousel: payload=' + payload
    );

    if (String.isNotEmpty(chatKey) && String.isNotEmpty(payload)) {
      Messaging_Insight__c session = NF_Util.getMessagingInsight(chatKey);
      if (session != null) {
        session.CarouselContent__c = payload;
        update session;
      } else {
        NF_Util.insertMessagingInsight(chatKey, payload);
      }
    }
  }

  public static void setCarouselOnMessagingSessionInsight(
    String routableId,
    String payload
  ) {
    System.debug(
      LoggingLevel.DEBUG,
      'NF_GetOrderSpecifics: setCarouselOnMessagingSessionInsight: routableId=' +
      routableId
    );
    System.debug(
      LoggingLevel.DEBUG,
      'NF_GetOrderSpecifics: setCarouselOnMessagingSessionInsight: payload=' +
      payload
    );

    if (String.isNotEmpty(routableId) && String.isNotEmpty(payload)) {
      Messaging_Insight__c session = NF_Util.getMessagingInsight(routableId);
      if (session != null) {
        session.CarouselContent__c = payload;
        update session;
      } else {
        NF_Util.insertMessagingInsight(routableId, payload);
      }
    }
  }
}