/*****************************************************************************************************@@
Class Name     :  NF_OrderServiceN
Purpose        :  Wrapper class for order api.
History:
-------
VERSION  AUTHOR                   DATE                	DETAIL                      	TICKET REFERENCE/ NO.
1.       mcasella              	09/24/2020            Original Version             			   	-
2.       Manishi             	09/03/2021            Modifying wrapper for API endpoints      DP-39915
3.       Sumit                  03/28/2023            Predictable Delivery Date                DP-61379
4.       Sumit                  05/11/2023            OrderNote changes                        DP-67509 
5.       Sumit                  07/20/2023            Upgrade to V5                            CCS-55
6.       Himanshu               10/16/2024            Added addtional tax details              CCS-580
7.		 Himanshu				10/21/2024			  Added discount details for DSS returns   DP-87523
*********************************************************************************************************/

public class NF_OrderServiceN {
  public static List<String> REMORSE_STATUSES = new List<String>{
    'ORDERPLACED',
    'BACKORDERED'
  };

  /**
   * @description new wrapper class for responses with new api calls
   */
  public class APIResponse {
    public String status;
    public Integer statusCode;
    public String responseError = '';
    public List<ListOfOrderResponse> orders;
    public OrderResponse order;
    public string rawBody;
    //Added for Callout Test Page
    public String requestURL;
    public String requestBody;
  }

  //Start------Wrapper while receiving list of orders by email
  public class ListOfOrderResponse {
    public String orderStatus;
    public String orderNumber;
    public Boolean isCancelModifyEligible;
    public String orderDateTime;
    public list<Lshipments> shipments;
    public String orderDate;
    public orderSummary orderSummary;
    //added by Manishi
    public String orderPlaceholder1;
    public String orderPlaceholder2;
    public String orderPlaceholder3;

    /* DP-39915 R3 order history response modification starts */
    public Boolean isCancelEligible;
    public Boolean isModifyEligible;
    public Boolean isOnHold;
    public String holdTypeId;
    public dssReturn dssReturn;
    public String parentOrderId;
    public String parentOrderNumber;
    public String storeNumber;
    public Boolean isAwaitingPaymentProcess;
    /* DP-39915 R3 order history response modification ends */

    //calculate Order Status based on shipment status LBRAN-172
    public String calculatedOrderStatus;
    //LBRAN-92
    //public Boolean isOrderRemorse;
    //public Boolean isBackordered;

    public Boolean isOrderNotePresent;

    public Boolean isInRemorse() {
      if (compareOrderStatus(orderStatus, REMORSE_STATUSES)) {
        return true;
      } else if (shipments != null) {
        //check for shipment status
        for (NF_OrderServiceN.Lshipments shipment : shipments) {
          if (compareOrderStatus(shipment.status, REMORSE_STATUSES)) {
            return true;
          }
        }
      }

      return false;
    }

    public Boolean hasShipmentStatus(String shipmentStatus) {
      if (shipments != null) {
        for (NF_OrderServiceN.Lshipments shipment : shipments) {
          if (shipment.status.equalsIgnoreCase(shipmentStatus)) {
            return true;
          }
        }
      }
      //for scenarios where we dont have shipments but the order status = returned.
      else if (orderStatus.equalsIgnoreCase(shipmentStatus)) {
        return true;
      } else {
        return false;
      }

      return false;
    }
  }
  public class Lshipments {
    public String trackingURL;
    public list<products> products;
    public String statusDate;
    public String status;
    public String shippingType;
  }
  public class products {
    public String image;
    public string absoluteImageURL;
    public String shortDescription;
    public String returnReason;
  }
  //End------Wrapper while receiving list of orders by email

  public class OrderResponse {
    public orderDate orderDate;
    public String orderDateTime;
    public String orderNumber;
    public Boolean isDisplayDiscounts;
    public orderSummary orderSummary;
    public String orderType;
    public String orderStatus;
    public boolean isLegacyOrder;
    public boolean isEShop;
    public boolean isRejected;
    public payments[] payments;
    public parentOrder parentOrder;
    public shipments[] shipments;
    public returns returns;
    public dssReturn dssReturn;
    public boolean isCancelModifyEligible;
    public cancelled[] cancelled;
    public statusDate statusDate;
    /* DP-39915 R3 order history response modification starts */
    public Boolean isCancelEligible;
    public Boolean isModifyEligible;
    public Boolean isOnHold;
    public String holdTypeId;
    public String parentOrderId;
    public String parentOrderNumber;
    public String storeNumber;
    public Boolean isAwaitingPaymentProcess;
    /* DP-39915 R3 order history response modification end */

    //added by Manishi
    //public String orderPlaceholder;

    //calculate Order Status based on shipment status LBRAN-172
    public String calculatedOrderStatus;

    public Boolean isInRemorse() {
      if (compareOrderStatus(orderStatus, REMORSE_STATUSES)) {
        return true;
      } else if (shipments != null) {
        //check for shipment status
        for (NF_OrderServiceN.shipments shipment : shipments) {
          if (compareOrderStatus(shipment.status, REMORSE_STATUSES)) {
            return true;
          }
        }
      }

      return false;
    }

