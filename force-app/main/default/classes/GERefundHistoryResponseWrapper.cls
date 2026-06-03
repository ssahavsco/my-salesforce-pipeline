/**
 *  created by Sumit Saha
 *
 */

public class GERefundHistoryResponseWrapper {
  public String orderId;
  public String externalOrderId;
  public Refunds[] refunds;
  public RefundableAmount refundableAmount;

  class Refunds {
    public String refundID;
    public String initiatedBy;
    public String currencyCode;
    public Boolean dutiesRefund;
    public String totalAmountInShopperCurrency;
    public String totalAmountInMerchantCurrency;
    public String serviceGestureAmountInShopperCurrency;
    public String dutiesAmountInShopperCurrency;
    public String shippingAmountInShopperCurrency;
    public String customerPrepaidAmountInShopperCurrency;
    public String customerPrepaidAmountInMerchantCurrency;
    public String totalGiftCardsAmountInShopperCurrency;
    public String totalGiftCardsAmountinMerchantCurrency;
    public String totalLoyaltyPointsAmount;
    public String merchantCurrencyCode;
    public RefundReason refundReason;
    public Products[] products;
    public RefundComponents[] refundComponents;
    public String refundComments;
    public RefundDocument[] refundDocument;
    public String refundDate;
  }
  class RefundReason {
    public String orderRefundReasonCode;
    public String name;
  }
  class Products {
    public String cartItemId;
    public Integer refundQuantity;
    public String refundAmountInShopperCurrency;
    public String refundAmountInMerchantCurrency;
    public String refundAmountPercent;
    public String refundReason;
    public String refundComments;
    public String sku;
    public String productCode;
    public String productGroupCode;
  }
  class RefundComponents {
    public String amountInShopperCurrency;
    public String amountInMerchantCurrency;
    public String isChargedToMerchant;
    public String componentType;
  }
  class RefundDocument {
    public String documentData;
    public String creditNoteUrl;
    public String documentTypeCode;
    public String documentTypeName;
    public String documentExtension;
  }
  class RefundableAmount {
    public String currencyCode;
    public String totalAmountInShopperCurrency;
    public String shippingAmountInShopperCurrency;
    public String dutiesAmountInShopperCurrency;
    public ProductsLines[] products;
  }

  class ProductsLines {
    public String lineItemId;
    public Integer sku;
    public String productCode;
    public String productGroupCode;
    public String totalAmountInShopperCurrency;
  }

  public String httpStatusCode;

  public String error;
  public String message;
  public String code;
  public String customMessage;

  public static GERefundHistoryResponseWrapper parse(String json) {
    return (GERefundHistoryResponseWrapper) System.JSON.deserialize(
      json,
      GERefundHistoryResponseWrapper.class
    );
  }
}