/*****************************************************************************************************@@
Class Name     :  NF_GetOrderDetails
Purpose        :  Class to serialize and get the order deatils from the order api response (used by chatbot)
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      	TICKET REFERENCE/ NO.
1.       apoorv                08/31/2020             Original Version             			-
2.       Manishi               09/03/2021            Adding new api paramters               DP-39915

@Testsuite:  {NF_GetOrderDetailsTest}        
*********************************************************************************************************/
public with sharing class NF_GetOrderDetails {
  public class Input {
    @InvocableVariable(required=false)
    public String chatKey;

    @InvocableVariable(required=false)
    public String email;

    @InvocableVariable(required=false)
    public String serializedOrder;

    @InvocableVariable
    public String language;
  }

  public class Output {
    @InvocableVariable
    public Boolean isClaimProcessed;

    //        @InvocableVariable
    //        public Boolean hasParentOrder;

    @InvocableVariable
    public String orderPrefix;

    //        @InvocableVariable
    //        public String parentOrderStatus;

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
  }

  @InvocableMethod(label='Neuraflash - Get Order Details')
  public static List<Output> getOrderDetails(List<Input> input) {
    List<Output> outputs = new List<Output>();
    Output out = new Output();
    outputs.add(out);

    String chatKey = input[0].chatKey;
    //System.debug( input[0].listOrder.toString());
    out.isOrderRemorse = false;
    NF_OrderServiceN.OrderResponse order = (NF_OrderServiceN.OrderResponse) JSON.deserialize(
      input[0].serializedOrder,
      NF_OrderServiceN.OrderResponse.class
    );
    System.debug(
      LoggingLevel.DEBUG,
      'NF_GetOrderDetails: input[0].serializedOrder=' + input[0].serializedOrder
    );
    System.debug(LoggingLevel.DEBUG, 'NF_GetOrderDetails: order=' + order);

    try {
      //if we have a valid order that is not canceled
      out.orderNumber = order.orderNumber;

      /* DP-39915 mapping new api parameters */
      out.isOnHold = order.isOnHold;
      out.isCancelEligible = order.isCancelEligible;
      out.isModifyEligible = order.isModifyEligible;
      out.holdType = order.holdTypeId;
      out.isAwaitingPaymentProcess = order.isAwaitingPaymentProcess;

      if (order != null) {
        if ('CANCELED'.equalsIgnoreCase(order.orderStatus)) {
          System.debug(
            LoggingLevel.DEBUG,
            'NF_GetOrderDetails: Canceled order, returning'
          );

          out.orderStatus = order.orderStatus.toUpperCase();
          out.isCanceled = true;
        } else {
          out.shipments = order.shipments;
          out.isClaimProcessed = false;

          System.debug(
            LoggingLevel.DEBUG,
            'NF_GetOrderDetails: order.orderStatus=' + order.orderStatus
          );
          if (order.orderStatus != null) {
            out.orderStatus = order.orderStatus.toUpperCase();
          }

          out.isOrderRemorse = order.isInRemorse();
          out.isBackordered = order.hasShipmentStatus('backordered');
          out.isReturned = order.hasShipmentStatus('returned');

          // generate the Carousal payload
          String carousalPayload = NF_DynamicCarouselContentFactory.getCarouselPayloadInfo(
            order,
            true,
            out.orderPrefix,
            'en_US'
          );
          System.debug(
            LoggingLevel.DEBUG,
            'Carousel PAYLOAD' + carousalPayload
          );

          // append the data to the bot session for carousal
          if (
            chatKey.startswith(
              MessagingSession.sobjecttype.getDescribe().getKeyPrefix()
            )
          ) {
            Messaging_Insight__c session = NF_Util.getMessagingInsight(input[0].chatKey);
            if (session != null) {
              System.debug(LoggingLevel.DEBUG, 'session found');
              session.CarouselContent__c = carousalPayload;
              update session;
              System.debug(
                LoggingLevel.DEBUG,
                'Updated field>>>' + session.CarouselContent__c
              );
            } else {
              System.debug(LoggingLevel.DEBUG, 'session not found');
              NF_Util.insertMessagingInsight(
                input[0].chatKey,
                carousalPayload
              );
            }
          } else {
            Messaging_Insight__c session = NF_Util.getMessagingInsight(
              input[0].chatKey
            );
            if (session != null) {
              System.debug(LoggingLevel.DEBUG, 'session found');
              session.CarouselContent__c = carousalPayload;
              update session;
              System.debug(
                LoggingLevel.DEBUG,
                'Updated field>>>' + session.CarouselContent__c
              );
            } else {
              System.debug(LoggingLevel.DEBUG, 'session not found');
              NF_Util.insertMessagingInsight(input[0].chatKey, carousalPayload);
            }
          }
        }
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.DEBUG,
        'NF_GetOrderDetails: exception= Line (' +
          e.getLineNumber() +
          '): ' +
          e.getMessage()
      );
    }

    System.debug(
      LoggingLevel.DEBUG,
      'NF_GetOrderDetails: returning outputs=' + outputs
    );

    return outputs;
  }
}