    public Boolean hasShipmentStatus(String shipmentStatus) {
      Boolean isOrderStatus = false;

      if (shipments != null) {
        for (NF_OrderServiceN.shipments shipment : shipments) {
          if (shipment.status.equalsIgnoreCase(shipmentStatus)) {
            return true;
          }
        }
      }
      //for scenarios where we dont have shipments but the order status = returned.
      else if (
        orderStatus != null && orderStatus.equalsIgnoreCase(shipmentStatus)
      ) {
        return true;
      } else {
        return false;
      }

      return false;
    }
  }
  public class orderDate {
    public Integer month;
    public Integer day;
    public Integer year;
  }
  public class orderSummary {
    public discounts discounts;
    public String merchandiseSubTotal;
    public String autoDiscountSubTotal;
    public String orderTotal;
    public String totalPaymentToBeCharged;
    public String salesTax;
    public String intlOrderDutiesTaxesFeesTotal;
    public String shippingHandling;
    public boolean isRefundTotal;
    public boolean showTax;
    public String giftCardTotal;
    public List<appliedOffer> appliedOffers;
    public additionalTax additionalTax;
  }

  public class additionalTax {
    public String retailDeliveryFee;
    public String pif;
    public String pifRsf;
    public String facilityCharge;
  }

  public class discounts {
    public string total;
    public String totalAmount;
    public List<items> items;
  }

  public class items {
    public String text;
    public String discountValue;
    public String discountValueAmount;
  }

  public class returnedSummary {
    public String returnMerchandiseSubTotal;
    public String salesTax;
    public String intlOrderDutiesTaxesFeesTotal;
    public boolean isRefundTotal;
    public boolean showTax;
  }
  public class payments {
    public String paymenttype;
    public String itemNumber;
    public String amount;
  }
  public class shipments {
    public lineItems[] lineItems;
    public String status;
    public statusDate statusDate;
    public estimatedDeliveryStart estDeliveryStart;
    public estimatedDeliveryEnd estDeliveryEnd;
    public address address;
    public pickUpStore pickUpStore;
    public method method;
    public String shipmentType;
    public shipmentSummary shipmentSummary;
    public String carrier;
    public String trackingNumber;
    public String shipmentTrackingURL;
    public String shippingType;
  }

  public class estimatedDeliveryStart {
    public String month;
    public String day;
    public String year;
  }

  public class estimatedDeliveryEnd {
    public String month;
    public String day;
    public String year;
  }

  public class returns {
    public lineItems[] lineItems;
    public returnedSummary returnedSummary;
  }
  public class lineItems {
    public String family;
    public String name;
    public String variantId;
    public String productImage;
    public String swatchImage;
    public boolean isAvailable;
    public String status;
    public statusDate statusDate;
    public attributes attributes;
    public quantity quantity;
    public price price;
    public String url;
    public String returnReason;
  }
  public class statusDate {
    public Integer month;
    public Integer day;
    public Integer year;
  }
  public class attributes {
    public choice choice;
    public size1 size1;
    public size2 size2;
    public sendDate sendDate;
    public String email; // this attribute is not getting in json
  }
  public class choice {
    public String value;
  }
  public class size1 {
    public String label;
    public String value;
  }
  public class size2 {
  }
  public class sendDate {
    public Integer month;
    public Integer day;
    public Integer year;
  }
  public class quantity {
    public Integer selected;
  }
  public class price {
    public unitPrice unitPrice;
    public totalPrice totalPrice;
    public String priceType;
  }
  public class unitPrice {
    public String originalPrice;
    public String salePrice;
  }
  public class totalPrice {
    public String originalPrice;
    public String salePrice;
  }
  public class address {
    public String countryCode;
    public String streetAddress1;
    public String streetAddress2;
    public String city;
    public String region;
    public String postalCode;
    public String firstName;
    public String lastName;
    public String phone;
  }
  public class pickUpStore {
  }
  public class method {
    public String code;
    public String title;
    public String estimatedDeliveryDate;
  }
  public class OrderRequest {
    public String email;
    public String orderId;
    public String activeCountry;
  }
  public class cancelled {
    public String family;
    public String name;
    public String variantId;
    public String productImage;
    public String swatchImage;
    public Boolean isAvailable;
    public String status;
    public statusDate statusDate;
    public attributes attributes;
    public quantity quantity;
    public price price;
    public String url;
    public String returnReason;
  }
  public class shipmentSummary {
    public String merchandiseSubTotal;
    public String orderTotal;
    public String salesTax;
    public String intlOrderDutiesTaxesFeesTotal;
    public String shippingHandling;
    public Boolean isRefundTotal;
    public Boolean showTax;
  }
  public class parentOrder {
    public String email;
    public String itemNumber;
  }
  public class appliedOffer {
    public String code;
    public String amount;
  }
  public class dssReturn {
    public tracking tracking;
    public String trackingId;
    public String carrierCode;
    public String parentOrderId;
    public String returnMethod;
    public estimatedRefundSummary estimatedRefundSummary;
  }
  public class estimatedRefundSummary {
    public String discount;
  }
  public class tracking {
    public processed processed;
    public String trackingId;
  }
  public class processed {
    public String trackingId;
  }
  public class FailedResponse {
    public String message;
    public String fieldNames;
    public String error;
  }

  /* Ignore spaces and case sensitivity
   *  List of statuses should not contain any spaces, and should be in UPPERCASE*/
  @TestVisible
  private static Boolean compareOrderStatus(
    String statusToCompare,
    List<String> statuses
  ) {
    if (String.isEmpty(statusToCompare) || statuses == null)
      return false;

    statusToCompare = statusToCompare.replaceAll('\\s+', '').toUpperCase();

    return statuses.contains(statusToCompare);
  }
}