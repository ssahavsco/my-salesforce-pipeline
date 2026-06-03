/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for ECG/PCG Service Request.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shujaath Mohammed  <shujaath.mohammed@neuraflash.com>
* @modifiedBy     Shujaath Mohammed  <shujaath.mohammed@neuraflash.com>
* @maintainedBy   Shujaath Mohammed  <shujaath.mohammed@neuraflash.com>
* @version        1.0
* @created        2021-04-20
* @modified       2021-06-02
* @systemLayer    Controller
* @Jira Number    DP-37135, DP-37137
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Shujaath Mohammed  <shujaath.mohammed@neuraflash.com>

* v1.0            Ravikant Kedia  <ravikant.kedia@neuraflash.com>

* v1.0            Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* 2021-06-02      added method toJson() to wrapper class EgcPgcgRequest
*
* v1.2          Shujaath Mohammed <shujaath.mohammed@neuraflash.com>
* 2021-06-03    Updated CapturedDate and PromisedDeliveryDate format.
*v1.3			Sharath Vadla <svadla@victoria.com>
2023-06-15  	Added AssociateName attribute to EgcPgcgExtended class
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class AoEgcPgcRequestWrapper {
  // Request Wrapper class
  public class EgcPgcgRequest {
    public String CapturedDate;
    public String CurrencyCode;
    public String CustomerEmail;
    public String CustomerFirstName;
    public String CustomerLastName;
    public EgcPgcgDocType DocType;
    public EgcPgcgExtended Extended;
    public Boolean IsConfirmed;
    public EgcPgcgOrderActions OrderActions;
    public String OrderChargeDetail;
    public String OrderExtension2;
    public String OrderHold;
    public String OrderId;
    public List<EgcPgcgOrdeLine> OrderLine;
    public String OrderPromotionRequest;
    public String OrderTaxDetail;
    public Decimal OrderTotal;
    public EgcPgcgOrderType OrderType;
    public Boolean PaymentStatus;

    public String toJson() {
      JSONGenerator g = JSON.createGenerator(false);
      g.writeStartObject();
      g.writeStringField('CapturedDate', CapturedDate);
      if (CurrencyCode != null) {
        g.writeStringField('CurrencyCode', CurrencyCode);
      } else {
        g.writeNullField('CurrencyCode');
      }
      if (CustomerEmail != null) {
        g.writeStringField('CustomerEmail', CustomerEmail);
      } else {
        g.writeNullField('CustomerEmail');
      }
      if (CustomerFirstName != null) {
        g.writeStringField('CustomerFirstName', CustomerFirstName);
      } else {
        g.writeNullField('CustomerFirstName');
      }
      if (CustomerLastName != null) {
        g.writeStringField('CustomerLastName', CustomerLastName);
      } else {
        g.writeNullField('CustomerLastName');
      }
      g.writeObjectField('DocType', DocType);
      g.writeObjectField('Extended', Extended);
      if (IsConfirmed != null) {
        g.writeBooleanField('IsConfirmed', IsConfirmed);
      } else {
        g.writeNullField('IsConfirmed');
      }
      g.writeObjectField('OrderActions', OrderActions);
      if (OrderChargeDetail != null) {
        g.writeStringField('OrderChargeDetail', OrderChargeDetail);
      } else {
        g.writeNullField('OrderChargeDetail');
      }
      if (OrderExtension2 != null) {
        g.writeStringField('OrderExtension2', OrderExtension2);
      } else {
        g.writeNullField('OrderExtension2');
      }
      if (OrderHold != null) {
        g.writeStringField('OrderHold', OrderHold);
      } else {
        g.writeNullField('OrderHold');
      }
      if (OrderId != null) {
        g.writeStringField('OrderId', OrderId);
      } else {
        g.writeNullField('OrderId');
      }
      EgcPgcgOrdeLine ol = OrderLine[0];
      g.writeFieldName('OrderLine');
      g.writeStartArray();
      g.writeStartObject();
      if (ol.UOM != null) {
        g.writeStringField('UOM', ol.UOM);
      } else {
        g.writeNullField('UOM');
      }
      if (ol.UnitPrice != null) {
        g.writeNumberField('UnitPrice', ol.UnitPrice);
      } else {
        g.writeNullField('UnitPrice');
      }
      g.writeFieldName('ShipToAddress');
      g.writeStartObject();
      g.writeBooleanField(
        'IsAddressVerified',
        ol.ShipToAddress.IsAddressVerified
      );
      g.writeFieldName('Address');
      g.writeStartObject();
      EgcPgcgOlAddress add = ol.ShipToAddress.Address;
      if (add.FirstName != null) {
        g.writeStringField('FirstName', add.FirstName);
      } else {
        g.writeNullField('FirstName');
      }
      if (add.LastName != null) {
        g.writeStringField('LastName', add.LastName);
      } else {
        g.writeNullField('LastName');
      }
      if (add.Address1 != null) {
        g.writeStringField('Address1', add.Address1);
      } else {
        g.writeNullField('Address1');
      }
      if (add.City != null) {
        g.writeStringField('City', add.City);
      } else {
        g.writeNullField('City');
      }
      if (add.State != null) {
        g.writeStringField('State', add.State);
      } else {
        g.writeNullField('State');
      }
      if (add.PostalCode != null) {
        g.writeStringField('PostalCode', add.PostalCode);
      } else {
        g.writeNullField('PostalCode');
      }
      if (add.Country != null) {
        g.writeStringField('Country', add.Country);
      } else {
        g.writeNullField('Country');
      }
      if (add.Phone != null) {
        g.writeStringField('Phone', add.Phone);
      } else {
        g.writeNullField('Phone');
      }
      if (add.Email != null) {
        g.writeStringField('Email', add.Email);
      } else {
        g.writeNullField('Email');
      }
      g.writeEndObject();
      g.writeEndObject();
      if (ol.Quantity != null) {
        g.writeNumberField('Quantity', ol.Quantity);
      } else {
        g.writeNullField('Quantity');
      }
      if (ol.ShippingMethodId != null) {
        g.writeStringField('ShippingMethodId', ol.ShippingMethodId);
      } else {
        g.writeNullField('ShippingMethodId');
      }
      if (ol.PromisedDeliveryDate != null) {
        g.writeStringField('PromisedDeliveryDate', ol.PromisedDeliveryDate);
      } else {
        g.writeNullField('PromisedDeliveryDate');
      }
      if (ol.OrderLineTaxDetail != null) {
        g.writeStringField('OrderLineTaxDetail', ol.OrderLineTaxDetail);
      } else {
        g.writeNullField('OrderLineTaxDetail');
      }
      if (ol.OrderLineNote != null) {
        g.writeStringField('OrderLineNote', ol.OrderLineNote);
      } else {
        g.writeNullField('OrderLineNote');
      }
      if (ol.OrderLineId != null) {
        g.writeStringField('OrderLineId', ol.OrderLineId);
      } else {
        g.writeNullField('OrderLineId');
      }
      if (ol.OrderLineExtension2 != null) {
        g.writeStringField('OrderLineExtension2', ol.OrderLineExtension2);
      } else {
        g.writeNullField('OrderLineExtension2');
      }
      if (ol.OrderLineChargeDetail != null) {
        g.writeStringField('OrderLineChargeDetail', ol.OrderLineChargeDetail);
      } else {
        g.writeNullField('OrderLineChargeDetail');
      }
      g.writeFieldName('OrderLineAdditional');
      g.writeStartObject();
      g.writeObjectField(
        'PriceOverrideReason',
        ol.OrderLineAdditional.PriceOverrideReason
      );
      g.writeStringField(
        'PriceOverrideComments',
        ol.OrderLineAdditional.PriceOverrideComments
      );
      if (ol.OrderLineAdditional.PriceOverrideReasonId != null) {
        g.writeStringField(
          'PriceOverrideReasonId',
          ol.OrderLineAdditional.PriceOverrideReasonId
        );
      } else {
        g.writeNullField('PriceOverrideReasonId');
      }
      g.writeEndObject();
      g.writeStringField('ItemId', ol.ItemId);
      if (ol.IsPriceOverridden != null) {
        g.writeBooleanField('IsPriceOverridden', ol.IsPriceOverridden);
      } else {
        g.writeNullField('IsPriceOverridden');
      }
      if (ol.IsHazmat != null) {
        g.writeBooleanField('IsHazmat', ol.IsHazmat);
      } else {
        g.writeNullField('IsHazmat');
      }
      if (ol.IsGiftCard != null) {
        g.writeBooleanField('IsGiftCard', ol.IsGiftCard);
      } else {
        g.writeNullField('IsGiftCard');
      }
      if (ol.GiftCardValue != null) {
        g.writeNumberField('GiftCardValue', ol.GiftCardValue);
      } else {
        g.writeNullField('GiftCardValue');
      }
      g.writeStringField('FulfillmentGroupId', ol.FulfillmentGroupId);
      g.writeObjectField('Extended', ol.Extended);
      g.writeObjectField('DeliveryMethod', ol.DeliveryMethod);
      if (ol.AddressVerified != null) {
        g.writeBooleanField('AddressVerified', ol.AddressVerified);
      } else {
        g.writeNullField('AddressVerified');
      }
      g.writeEndObject();
      g.writeEndArray();
      if (OrderPromotionRequest != null) {
        g.writeStringField('OrderPromotionRequest', OrderPromotionRequest);
      } else {
        g.writeNullField('OrderPromotionRequest');
      }
      if (OrderTaxDetail != null) {
        g.writeStringField('OrderTaxDetail', OrderTaxDetail);
      } else {
        g.writeNullField('OrderTaxDetail');
      }
      if (OrderTotal != null) {
        g.writeNumberField('OrderTotal', OrderTotal);
      } else {
        g.writeNullField('OrderTotal');
      }
      g.writeObjectField('OrderType', OrderType);
      if (PaymentStatus != null) {
        g.writeBooleanField('PaymentStatus', PaymentStatus);
      } else {
        g.writeNullField('PaymentStatus');
      }
      g.writeEndObject();
      return g.getAsString();
    }
  }

  public class EgcPgcgDocType {
    public String DocTypeId;
  }

  public class EgcPgcgExtended {
    public Boolean IsAngelCardUsed;
    public String FreeReturn;
    public String AssociateOrder;
    public String AssociateName;
    public Boolean AngelCard;
  }

  public class EgcPgcgOrderActions {
    public Boolean IsAlreadyTaxed;
    public Boolean IsAlreadyPriced;
    public Boolean IsAlreadyCharged;
  }

  public class EgcPgcgOrdeLine {
    public String UOM;
    public Integer UnitPrice;
    public EgcPgcgOlShipToAddr ShipToAddress;
    public Integer Quantity;
    public String ShippingMethodId;
    public String PromisedDeliveryDate;
    public String OrderLineTaxDetail;
    public String OrderLineNote;
    public String OrderLineId;
    public String OrderLineExtension2;
    public String OrderLineChargeDetail;
    public EgcPgcgOlOrderLineAdditional OrderLineAdditional;
    public String ItemId;
    public Boolean IsPriceOverridden;
    public Boolean IsHazmat;
    public Boolean IsGiftCard;
    public Integer GiftCardValue;
    public String FulfillmentGroupId;
    public EgcPgcgOlExtended Extended;
    public EgcPgcgOlDeliveryMethod DeliveryMethod;
    public Boolean AddressVerified;
  }

  public class EgcPgcgOlShipToAddr {
    public Boolean IsAddressVerified;
    public EgcPgcgOlAddress Address;
  }

  public class EgcPgcgOlAddress {
    public String FirstName;
    public String LastName;
    public String Address1;
    public String City;
    public String State;
    public String PostalCode;
    public String Country;
    public String Phone;
    public String Email;
  }

  public class EgcPgcgOlOrderLineAdditional {
    public EgcPgcgOlPriceOverrideReason PriceOverrideReason;
    public String PriceOverrideComments;
    public String PriceOverrideReasonId;
  }

  public class EgcPgcgOlPriceOverrideReason {
    public String ReasonId;
  }

  public class EgcPgcgOlExtended {
    public String SubBrandDescription;
    public String ShopperOrderLineId;
    public String PromisedSupplyType;
    public String IsClearance;
    public String CategoryDescription;
    public String CategoryCode;
  }

  public class EgcPgcgOlDeliveryMethod {
    public String DeliveryMethodId;
  }

  public class EgcPgcgOrderType {
    public String OrderTypeId;
  }

  // Response Wrapper class
  public class EgcPgcgResponse {
    public String messageID;
  }
}