/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Controller class for phistOrderTransactionSearch
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
 * @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
 * @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
 * @version        1.0
 * @created        2021-04-05
 * @modified       2021-09-16
 * @systemLayer    Controller
 * @see            ????
 * @see            ????
 * @Jira Number    DP-37110, DP-37111, DP-37112, DP-37113, DP-37114, DP-37115, DP-37116, DP-37188,
 *                 DP-37466, DP-37468
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @changes
 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-04-14      code commenting

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-04-15      added method getCaseDataStateful()

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-04-16      updated method createOrderTransactions()

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-04-19      updated method getCaseDataStateful()

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-04-21      updated method getCaseDataStateful()

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-05-06      added status matrix map in the initit response

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-05-14      updated methods to use Account record as customer instead of Contact record

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-05-24      updated duplicate logic for Store Transaction records

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-05-27      added new mapping for digital orders

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-05-31      updated getTabAndStatefulData() method

 * v1.0            ravikant.kedia@neuraflash.com
 * 2021-09-16      updated mapping for Order_Transaction__c.Price_Paid__c field

 * v1.0            ssaha@lb.com
 * 2022-01-18      DP-50494
 * 
 *  v1.0            ssaha@lb.com
 * 2022-03-14      DP-64822
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public without sharing class PHISTOrderTransactionSearch {
  public class TabAndCase {
    @AuraEnabled
    public Case caseData;
    @AuraEnabled
    public Boolean storeTabPermission;
    @AuraEnabled
    public Boolean grantOrderCancelPermission;
    @AuraEnabled
    public Boolean digitalTabPermission;
    @AuraEnabled
    public Map<String, Map<String, String>> digitalOrderStatusMatrixMap;
  }

  public class CaseResponse {
    @AuraEnabled
    public List<Case> existingCaseList;
    @AuraEnabled
    public Account transactionCustomer;
  }

  public class SaveData {
    public PHISTorderTransactionWrapper.ResponseOrder selectedOrder;
    public List<PHISTorderTransactionWrapper.ResponseOrderLine> selectedOrderLineList;
    public Case selectedCase;
    public String customerId;
  }

  @TestVisible
  private static Map<String, PHIST_DigitalOrder_Status_Matrix__mdt> phistDOStatusMatrixMap {
    get {
      if (phistDOStatusMatrixMap == null) {
        phistDOStatusMatrixMap = PHIST_DigitalOrder_Status_Matrix__mdt.getAll();
      }
      return phistDOStatusMatrixMap;
    }
    set;
  }

  /**
   * ───────────────────────────────────────────────────────────────────────────────────────────────┐
   * get case when running in stateful mode
   * ────────────────────────────────────────────────────────────────────────────────────────────────
   * @param    caseId  String
   * @return   Case
   * ───────────────────────────────────────────────────────────────────────────────────────────────┘
   */
  @AuraEnabled
  public static TabAndCase getTabAndStatefulData(
    String caseId,
    Boolean stateful,
    String chatTranscriptRecordId
  ) {
    TabAndCase tac = new TabAndCase();
    if (stateful) {
      List<Case> caseList = [
        SELECT
          Id,
          Status,
          Account.CID__c,
          Account.SAP_Store__c,
          Account.PersonEmail,
          Account.FirstName,
          Account.LastName,
          Account.ShippingPostalCode
        FROM Case
        WHERE Id = :caseId
      ];
      if (!caseList.isEmpty()) {
        tac.caseData = caseList[0];
      }
    }

    if (
      chatTranscriptRecordId != null &&
      string.isNotEmpty(chatTranscriptRecordId)
    ) {
      List<MessagingSession> chatTranscriptRecordList = [
        SELECT CaseId
        FROM MessagingSession
        WHERE Id = :chatTranscriptRecordId
      ];
      if (
        !chatTranscriptRecordList.isEmpty() &&
        chatTranscriptRecordList[0].CaseId != null
      ) {
        List<Case> caseList = [
          SELECT
            Id,
            Status,
            Account.CID__c,
            Account.SAP_Store__c,
            Account.PersonEmail,
            Account.FirstName,
            Account.LastName,
            Account.ShippingPostalCode
          FROM Case
          WHERE Id = :chatTranscriptRecordList[0].CaseId
        ];
        if (!caseList.isEmpty()) {
          tac.caseData = caseList[0];
        }
      }
    }

    try {
      tac.grantOrderCancelPermission = FeatureManagement.checkPermission(
        'Grant_Order_Cancellation'
      );
      tac.storeTabPermission = FeatureManagement.checkPermission(
        'Grant_Store_Transaction_Search'
      );
      tac.digitalTabPermission = FeatureManagement.checkPermission(
        'Grant_Digital_Order_Search'
      );
    } catch (Exception e) {
      Logger.error('Exception while checking permission :: ' + e.getMessage());
      Logger.saveLog();
    }
    if (tac.digitalTabPermission) {
      tac.digitalOrderStatusMatrixMap = new Map<String, Map<String, String>>();
      for (String label : phistDOStatusMatrixMap.keySet()) {
        PHIST_DigitalOrder_Status_Matrix__mdt doMatrix = phistDOStatusMatrixMap.get(
          label
        );
        if (
          !tac.digitalOrderStatusMatrixMap.containsKey(doMatrix.Min_Status__c)
        ) {
          tac.digitalOrderStatusMatrixMap.put(
            doMatrix.Min_Status__c,
            new Map<String, String>()
          );
        }
        tac.digitalOrderStatusMatrixMap.get(doMatrix.Min_Status__c)
          .put(doMatrix.Max_Status__c, doMatrix.Associate_Dispay__c);
      }
    }

    return tac;
  }

  /**
   * ───────────────────────────────────────────────────────────────────────────────────────────────┐
   * get initial data for the Existing cases
   * ────────────────────────────────────────────────────────────────────────────────────────────────
   * @param    customerId  String( customer Id on the selected order )
   * @return   String      structured data
   * ───────────────────────────────────────────────────────────────────────────────────────────────┘
   */
  @AuraEnabled
  public static String getCasesDetails(String customerId) {
    CaseResponse res = new CaseResponse();
    res.existingCaseList = [
      SELECT
        Id,
        CaseNumber,
        Origin,
        Subject,
        Description,
        Status,
        Type,
        Sub_Type__c,
        AccountId,
        Account.Name,
        Account.Phone,
        Account.PersonEmail,
        Account.ShippingStreet,
        Account.ShippingCity,
        Account.ShippingState,
        Account.ShippingPostalCode,
        Account.ShippingCountry,
        Account.CID__c
      FROM Case
      WHERE OwnerId = :UserInfo.getUserId() AND Status != 'Closed'
      ORDER BY CreatedDate DESC
    ];

    if (customerId != null) {
      List<Account> transactionCustomerList = [
        SELECT
          Id,
          Name,
          Phone,
          PersonEmail,
          ShippingStreet,
          ShippingCity,
          ShippingState,
          ShippingPostalCode,
          ShippingCountry,
          CID__c
        FROM Account
        WHERE CID__c = :customerId
      ];
      if (!transactionCustomerList.isEmpty()) {
        res.transactionCustomer = transactionCustomerList[0];
      }
    }

    return JSON.serialize(res);
  }

  /**
   * ───────────────────────────────────────────────────────────────────────────────────────────────┐
   * create Order Transaction records
   * ────────────────────────────────────────────────────────────────────────────────────────────────
   * @param    data    String
   * @return   String
   * ───────────────────────────────────────────────────────────────────────────────────────────────┘
   */
  @AuraEnabled
  public static String createOrderTransactions(
    String data,
    String childComponent
  ) {
    String responseMessage = 'SUCCESS';
    data = data.replace('$','');
    SaveData svData = (SaveData) JSON.deserialize(data, SaveData.class);
    System.debug('svData---' + svData);
    System.debug('svData.selectedOrderLineList' + svData.selectedOrderLineList);
    //─────────────────────────────────────────────────────────────────────────────────────────────────┐
    // Getting list of OrderTransaction for the selected case and selected order OrderId
    //─────────────────────────────────────────────────────────────────────────────────────────────────┘
    List<String> itemIdList = new List<String>();
    List<Order_Transaction__c> otList = [
      SELECT Id, Item_ID__c
      FROM Order_Transaction__c
      WHERE
        Case__c = :svData.selectedCase.Id
        AND Transaction_Number__c = :svData.selectedOrder.OrderId
    ];
    for (Order_Transaction__c ot : otList) {
      if (ot.Item_ID__c != null) {
        itemIdList.add(ot.Item_ID__c);
      }
    }
    System.debug('otList---' + otList);
    System.debug('itemIdList---' + itemIdList);
    Integer duplicateCounter = 0;
    String timestamp = svData.selectedOrder.CreatedTimestamp.replace('T', ' ');
    Boolean digitalOrder = childComponent == 'DigitalOrder' ? true : false;
    Boolean eshopOrder = digitalOrder &&
      svData.selectedOrder.OrderType.OrderTypeId == 'VSD-ESHOP' ||
      svData.selectedOrder.OrderType.OrderTypeId == 'VSD-GLOBALE'
      ? true
      : false;
    List<String> dateTimeList = timestamp.split(' ');
    List<String> dateList = dateTimeList[0].split('-');
    String duplicateItems = '';
    List<Order_Transaction__c> insertOrderTrasactionsList = new List<Order_Transaction__c>();
    //─────────────────────────────────────────────────────────────────────────────────────────────────┐
    // User did not select any OrderLineItem
    //─────────────────────────────────────────────────────────────────────────────────────────────────┘
    if (otList.isEmpty() && svData.selectedOrderLineList.isEmpty()) {
      System.debug('rs1->');
      try {
        Order_Transaction__c ot = new Order_Transaction__c();
        ot.Case__c = (Id) svData.selectedCase.Id;

        ot.Amount__c = eshopOrder
          ? svData.selectedOrder.orderExtension3[0].Extended.ShopperTotal
          : svData.selectedOrder.OrderTotal;
        //Added by pooja
        ot.Order_Type__c = svData.selectedOrder.OrderType.OrderTypeId;
        ot.Shoppers_Amount__c = svData.selectedOrder.formattedCurrency;
        //Added by pooja
        //ot.CID__c = svData.selectedOrder.CustomerId;
        ot.CID__c = svData.selectedOrder.Extended.CID;
        ot.Register_Number__c = svData.selectedOrder.Extended.DeviceId;
        ot.Store_Number__c = svData.selectedOrder.Extended.OriginStore;
        ot.Transaction_Number__c = svData.selectedOrder.OrderId;
        ot.Order_Status__c = digitalOrder ? svData.selectedOrder.status : '';
        ot.Payment_Method__c = createPaymentString(
          svData.selectedOrder.Payment,
          eshopOrder,
          svData.selectedOrder.formattedCurrency
        );
        ot.Transaction_Date__c = (digitalOrder
          ? Date.valueOf(timestamp)
          : Date.valueOf(
              dateList[2] +
                '-' +
                dateList[0] +
                '-' +
                dateList[1] +
                ' ' +
                dateTimeList[1]
            ));

        /** DP-58367 ****
         * @description - assign pick up date and time
         * @author Rishabh Sharma
         */
        System.debug('Is Empty '+svData.selectedOrder.orderLine.isEmpty());
        if (
          svData.selectedOrder != null &&
          svData.selectedOrder.orderLine != null &&
          !svData.selectedOrder.orderLine.isEmpty()
        ) {
          //check if order is cancelled
          if (svData.selectedOrder.orderLine[0].IsCancelled == true) {
            ot.Pick_up_Date__c = 'Order was cancelled';
          } else {
            if (
              svData.selectedOrder.orderLine[0].MaxFulfillmentStatusId != null
            ) {
              ot.MaxfulfillmentStatusId__c = Decimal.valueOf(
                (svData.selectedOrder.orderLine[0].MaxFulfillmentStatusId)
              );
              if (
                svData.selectedOrder.orderLine[0].MaxFulfillmentStatusId ==
                '3600' &&
                svData.selectedOrder.orderLine[0].FulfillmentDetail != null &&!svData.selectedOrder.orderLine[0].FulfillmentDetail.isEmpty()
              ) {
                ot.Pick_up_Date__c = String.valueOf(Date.valueOf(svData.selectedOrder.orderLine[0].FulfillmentDetail[0].UpdatedTimeStamp).addDays(4)
                );
              } else if (
                svData.selectedOrder.orderLine[0].MaxFulfillmentStatusId ==
                '2000'
              ) {
                ot.Pick_up_Date__c = 'Order is not yet ready for pickup';
              } else if (
                svData.selectedOrder.orderLine[0].MaxFulfillmentStatusId ==
                '7000'
              ) {
                String pickUpDate = !String.isEmpty(svData.selectedOrder.orderLine[0].FulfillmentDetail[0].FulfillmentDate)? String.valueOf(Date.valueOf(svData.selectedOrder.orderLine[0].FulfillmentDetail[0].FulfillmentDate)): null;
                // ot.Pick_up_Date__c = 'Order has been picked up on '+String.valueOf(Date.valueOf(svData.selectedOrder.orderLine[0].FulfillmentDetail[0].FulfillmentDate));
                // ot.Pick_up_Date__c = 'Order has been picked up on '+ pickUpDate ;

                if (!String.isEmpty(pickUpDate)) {ot.Pick_up_Date__c ='Order has been picked up on ' + pickUpDate;
                } else {
                  ot.Pick_up_Date__c = 'Pick up date is not available';
                }
              }
            }
          }
        }
        if (
          svData.selectedOrder != null &&
          svData.selectedOrder.orderLine != null &&
          !svData.selectedOrder.orderLine.isEmpty() &&
          svData.selectedOrder.orderLine[0].ShipToLocationId != null
        ) {
          ot.BOPIS_Store_Number_Text__c = String.valueOf(
            svData.selectedOrder.orderLine[0].ShipToLocationId
          );
        }

        /** DP-50494 ****
         * @description - checking if this is Store order and Paid with Credit card
         * @author Sumit Saha
         *
         * DP-53297 *****
         * @description - Updated condition to cardTypeId for VS Credit card
         * @author Himanshu Mishra
         */
        if (!digitalOrder && svData.selectedOrder.Payment.size() > 0 && svData.selectedOrder.Payment[0].PaymentMethod !=null && svData.selectedOrder.Payment[0].PaymentMethod.size()>0) {
          for (
            Integer i = 0;
            i < svData.selectedOrder.Payment[0].PaymentMethod.size();
            i++
          ) {
            if (String.isNotEmpty(svData.selectedOrder.Payment[0].PaymentMethod[i].CardType.CardTypeId) ||
              svData.selectedOrder.Payment[0].PaymentMethod[i].CardType.CardTypeId == 'Victoria’s Secret Credit Card'
            ) {
              System.debug(
                'Account Number:: ' +
                svData.selectedOrder.Payment[0].PaymentMethod[i].AccountNumber
              );
              ot.Account_Number__c = svData.selectedOrder.Payment[0].PaymentMethod[i].AccountNumber;
              break;
            }
          }
        }
        /***** DP-50494 *****/

        insertOrderTrasactionsList.add(ot);
      } catch (System.NullPointerException e) {
        Logger.error(
          'Exception in reading order details: ' +
            String.valueOf(e.getMessage()) +
            ' || Stack trace ' +
            String.valueOf(e.getStackTraceString())
        );
        Logger.saveLog();
      }
    }
    //─────────────────────────────────────────────────────────────────────────────────────────────────┐
    // User selected multiple OrderLineItem
    // OrderLineItems can be duplicate/new
    //─────────────────────────────────────────────────────────────────────────────────────────────────┘
    else if (!svData.selectedOrderLineList.isEmpty()) {
      System.debug('rs2->');
      try {
        for (
          PHISTorderTransactionWrapper.ResponseOrderLine orderLine : svData.selectedOrderLineList
        ) {
          // Only create records for the new OrderLineItems
          if (!itemIdList.contains(orderLine.ItemId)) {
            Order_Transaction__c ot = new Order_Transaction__c();
            ot.Case__c = (Id) svData.selectedCase.Id;
            ot.Amount__c = eshopOrder
              ? svData.selectedOrder.orderExtension3[0].Extended.ShopperTotal
              : svData.selectedOrder.OrderTotal;
            //Added by pooja
            ot.Order_Type__c = svData.selectedOrder.OrderType.OrderTypeId;
            ot.Shoppers_Amount__c = svData.selectedOrder.formattedCurrency;
            //Added by pooja
            //ot.CID__c = svData.selectedOrder.CustomerId;
              ot.CID__c = svData.selectedOrder.Extended.CID;
              ot.Register_Number__c = svData.selectedOrder.Extended.DeviceId;
              ot.Store_Number__c = svData.selectedOrder.Extended.OriginStore;
              ot.Transaction_Number__c = svData.selectedOrder.OrderId;
              ot.Payment_Method__c = createPaymentString(
                  svData.selectedOrder.Payment,
                  eshopOrder,
                  svData.selectedOrder.formattedCurrency
              );
              ot.Item_Description__c = orderLine.ItemDescription;
              ot.Item_ID__c = orderLine.ItemId;
              ot.Quantity__c = orderLine.Quantity;
              ot.Total_Discount__c = orderLine.TotalDiscounts;
              ot.Unit_Price__c = eshopOrder
                  ? orderLine.orderLineExtension3[0].Extended.ShopperUnitPriceAfterDiscount
                  : orderLine.UnitPrice;
              ot.Price_Paid__c = orderLine.OrderLineSubTotal;
              ot.Color__c = digitalOrder
                  ? orderLine.ItemColorDescription
                  : orderLine.Sku.Color;
              ot.Size__c = digitalOrder ? orderLine.ItemSize : orderLine.Sku.Size;
              ot.Transaction_Date__c = (digitalOrder
                                        ? Date.valueOf(timestamp)
                                        : Date.valueOf(dateList[2] +'-' +dateList[0] +'-' +dateList[1] +' ' +dateTimeList[1]));
              ot.BOPIS_Store_Number_Text__c = String.valueOf(
                  orderLine.ShipToLocationId
              );
              /** DP-53302 ****
* @description - assign pick up date and time
* @author Rishabh Sharma
*/
              //  System.debug('orderLine.FulfillmentDetail.isEmpty()' + orderLine.FulfillmentDetail.isEmpty());
              if(orderLine.MaxFulfillmentStatusId !=null ){
                  ot.MaxfulfillmentStatusId__c = Decimal.valueOf(
                      orderLine.MaxFulfillmentStatusId
             	 );
              }
              
              if (orderLine.IsCancelled == true) {
                  ot.Pick_up_Date__c = 'Order was cancelled';
              } else {
                  //check for maxfulfillment statuses
                  if (orderLine.MaxFulfillmentStatusId != null) {
                      //3600
                      if (
                          orderLine.MaxFulfillmentStatusId == '3600' &&!orderLine.FulfillmentDetail.isEmpty()) {
                          ot.Pick_up_Date__c = String.valueOf(Date.valueOf(orderLine.FulfillmentDetail[0].UpdatedTimeStamp).addDays(4));
                      } else if (orderLine.MaxFulfillmentStatusId == '2000') {
                          ot.Pick_up_Date__c = 'Order is not yet ready for pickup';
                      } else if (
                          orderLine.MaxFulfillmentStatusId == '7000' &&
                          !orderLine.FulfillmentDetail.isEmpty()
                      ) {
                          String pickUpDate = !String.isEmpty(
                              svData.selectedOrder.orderLine[0]
                              .FulfillmentDetail[0]
                              .FulfillmentDate)? String.valueOf(Date.valueOf(svData.selectedOrder.orderLine[0].FulfillmentDetail[0].FulfillmentDate)): null;
                          // ot.Pick_up_Date__c = 'Order has been picked up on '+String.valueOf(Date.valueOf(orderLine.FulfillmentDetail[0].FulfillmentDate));
                          
                          if (!String.isEmpty(pickUpDate)) {ot.Pick_up_Date__c ='Order has been picked up on ' + pickUpDate;
                          } else {
                              ot.Pick_up_Date__c = 'Pick up date is not available';
                          }
                      }
                  }
              }
              
              if (digitalOrder) {
                  ot.Order_Status__c = svData.selectedOrder.status;
                  ot.Ship_Date__c = orderLine.PromisedShipDate != null? Date.valueOf(orderLine.PromisedShipDate.replace('T', ' '))
                      : null;
                  ot.Estimated_Delivery_Date__c = orderLine.PromisedDeliveryDate !=
                      null? Date.valueOf(orderLine.PromisedDeliveryDate.replace('T', ' '))
                      : null;
                  ot.Ship_Type__c = orderLine.ShippingMethodId;
                  if (
                      orderLine.FulfillmentDetail != null &&
                      !orderLine.FulfillmentDetail.isEmpty()
                  ) {
                      ot.Carrier_Code__c = orderLine.FulfillmentDetail[0].CarrierCode;
                  }
              }
              
              /** DP-50494 ****
* @description - checking if this is Store order and Paid with Credit card
* @author Sumit Saha
*
* DP-53297 *****
* @description - Updated condition to cardTypeId for VS Credit card
* @author Himanshu Mishra
*/
              if (!digitalOrder && svData.selectedOrder.Payment.size() > 0 && svData.selectedOrder.Payment[0].PaymentMethod !=null && svData.selectedOrder.Payment[0].PaymentMethod.size()>0) {
                  for (
                      Integer i = 0;
                      i < svData.selectedOrder.Payment[0].PaymentMethod.size();
                      i++
                  ) {
                      if (
                          String.isEmpty(
                              svData.selectedOrder.Payment[0]
                              .PaymentMethod[i]
                              .CardType.CardTypeId
                          ) ||
                          svData.selectedOrder.Payment[0]
                          .PaymentMethod[i]
                          .CardType.CardTypeId == 'Victoria’s Secret Credit Card'
                      ) {
                          System.debug(
                              'Account Number:: ' +
                              svData.selectedOrder.Payment[0]
                              .PaymentMethod[i]
                              .AccountNumber
                          );
                          ot.Account_Number__c = svData.selectedOrder.Payment[0]
                              .PaymentMethod[i]
                              .AccountNumber;
                          break;
                      }
                  }
              }
            /***** DP-50494 *****/

            insertOrderTrasactionsList.add(ot);
          } else {
            duplicateItems += (String.isBlank(duplicateItems)
              ? 'Order Number: ' +
                svData.selectedOrder.OrderId +
                ' Item Ids: ' +
                orderLine.ItemId
              : ', ' + orderLine.ItemId);
            ++duplicateCounter;
          }
        }
      } catch (System.NullPointerException e) {
        Logger.error(
          'Exception in reading order details: ' +
            String.valueOf(e.getMessage()) +
            ' || Stack trace ' +
            String.valueOf(e.getStackTraceString())
        );
        Logger.saveLog();
      }
    }
    //─────────────────────────────────────────────────────────────────────────────────────────────────┐
    // setting responseMessage
    //─────────────────────────────────────────────────────────────────────────────────────────────────┘
    else {
      ++duplicateCounter;
      duplicateItems += 'Order Number: ' + svData.selectedOrder.OrderId;
    }

    if (digitalOrder && duplicateCounter > 0) {
      responseMessage = String.format(
        System.Label.PhistAddDuplicateOrderInfo,
        new List<String>{ duplicateItems }
      );
      return responseMessage;
    }

    //─────────────────────────────────────────────────────────────────────────────────────────────────┐
    // Inserting new Order Transactions
    //─────────────────────────────────────────────────────────────────────────────────────────────────┘
    try {
      if (!insertOrderTrasactionsList.isEmpty()) {
        insert insertOrderTrasactionsList;
      }

      //─────────────────────────────────────────────────────────────────────────────────────────────────┐
      // Updating Case with the selected customer in case there is choice available
      //─────────────────────────────────────────────────────────────────────────────────────────────────┘
      Case updateCase;
      if (svData.customerId != null) {
        Account acc = [
          SELECT Id, PersonContactId
          FROM Account
          WHERE Id = :svData.customerId
        ];
        updateCase = new Case(
          Id = (Id) svData.selectedCase.Id,
          ContactId = acc.PersonContactId,
          AccountId = acc.Id,
          /* Below fields are added as part of DP-56071*/
          //Order_Number_from_OT__c=true,
          Order_Number__c = svData.selectedOrder.OrderId
        );

        update updateCase;
      }
      /* Below fields are added as part of DP-56071*/
      else {
        updateCase = new Case(
          Id = (Id) svData.selectedCase.Id,
          /* Below fields are added as part of DP-56071*/
          //Order_Number_from_OT__c=true,
          Order_Number__c = svData.selectedOrder.OrderId
        );
        update updateCase;
      }
      //update case resolution
      /*List<Case_Resolution__c> crList=[SELECT Id,
             Order__c
             FROM Case_Resolution__c
             WHERE Related_Case__c=:svData.selectedCase.Id];
             if(!crList.isEmpty()){
             crList[0].Order__c=svData.selectedOrder.OrderId;
             //update crList;
             }*/
    } catch (Exception ex) {
      responseMessage = ex.getMessage();
      System.debug('>>>> RESPONSE MESSAGE');
      System.debug(responseMessage);
      Logger.error('Exception in Updating Case:: ' + responseMessage);
      Logger.saveLog();
    }

    return responseMessage;
  }

  /**
   * ───────────────────────────────────────────────────────────────────────────────────────────────┐
   * create Order_Transaction__c.Payment_Method__c field value
   * ────────────────────────────────────────────────────────────────────────────────────────────────
   * @param    paymentList    List<PHISTorderTransactionWrapper.ResponsePayment>
   * @param    eGlobalOrder   Boolean
   * @param    eGlobalAmount  String
   * @return   String
   * ───────────────────────────────────────────────────────────────────────────────────────────────┘
   */
  private static String createPaymentString(
    List<PHISTorderTransactionWrapper.ResponsePayment> paymentList,
    Boolean eGlobalOrder,
    String eGlobalAmount
  ) {
    String paymentMethodString = '';
    if (paymentList != null && !paymentList.isEmpty()) {
      for (PHISTorderTransactionWrapper.ResponsePayment payment : paymentList) {
        if (payment.PaymentMethod != null && !payment.PaymentMethod.isEmpty()) {
          for (
            PHISTorderTransactionWrapper.ResponsePaymentMethod paymentMethod : payment.PaymentMethod
          ) {
            if (
              paymentMethod.PaymentType.PaymentTypeId != null && eGlobalOrder
            ) {
              String tempPayment =
                paymentMethod.PaymentType.PaymentTypeId +
                ' - ' +
                eGlobalAmount;
              paymentMethodString += String.isBlank(paymentMethodString)
                ? tempPayment
                : ('; ' + tempPayment);
            } else if (paymentMethod.PaymentType.PaymentTypeId != null) {
              String tempPayment =
                paymentMethod.PaymentType.PaymentTypeId +
                ' - ' +
                paymentMethod.Amount;
              paymentMethodString += String.isBlank(paymentMethodString)
                ? tempPayment
                : ('; ' + tempPayment);
            }
          }
        }
      }
    }

    return paymentMethodString;
  }

  @AuraEnabled
  public static ResponseWrapper getUserProfileName() {
    ResponseWrapper resp = new ResponseWrapper();
    resp.status = true;
    resp.errormessage = '';
    try {
      resp.data = [
        SELECT Profile.Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ]
      .Profile.Name;
    } catch (Exception e) {
      resp.status = false;resp.data = e.getMessage();resp.errormessage = e.getMessage();
      Logger.error('Exception in Getting Profile for an User:: ' + e.getMessage());
      Logger.saveLog();
    }
    return resp;
  }
}