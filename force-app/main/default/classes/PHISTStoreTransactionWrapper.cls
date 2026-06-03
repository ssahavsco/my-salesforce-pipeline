/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* wrapper class for callout
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-02
* @modified       2021-05-27
* @systemLayer    Wrapper
* @see            ????
* @see            ????
* @JIRA Number    DP-37112, DP-37115 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-14      code commenting

* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-19      updated wrapper
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class PHISTStoreTransactionWrapper {

    public class ResponsePHISTStoreList{
        public List<ResponsePHISTStore> transactions;
    }

    public class ResponsePHISTStore{
        public String OMS;
        public String CapturedDate;
        public String CreatedTimestamp;
        public String BusinessDate;
        public Decimal OrderTotal;
        public Decimal TotalTaxes;
        public Decimal OrderShipHandleAmount;
        public String OrderId;
        public ResponseSellingChannel SellingChannel;
        public ResponseOrderType OrderType;
        public String CurrencyCode;
        public String CustomerId;
        public Boolean IsTaxExempt;
        public Boolean IsCancelled;
        public List<ResponsePayment> Payment;
        public List<ResponseOrderLine> OrderLine;
        public ResponseExtended Extended;
        public Decimal OrderSubTotal;
        public Decimal mfGiftWrapAmount;
        public ResonseExtendedLegacyOrder ExtendedLegacyOrder;
        public ResponseShopperPayment ShopperPayment;
    }
    
    public class ResponseSellingChannel{
        public String SellingChannelId;
    }
    
    public class ResponseOrderType{
        public String OrderTypeId;
    }
    
    public class ResponsePayment{
        public List<ResponsePaymentMethod> PaymentMethod;
    }
    
    public class ResponsePaymentMethod{
        public String AccountNumber;
        public Decimal Amount;
        public String CreatedTimestamp;
        public String NameOnCard;
        public ResponseCardType CardType;
        public Integer ChargeSequence;
        public ResponsePaymentType PaymentType;
        public String CurrentRefundAmount;
        public String CurrentFailedAmount;
        public String ParentOrderPaymentMethod;
        public Boolean IsCopied;
    }
    
    public class ResponseCardType{}
    
    public class ResponsePaymentType{}
    
    public class ResponseOrderLine{
        public String ItemDescription;
        public String ItemId;
        public Integer Quantity;
        public Integer ReturnableQuantity;
        public Decimal TaxableAmount;
        public Decimal OrderLineSubTotal;
        public Boolean IsGiftCard;
        public Integer UnitPrice;
        public Boolean IsPriceOverridden;
        public Boolean IsItemTaxExemptable;
        public ResponseOrderLineExtended Extended;
        public List<ResponseOrderLineTaxDetail> OrderLineTaxDetail;
        public String OrderLineId;
        public ResponsShipAddresses ShipToAddress; 
        public ResponsShipAddresses ShipFromAddress; 
        public Decimal GiftCardValue;
        public ResponseSKU Sku;
        public Boolean IsReturn;
        public Boolean IsCancelled;
        public ResponseOrderLineAdditional OrderLineAdditional;
        public ResponseLegacyOrderLineExtended LegacyOrderLineExtended;
        public Decimal TotalDiscounts;
        public ResponseChangeLog ChangeLog;
        public Boolean IsReturnable;
        public ResponseDeliveryMethod DeliveryMethod;
    }
    
    public class ResponseOrderLineExtended{
        public Boolean IsReturnableToDC;
    }
    
    public class ResponseOrderLineTaxDetail{
        public String TaxDate;
        public String Jurisdiction;
        public Decimal TaxAmount;
        public Decimal TaxRate;
        public Decimal TaxableAmount;
    }
    
    public class ResponsShipAddresses{
        public ResponseAddres Address;
    }
    
    public class ResponseAddres {}
    
    public class ResponseSKU{}
    
    public class ResponseOrderLineAdditional{}
    
    public class ResponseLegacyOrderLineExtended{}
    
    public class ResponseChangeLog{
        public ResponseModTypes ModTypes;
    }
    
    public class ResponseModTypes{}
    
    public class ResponseDeliveryMethod{}
    
    public class ResponseExtended{
        public String DeviceId;
        public String OriginStore;
        public String POSTransactionId;
        public String Brand;
        public String LoyaltyID;
    }
    
    public class ResonseExtendedLegacyOrder{
        public Decimal fundsOnBo;
    }
    
    public class ResponseShopperPayment{}
}