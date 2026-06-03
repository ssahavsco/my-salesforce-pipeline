/** created by Sumit Saha
 *  CreatedDate: May 7, 2025
 */

public with sharing class VSCCS_CarouselOrderDetails {
  public static List<String> labelName = new List<String>{
    'EstimatedDelivery',
    'Placedon',
    'OrderNumber',
    'ReturnOrderNumber',
    'Status',
    'TotalItems',
    'Total',
    'TRACK_SHIPMENT',
    'VIEW_ALL_SHIPMENTS',
    'CALL_US',
    'VIEW_ORDER_HISTORY',
    'Shipped',
    'Refunded',
    'Your_order_contains_more_than_4_shipments',
    'Cancelled',
    'Delivered',
    'Backordered',
    'PreparingtoShip',
    'Package_with_Carrier',
    'Return_Processed_on',
    'Refund_in_Process',
    'Return_Initiated',
    'Refund_Pending',
    'Awaiting_Payment'
  };
  // public static List<String> languages = new List<String>{ 'en_US', 'ko' };

  public class Carousel {
    public List<OrderDetails> details;
    public List<LanguageCustomLabels> labels;
    public Boolean isAuthorized;

    public Carousel() {
      this.details = new List<OrderDetails>();
      this.labels = new List<LanguageCustomLabels>();
      List<String> languages = new List<String>{ 'en_US', 'ko', 'de' };

      for (String name : labelName) {
        for (String lang : languages) {
          String labelValue = System.Label.get('', name, lang);
          String labelValue_en_US = System.Label.get('', name, 'en_US');
          VSCCS_CarouselOrderDetails.LanguageCustomLabels customLabels = new VSCCS_CarouselOrderDetails.LanguageCustomLabels();
          customLabels.language = lang;
          customLabels.label = labelValue_en_US;
          customLabels.translation = labelValue;
          this.labels.add(customLabels);
        }
      }
    }
    public Carousel(String language) {
      this.details = new List<OrderDetails>();
      this.labels = new List<LanguageCustomLabels>();
      List<String> languages = new List<String>{ 'en_US', language };

      for (String name : labelName) {
        for (String lang : languages) {
          String labelValue = System.Label.get('', name, language);
          String labelValue_en_US = System.Label.get('', name, 'en_US');
          vsccs_CarouselOrderDetails.LanguageCustomLabels customLabels = new vsccs_CarouselOrderDetails.LanguageCustomLabels();
          customLabels.language = lang;
          customLabels.label = labelValue_en_US;
          customLabels.translation = labelValue;
          this.labels.add(customLabels);
        }
      }
    }
  }

  public class OrderDetails {
    public Integer Id;
    public String orderNumber;
    public String orderNumberLabel;
    public String orderPlacedDate;
    public String itemQuantity;
    public String imageHTMLCompiled;
    public String totalItemPrice;

    public String displayStatus;

    public String shipmentStatusMonth;
    public String shipmentStatusDay;
    public String shipmentStatusYear;

    public String estimatedDeliveryDate;

    public String displayPrice;

    public String truckHtml;
    public String orderDetailsButton;
    public String shipmentButton;
    public String orderHistoryButton;
    public String callUsButton;
  }

  public class LanguageCustomLabels {
    public string language;
    public string label;
    public string translation;
  }
}