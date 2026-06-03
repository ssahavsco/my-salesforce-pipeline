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

* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-20      added wrapper class for cancel order request

* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-27      updated wrapper class

* v1.0            ssaha@lb.com
* 2022-01-18      updated wrapper class ~ DP-50494

* v1.0            Sumit Saha | ssaha@victoria.com
* 2022-01-18      updated wrapper class for OrderNote ~ DP-63205

* v1.0            Himanshu Mishra | hmishra@victoria.com
* 2024-07-25      updated wrapper class for ReturnTrackingDetail ~ CCS-545
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class PHISTorderTransactionWrapper {

    public class ResponseTransactions{
        public List<ResponseOrder> transactions;
    }

    public class ResponseOrder{
        public String OMS;
        public String CapturedDate;
        public String CreatedTimestamp;
        public String BusinessDate;
        public Decimal OrderTotal;
        public String formattedCurrency;
        public Decimal TotalTaxes;
        public Decimal OrderShipHandleAmount;
        public String OrderId;
        public ResponseSellingChannel SellingChannel;
        public ResponseOrderType OrderType;
        public String CurrencyCode;
        public String CustomerPhone;
        public String CustomerEmail;
        public String CustomerFirstName;
        public String CustomerLastName;
        public String CustomerId;
        public Boolean IsTaxExempt;
        public Boolean IsCancelled;
        public List<ResponsePayment> Payment;
        public List<ResponseOrderChargeDetail> OrderChargeDetail;
        public List<ResponseOrderExtension3> OrderExtension3;
        public List<ResponseOrderLine> OrderLine;
        public ResponseExtended Extended;
        public List<ResponseInvoice> Invoice;
        public String MinFulfillmentStatusId;
        public String MaxFulfillmentStatusId;
        public String MaxReturnStatusId;
        public Decimal OrderSubTotal;
        public String UpdatedTimeStamp;
        public Decimal mfGiftWrapAmount;
        public ResonseExtendedLegacyOrder ExtendedLegacyOrder;
        public ResponseShopperPayment ShopperPayment;
        public String status;
        public String LoyaltyNumber;
        public List<OrderNote> OrderNote;
        public List<ResponseReturnTrackingDetail> ReturnTrackingDetail;
    }

    public class OrderNote {
		public String NoteId;
		public String UpdatedTimestamp;
		public String CreatedBy;
		public String CreatedTimestamp;
		public Integer DisplaySequence;
		public String NoteText;
		public String OrgId;
		public String UpdatedBy;
		public NoteType NoteType;
		public Boolean IsVisible;
		public NoteCategory NoteCategory;
	}

    public class NoteType {
		public String NoteTypeId;
	}

    public class NoteCategory {
		public String NoteCategoryId;
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
        public String AccountDisplayNumber;
        public String AccountNumber;
        public Decimal Amount;
        public String CardExpiryMonth;
        public String CardExpiryYear;
        public ResponseCardType CardType;
        public String CardTypeId; // Added by Sumit, DP-50494
        public Integer ChargeSequence;
        public String CreatedTimestamp;
        public String CurrencyCode;
        public String PaymentMethodId;
        public ResponsePaymentType PaymentType;
        public String NameOnCard;
        public ResponseBillingAddress BillingAddress;
        public Decimal CurrentRefundAmount;
        public Decimal CurrentFailedAmount;
        public List<ResponseParentOrderPaymentMethod> ParentOrderPaymentMethod;
        public List<ResponsePaymentTransaction> PaymentTransaction;
        public Boolean IsCopied;
    }
    
    public class ResponseCardType{
        public String CardTypeId;
    }
    
    public class ResponsePaymentType{
        public String PaymentTypeId;
    }

    public class ResponseBillingAddress{
        public ResponseAddress Address;
        public String CreatedBy;
        public String CreatedTimestamp;
        public String PK;
        public String UpdatedBy;
        public String UpdatedTimeStamp;
        public ResponseMessage Messages;
    }

    public class ResponseAddress{
        public String Address1;
        public String City;
        public String Country;
        public String Email;
        public String FirstName;
        public String LastName;
        public String Phone;
        public String PostalCode;
        public String State;
    }

    public class ResponseMessage{
        public Decimal Size;
    }

    public class ResponseParentOrderPaymentMethod{
        
    }

    public class ResponsePaymentTransaction{
        public Decimal RequestedAmount;
        public ResponseTransactionType TransactionType;
        public List<ResponsePaymentTransactionDetail> PaymentTransactionDetail;
    }

    public class ResponseTransactionType{
        public String PaymentTransactionTypeId;
    }

    public class ResponsePaymentTransactionDetail{
        public Decimal Amount;
        public String ReferenceId;
    }

    public class ResponseOrderChargeDetail{
        public String ChargeDetailId;
        public ResponseChargeType ChargeType;
        public Decimal RequestedAmount;
        public Decimal ChargeTotal;
    }

    public class ResponseChargeType{
        public String ChargeTypeId;
    }

    public class ResponseOrderExtension3{
        public String UpdatedBy;
        public String UpdatedTimestamp;
        public String OrgId;
        public String CreatedTimestamp;
        public String CreatedBy;
        public ResponseOrderExtension3Extended Extended;
        public String OrderExtension3Id;
        public String ContextId;
    }

    public class ResponseOrderExtension3Extended{
        public Decimal RetailerShippingPrice;
        public Decimal ShopperTotal;
        public Decimal EffectiveFxRate;
        public String ShopperCurrency;
        public Decimal RetailerDuty;
        public Decimal RetailerTaxes;
        public Decimal RetailerDeliveryTaxes;
        public Decimal ShopperDuty;
        public Decimal ShopperShippingPrice;
        public Decimal ShopperDeliveryTaxes;
        public Decimal ShopperDeliveryDuty;
        public Decimal ShopperTaxes;
        public Decimal ShopperOtherTaxes;
        public Decimal ShopperCurrencyReturnRefundTotal;
        public Decimal RetailerDeliveryDuty;
        public String PaymentMethod;
        public String ShopperCultureLanguageIso;
        public String PaymentMethodCardBrand;
        public Decimal ShopperCurrencySubTotal;
        public Decimal ShopperTotalDiscount;
    }
    
    public class ResponseOrderLine{
        public String OrderId;
        public String ItemDescription;
        public String ItemId;
        public Integer Quantity;
        public Integer ReturnableQuantity;
        public Decimal TaxableAmount;
        public Decimal OrderLineSubTotal;
        public Boolean IsGiftCard;
        public String ItemSize;
        public String ItemColorDescription;
        public Decimal UnitPrice;
        public Boolean IsPriceOverridden;
        public Boolean IsItemTaxExemptable;
        public ResponseOrderLineExtended Extended;
        public List<ResponseOrderLineExtension3> OrderLineExtension3;
        public List<ResponseOrderLineTaxDetail> OrderLineTaxDetail;
        public String OrderLineId;
        public String ParentOrderId;
        public ResponsShipAddresses ShipToAddress;
        public ResponsShipAddresses ShipFromAddress;
        public String MaxFulfillmentStatusId;
        public String ShippingMethodId;
        public String PromisedDeliveryDate;
        public String PromisedShipDate;
        public Decimal GiftCardValue;
        public List<ResponseOrderLineNote> OrderLineNote;
        public List<ResponseFulfillmentDetail> FulfillmentDetail;
        public ResponseSKU Sku;
        public Boolean IsReturn;
        public Boolean IsCancelled;
        public ResponseOrderLineAdditional OrderLineAdditional;
        public Decimal TotalDiscounts;
        public ResponseLegacyOrderLineExtended LegacyOrderLineExtended;
        public Boolean IsReturnable;
        public ResponseChangeLog ChangeLog;
        public ResponseDeliveryMethod DeliveryMethod;
        public List<ResponseOrderLinePickupDetail> OrderLinePickupDetail;
        public Boolean IsOnlineIndicator;
        public Boolean IsReward;
        public String SmallImageURI;
        public string ShipToLocationId;
        public String FulfillmentStatus; 
    }
    
    public class ResponseOrderLineExtended{
        public Boolean IsReturnableToDC;
        public String IsClearance;
        public String CustomOrderLineSubTotal;
        public String PromisedSupplyType;
    }

    public class ResponseOrderLineExtension3{
        public String UpdatedBy;
        public String UpdatedTimestamp;
        public String OrgId;
        public String CreatedTimestamp;
        public String CreatedBy;
        public String OrderLineExtension3Id;
        public ResponseOrderLineExtension3Extended Extended;
        public String ContextId;
        public String PK;
    }

    public class ResponseOrderLineExtension3Extended{
        public Decimal ShopperLineDisplayBeforeDiscount;
        public Decimal ShopperCurrencyItemRefundAmount;
        public String ShopperItemDescription;
        public String HsCode;
        public Decimal ShopperLineDisplayPrice;
        public Decimal RetailerItemTaxes;
        public Decimal ShopperUnitPriceAfterDiscount;
        public String ShopperItemTitle;
        public Decimal ShopperItemTaxes;
        public Decimal ShopperUnitPriceBeforeDiscount;
        public Decimal ShopperItemSubTotal;
    }
    
    public class ResponseOrderLineTaxDetail{
        public String TaxDate;
        public String Jurisdiction;
        public String JurisdictionTypeId;
        public Decimal TaxAmount;
        public String TaxDetailId;
        public Decimal TaxRate;
        public String TaxTypeId;
        public Decimal TaxableAmount;
    }
    
    public class ResponsShipAddresses{
        public ResponseAddress Address;
    }

    public class ResponseOrderLineNote{
        public String CreatedBy;
        public String CreatedTimestamp;
        public Decimal DisplaySequence;
        public Boolean IsVisible;
        public String NoteId;
        public String NoteText;
        public String OrgId;
        public String PK;
        public String UpdatedBy;
        public String UpdatedTimeStamp;
        public ResponseNoteType NoteType;
        public ResponseNoteCategory NoteCategory;
    }

    public class ResponseNoteType{
        public String NoteTypeId;
    }

    public class ResponseNoteCategory{
        public String NoteCategoryId;
    }

    public class ResponseFulfillmentDetail{
        public String CarrierCode;
        public String CreatedBy;
        public String CreatedTimestamp;
        public String FulfillmentDate;
        public String FulfillmentDetailId;
        public String GcNumber;
        public String GcPIN;
        public String GiftCardNumber;
        public String GiftCardPIN;
        public String ItemId;
        public String OrgId;
        public String PK;
        public String PackageDetailId;
        public String PackageId;
        public Decimal Quantity;
        public String ReleaseId;
        public String ReleaseLineId;
        public String StatusId;
        public String UOM;
        public String UpdatedBy;
        public String UpdatedTimeStamp;
        public String TrackingNumber;
        public ResponseLegacyFulfillmentDetailExtended LegacyFulfillmentDetailExtended;
        public ResponseFulfillmentExtended Extended;
    }

    public class ResponseLegacyFulfillmentDetailExtended{

    }
    public class ResponseFulfillmentExtended{
        public String  HTOReturnTrackingNo;
    }
    
    public class ResponseSKU{
        public String Color;
        public String Size;
        public String RootStyleID;
    }
    
    public class ResponseOrderLineAdditional{
        public String ReturnReason;
    }
    
    public class ResponseLegacyOrderLineExtended{}
    
    public class ResponseChangeLog{
        public ResponseModTypes ModTypes;
    }
    
    public class ResponseModTypes{}
    
    public class ResponseDeliveryMethod{
        public String DeliveryMethodId;
    }

    public class ResponseOrderLinePickupDetail{
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public Boolean IsPrimary;
    }
    
    public class ResponseExtended{
        public String DeviceId;
        public String OriginStore;
        public String POSTransactionId;
        public String Brand;
        public String LoyaltyID;
        public String FreeReturn;
        public String AssociateOrder;
        public String CID;
        public String Version;
        public String OrderShippingCharge;
        public String OrderSpecialOffer;
        public String OrderTrackingNumber;
    }

    public class ResponseInvoice{
        public Decimal AmountProcessed;
        public String CreatedBy;
        public String CreatedTimestamp;
        public Decimal FailedAmount;
        public String FulfillmentDate;
        public String InvoiceId;
        public Decimal InvoiceSubTotal;
        public Decimal InvoiceTotal;
        public String OrgId;
        public String PK;
        public String ParentOrderId;
        public String PackageId;
        public Decimal PublishCount;
        public Decimal TotalCharges;
        public Decimal TotalDiscounts;
        public Decimal TotalTaxes;
        public String UpdatedBy;
        public String UpdatedTimeStamp;
        public ResponseInvoiceType InvoiceType;
        public List<ResponseInvoiceLine> InvoiceLine;
    }

    public class ResponseInvoiceType{
        public String InvoiceTypeId;
    }

    public class ResponseInvoiceLine{
        public String AddressId;
        public String CreatedBy;
        public String CreatedTimestamp;
        public String FulfillmentGroupId;
        public String InvoiceLineId;
        public Decimal InvoiceLineSubTotal;
        public Decimal InvoiceLineTotal;
        public Boolean IsTaxIncluded;
        public String ItemId;
        public String OrderLineCreatedTimestamp;
        public String OrderLineId;
        public String OrderedItemId;
        public Decimal OrderedQuantity;
        public String OrderedUOM;
        public String OrgId;
        public String PK;
        public String PackageDetailId;
        public Decimal Quantity;
        public Decimal TotalCharges;
        public Decimal TotalDiscounts;
        public Decimal TotalTaxes;
        public String UOM;
        public Decimal UnitPrice;
        public String UpdatedBy;
        public String UpdatedTimeStamp;
        public ResponsShipAddresses ShipToAddress; 
        public ResponsShipAddresses ShipFromAddress;
        public ResponseMessage Messages;
        public ResponseInvoiceLineExtended Extended;
    }
    
    public class ResonseExtendedLegacyOrder{
        public Decimal fundsOnBo;
    }

    public class ResponseInvoiceLineExtended{
        public String CustomInvoiceLineSubTotal;
    }
    
    public class ResponseShopperPayment{}

    // Delete request wrapper
    public class DeleteRequest{
        public String OrderId;
        public ResponseFulfillmentStatus MaxFulfillmentStatus;
        public Boolean IsCancelled;
        public ResponseFulfillmentStatus MinFulfillmentStatus;
        public CancellingReason CancelReason;
        public String CancelComments;
    }

    public class ResponseFulfillmentStatus{
        public String StatusId;
    }

    public class CancellingReason{
        public String ReasonId;
    }
    
    public class ResponseReturnTrackingDetail{
        public String CarrierCode;
        public String ReturnTrackingNumber;
    }
}