/** Created by Sumit Saha
 *  Created Date: Nov 4 , 2023
 */

 
public with sharing class MA_AoEgcPgcService {
    private static final String GIFT_CARD_TYPE_PHYSICAL = 'Physical Gift Card';
    private static final String INTEGRATION_METADATA_AOECGPCG_DEV = 'AOEcgPcg_Dev';
    public static Mass_Appeasement__c  gcr ;
    public static List<Mass_Appeasement__c> macList = new List<Mass_Appeasement__c>();
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * map for metadata AoEgPgcRequestValue__mdt
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    gcrId  List<Id>
     * @return   List<String>
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @TestVisible
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMap {
      get {
        if (lbAPIIntegSettingsMap == null) {
          lbAPIIntegSettingsMap = LBrands_API_Integration_Setting__mdt.getAll();
        }
        return lbAPIIntegSettingsMap;
      }
      set;
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * map for metadata AoEgPgcRequestValue__mdt
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    @TestVisible
    private static Map<String, AoEgPgcRequestValue__mdt> aoEPRequestValueMap {
      get {
        if (aoEPRequestValueMap == null) {
          aoEPRequestValueMap = AoEgPgcRequestValue__mdt.getAll();
        }
        return aoEPRequestValueMap;
      }
      set;
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * invocable method which makes a callout and updates GIFT_CARD_REQUEST__C.MESSAGE_ID__C field
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    gcrId           List<Id>
     * @return   List<String>
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    // @future(callout=true)
    public static Mass_Appeasement__c sendEcgPcgReq(String orderNumber) {
        gcr = [
        SELECT
          ID,
          CreatedDate,
          GIFT_CARD_AMOUNT__C,
          Price_Override_Reason__c,
          NAME,
          GIFT_CARD_TYPE__C,
          MESSAGE_ID__C,
          ASSOCIATE_ID__C,
          RECIPIENT_ADDRESS1__C,
          RECIPIENT_ADDRESS2__C,
          RECIPIENT_CITY__C,
          RECIPIENT_COUNTRY__C,
          RECIPIENT_EMAIL__C,
          RECIPIENT_FIRST_NAME__C,
          RECIPIENT_LAST_NAME__C,
          RECIPIENT_PHONE__C,
          RECIPIENT_STATE__C,
          RECIPIENT_ZIP_POSTAL_CODE__C
        FROM Mass_Appeasement__c
        WHERE Name = :orderNumber
      ];
  
      Boolean isPCG = gcr.GIFT_CARD_TYPE__C == GIFT_CARD_TYPE_PHYSICAL? true : false;
  
      AoEgcPgcRequestWrapper.EgcPgcgRequest requestBodyWrapper = new AoEgcPgcRequestWrapper.EgcPgcgRequest();
      DateTime cptDate = gcr.CreatedDate;
      requestBodyWrapper.CapturedDate = cptDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
      requestBodyWrapper.CurrencyCode = aoEPRequestValueMap.get('CurrencyCode').Value__c;
      requestBodyWrapper.CustomerEmail = gcr.RECIPIENT_EMAIL__C;
      requestBodyWrapper.CustomerFirstName = gcr.RECIPIENT_FIRST_NAME__C;
      requestBodyWrapper.CustomerLastName = gcr.RECIPIENT_LAST_NAME__C;
        
      requestBodyWrapper.DocType = new AoEgcPgcRequestWrapper.EgcPgcgDocType();
      requestBodyWrapper.DocType.DocTypeId = aoEPRequestValueMap.get('DocTypeId').Value__c;
  
      requestBodyWrapper.Extended = new AoEgcPgcRequestWrapper.EgcPgcgExtended();
      requestBodyWrapper.Extended.IsAngelCardUsed = Boolean.valueOf(aoEPRequestValueMap.get('IsAngelCardUsed').Value__c);
      requestBodyWrapper.Extended.FreeReturn = aoEPRequestValueMap.get('FreeReturn').Value__c;
      requestBodyWrapper.Extended.AssociateOrder = aoEPRequestValueMap.get('AssociateOrder').Value__c;
       requestBodyWrapper.Extended.AssociateName = gcr.ASSOCIATE_ID__C;
        
      requestBodyWrapper.Extended.AngelCard = Boolean.valueOf(aoEPRequestValueMap.get('AngelCard').Value__c);
  
      requestBodyWrapper.IsConfirmed = Boolean.valueOf(aoEPRequestValueMap.get('IsConfirmed').Value__c);
  
      requestBodyWrapper.OrderActions = new AoEgcPgcRequestWrapper.EgcPgcgOrderActions();
      requestBodyWrapper.OrderActions.IsAlreadyTaxed = Boolean.valueOf(aoEPRequestValueMap.get('IsAlreadyTaxed').Value__c);
      requestBodyWrapper.OrderActions.IsAlreadyPriced = Boolean.valueOf(aoEPRequestValueMap.get('IsAlreadyPriced').Value__c);
      requestBodyWrapper.OrderActions.IsAlreadyCharged = Boolean.valueOf(aoEPRequestValueMap.get('IsAlreadyCharged').Value__c);
  
      requestBodyWrapper.OrderChargeDetail = aoEPRequestValueMap.get('OrderChargeDetail').Value__c;
      requestBodyWrapper.OrderExtension2 = aoEPRequestValueMap.get('OrderExtension2').Value__c;
      requestBodyWrapper.OrderHold = aoEPRequestValueMap.get('OrderHold').Value__c;
      requestBodyWrapper.OrderId = gcr.NAME;
  
      requestBodyWrapper.OrderLine = new List<AoEgcPgcRequestWrapper.EgcPgcgOrdeLine>();
      AoEgcPgcRequestWrapper.EgcPgcgOrdeLine orderLine = new AoEgcPgcRequestWrapper.EgcPgcgOrdeLine();
      orderLine.UOM = aoEPRequestValueMap.get('UOM').Value__c;
      orderLine.UnitPrice = Integer.valueOf(aoEPRequestValueMap.get('UnitPrice').Value__c);
  
      orderLine.ShipToAddress = new AoEgcPgcRequestWrapper.EgcPgcgOlShipToAddr();
      orderLine.ShipToAddress.IsAddressVerified = Boolean.valueOf( aoEPRequestValueMap.get('IsAddressVerified').Value__c);
      orderLine.ShipToAddress.Address = new AoEgcPgcRequestWrapper.EgcPgcgOlAddress();
      orderLine.ShipToAddress.Address.FirstName = gcr.RECIPIENT_FIRST_NAME__C;
      orderLine.ShipToAddress.Address.LastName = gcr.RECIPIENT_LAST_NAME__C;
      if (isPCG) {
        orderLine.ShipToAddress.Address.Address1 = gcr.RECIPIENT_ADDRESS1__C;
        orderLine.ShipToAddress.Address.City = gcr.RECIPIENT_CITY__C;
        orderLine.ShipToAddress.Address.State = gcr.RECIPIENT_STATE__C;
        orderLine.ShipToAddress.Address.PostalCode = gcr.RECIPIENT_ZIP_POSTAL_CODE__C;
        orderLine.ShipToAddress.Address.Country = gcr.RECIPIENT_COUNTRY__C;
      }
      orderLine.ShipToAddress.Address.Phone = gcr.RECIPIENT_PHONE__C;
      orderLine.ShipToAddress.Address.Email = gcr.RECIPIENT_EMAIL__C;
  
      orderLine.Quantity = Integer.valueOf( aoEPRequestValueMap.get('Quantity').Value__c );
      if (isPCG) {
        orderLine.ShippingMethodId = aoEPRequestValueMap.get('ShippingMethodId').Value__c;
      }
      DateTime pDeliveryDate = gcr.CreatedDate.addDays(14);
      orderLine.PromisedDeliveryDate = pDeliveryDate.formatGMT( 'yyyy-MM-dd\'T\'HH:mm:ss');
      orderLine.OrderLineTaxDetail = aoEPRequestValueMap.get('OrderLineTaxDetail').Value__c;
      orderLine.OrderLineNote = aoEPRequestValueMap.get('OrderLineNote').Value__c;
      orderLine.OrderLineId = aoEPRequestValueMap.get('OrderLineId').Value__c;
      orderLine.OrderLineExtension2 = aoEPRequestValueMap.get('OrderLineExtension2').Value__c;
      orderLine.OrderLineChargeDetail = aoEPRequestValueMap.get('OrderLineChargeDetail').Value__c;
  
      orderLine.OrderLineAdditional = new AoEgcPgcRequestWrapper.EgcPgcgOlOrderLineAdditional();
      orderLine.OrderLineAdditional.PriceOverrideReason = new AoEgcPgcRequestWrapper.EgcPgcgOlPriceOverrideReason();
      orderLine.OrderLineAdditional.PriceOverrideReason.ReasonId = gcr.Price_Override_Reason__c;
      orderLine.OrderLineAdditional.PriceOverrideComments = 'Mass_Appeasement';
      orderLine.OrderLineAdditional.PriceOverrideReasonId = gcr.Price_Override_Reason__c;
  
      orderLine.ItemId = isPCG ? '70008428' : '70008471';
      orderLine.IsPriceOverridden = Boolean.valueOf(aoEPRequestValueMap.get('IsPriceOverridden').Value__c);
      orderLine.IsGiftCard = Boolean.valueOf(aoEPRequestValueMap.get('IsGiftCard').Value__c);
      // orderLine.GiftCardValue = Integer.valueOf( aoEPRequestValueMap.get( 'GiftCardValue' ).Value__c );
      orderLine.GiftCardValue = Integer.valueOf(gcr.GIFT_CARD_AMOUNT__C);
      // orderLine.fulfillmentGroupId = aoEPRequestValueMap.get( 'FulfillmentGroupId' ).Value__c;
      if (isPCG) {
        orderLine.fulfillmentGroupId = gcr.Name + 'PGC';
      } else {
        orderLine.fulfillmentGroupId = gcr.Name + 'Email';
      }
      orderLine.Extended = new AoEgcPgcRequestWrapper.EgcPgcgOlExtended();
      if (isPCG) {
        orderLine.Extended.SubBrandDescription = aoEPRequestValueMap.get('SubBrandDescription').Value__c;
        orderLine.Extended.ShopperOrderLineId = aoEPRequestValueMap.get('ShopperOrderLineId').Value__c;
      }
      orderLine.Extended.PromisedSupplyType = aoEPRequestValueMap.get('PromisedSupplyType').Value__c;
      orderLine.Extended.IsClearance = aoEPRequestValueMap.get('IsClearance').Value__c;
      if (isPCG) {
        orderLine.Extended.CategoryDescription = aoEPRequestValueMap.get('CategoryDescription' ).Value__c;
        orderLine.Extended.CategoryCode = aoEPRequestValueMap.get('CategoryCode').Value__c;
      }
  
      orderLine.DeliveryMethod = new AoEgcPgcRequestWrapper.EgcPgcgOlDeliveryMethod();
      orderLine.DeliveryMethod.DeliveryMethodId = isPCG ? 'ShipToAddress' : 'Email';
  
      if (isPCG) {
        orderLine.AddressVerified = Boolean.valueOf( aoEPRequestValueMap.get('AddressVerified').Value__c);
      }
      requestBodyWrapper.OrderLine.add(orderLine);
  
      requestBodyWrapper.OrderPromotionRequest = aoEPRequestValueMap.get('OrderPromotionRequest' )
        .Value__c;
      requestBodyWrapper.OrderTaxDetail = aoEPRequestValueMap.get('OrderTaxDetail').Value__c;
      requestBodyWrapper.OrderTotal = Decimal.valueOf(aoEPRequestValueMap.get('OrderTotal').Value__c);
  
      requestBodyWrapper.OrderType = new AoEgcPgcRequestWrapper.EgcPgcgOrderType();
      requestBodyWrapper.OrderType.OrderTypeId = aoEPRequestValueMap.get('OrderTypeId').Value__c;
  
      requestBodyWrapper.PaymentStatus = String.isNotBlank(aoEPRequestValueMap.get('PaymentStatus').Value__c) ? Boolean.valueOf(aoEPRequestValueMap.get('PaymentStatus').Value__c) : null;
  
      // System.debug( '@@@@ JSON Body of Request Payload ==>> ' + requestBodyWrapper.toJson());
      LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get( INTEGRATION_METADATA_AOECGPCG_DEV);
  
      // Initially the method was returning List<String>, but agter Peter updated it, the return type of method became void
      // Therefore, this "result" variable is not needed
      // String result = lbAPIMDT.Status_Code_400_Message__c;

      
      Mass_Appeasement__c ma ;

      if (lbAPIMDT.Active__c) {
        PostRequest postReq = new PostRequest();
        postReq.setRelativeEndpoint(lbAPIMDT.Endpoint__c);
        postReq.setBody(requestBodyWrapper.toJson());
  
        // Callout
        RestResponse response = doPost(postReq);
        if (response.getStatusCode() == 200) {
          AoEgcPgcRequestWrapper.EgcPgcgResponse res = (AoEgcPgcRequestWrapper.EgcPgcgResponse) JSON.deserialize(
            String.valueOf(response.getData()),
            AoEgcPgcRequestWrapper.EgcPgcgResponse.class
          );
          System.debug('@@@@ Result ==>> ' + res);
  
          ma = new Mass_Appeasement__c();
          ma.Id = gcr.Id;
          ma.MESSAGE_ID__C = res.messageID;     
        }
      }
      return ma; 
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * Authenticate the callout request
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @return   void
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public void authenticate() {
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * make a callout for GET request
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    request         IRestRequest
     * @return   IRestResponse   callout response
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public RestResponse doGet(IRestRequest request) {
      return new RestResponse();
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * make a callout for POST request
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    request         IRestRequest
     * @return   IRestResponse   callout response
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public static RestResponse doPost(IRestRequest request) {
      // Type cast into the PostRequest
      PostRequest req = (PostRequest) request;
  
      // Make the callout request
      HttpRequest calloutRequest = new HttpRequest();
      calloutRequest.setMethod('POST');
      calloutRequest.setEndpoint(req.getRelativeEndpoint());
      calloutRequest.setBody(req.getBody());
  
      HTTPResponse resp = new Http().send(calloutRequest);
      RestResponse response = new RestResponse();
      Integer statusCode = resp.getStatusCode();
      response.setStatusCode(statusCode);
      if (statusCode != 200) {
        RestServiceError serviceError = new RestServiceError();
        serviceError.setMessage(resp.getBody());
        serviceError.setErrorCode(statusCode);
        response.setError(serviceError);
        Logger.error(resp.getBody());
        Logger.saveLog();
      } else {
        response.setData(resp.getBody());
      }
      return response;
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * make a callout for PUT request
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    request         IRestRequest
     * @return   IRestResponse   callout response
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public RestResponse doPut(IRestRequest request) {
      return new RestResponse();
    }
  
    /**
     * ───────────────────────────────────────────────────────────────────────────────────────────────┐
     * make a callout for Delete request
     * ────────────────────────────────────────────────────────────────────────────────────────────────
     * @param    request         IRestRequest
     * @return   IRestResponse   callout response
     * ───────────────────────────────────────────────────────────────────────────────────────────────┘
     */
    public RestResponse doDelete(IRestRequest request) {
      return new RestResponse();
    }
}