/** International Project : Test Class for Unit testing
 *  Created By:  ssaha@victoria.com | Date: 03-Jun-24
 *  Modified By:  
 */


@isTest
public with sharing class GEServiceCallOutsTest {
    
    private class MockHttpResponse implements HttpCalloutMock {
        GERefundWrapperResponse response = new GERefundWrapperResponse();
        GERefundHistoryResponseWrapper historyResponse = new GERefundHistoryResponseWrapper();
        String authResponse;

        MockHttpResponse(GERefundWrapperResponse obj){
            response = obj;
        }
        MockHttpResponse(GERefundHistoryResponseWrapper obj){
            historyResponse = obj;
        }
        MockHttpResponse(String res){
            authResponse = res;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('/api/order/cancel')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(JSON.serialize(response));
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().contains('/refund/claim')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(JSON.serialize(response));
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().contains('/refund/itemlevel')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(JSON.serialize(response));
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().contains('/refund/shipping')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(JSON.serialize(response));
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().contains('/orderdetails/v8/refunds')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(JSON.serialize(historyResponse));
                res.setStatusCode(200);
                return res;
            }
            else if (req.getEndpoint().contains('apiauthentication/v1/token')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(authResponse);
                res.setStatusCode(200);
                return res;
            }
            return res;    
        }
    }

    private class MockHttpResponseFailure implements HttpCalloutMock {
        GERefundWrapperResponse response = new GERefundWrapperResponse();
        Integer statusCode ;

        public MockHttpResponseFailure(GERefundWrapperResponse obj, Integer code){
            response = obj;
            statusCode = code;
        }
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            if(req.getEndpoint().contains('refund/claim')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody(JSON.serialize(response));
                res.setStatusCode(statusCode);
                return res;
            }
            else if (req.getEndpoint().contains('apiauthentication/v1/token')){
                String auth = '{"access_token":"ODO2ST7GMP2ZGRKYKF0UCA","expires_in":7200,"token_type":"Bearer"}';
                res.setHeader('Content-Type', 'application/json');
                res.setBody(auth);
                res.setStatusCode(200);
                return res;
            }
            return res;
        }
    }

    @isTest(SeeAllData=true)
    public static void generateToken(){
        String response = '{"access_token":"ODO2ST7GMP2ZGRKYKF0UCA","expires_in":7200,"token_type":"Bearer"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(response));
        GEServiceCallOuts.generateAuthToken();
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void cancelTest(){
        GEServiceCallOuts.CancelRequest cancel = new  GEServiceCallOuts.CancelRequest();
        cancel.actionType = 'CancelOrderLine';
        cancel.cancelRequest.Process = 'OrderLineCancel';
        cancel.cancelRequest.OrderId = 'G000002377';
        cancel.cancelRequest.Comments = 'Cancellation at line level';
        cancel.cancelRequest.AssociateId = 'ssaha';

        INTLOrderCancellation.OrderLine ordLine = new  INTLOrderCancellation.OrderLine();
        ordLine.AssociateId = 'ssaha';
        ordLine.Comments = 'Cancellation at line level';
        ordLine.OrderLineId = '30d1e9e6-fc5e-48ff-ba14-dfac318273c5';
        ordLine.Quantity = '1';
        ordLine.ReasonId = 'Customer Request';

        List<INTLOrderCancellation.OrderLine> listOrderLine = new List<INTLOrderCancellation.OrderLine>();
        listOrderLine.add(ordLine);
        cancel.cancelRequest.OrderLine = listOrderLine;

        GERefundWrapperResponse response = new GERefundWrapperResponse();
        response.messageID = '321343456465465';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(response));
        String out = GEServiceCallOuts.cancel(JSON.serialize(cancel));
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void refundAppeasementTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(refundResponsePayload()));
        String outputClaim = GEServiceCallOuts.refund(refundRequestPayload('Appeasement'));
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void history(){
        string json = '{"request":{"orderTypeId":"VSD-GLOBALE","orderId":"G000629711","historyNotReqd":false},"actionType":"RefundHistory"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(refundHistoryResponsePayload()));
        String outputClaim = GEServiceCallOuts.refundHistory(json);
        Test.stopTest();
    }

    public static GERefundHistoryResponseWrapper refundHistoryResponsePayload(){
        string json = '{"orderId":"G000629789","externalOrderId":"GE98479833US","refunds":[{"refundID":"101514","initiatedBy":"mawhite","currencyCode":"CAD","dutiesRefund":true,"totalAmountInShopperCurrency":"40.68","totalAmountInMerchantCurrency":"21.59","serviceGestureAmountInShopperCurrency":"0","dutiesAmountInShopperCurrency":"4.6800","shippingAmountInShopperCurrency":"0.0","customerPrepaidAmountInShopperCurrency":"0","customerPrepaidAmountInMerchantCurrency":"0.000000","totalGiftCardsAmountInShopperCurrency":"0","totalGiftCardsAmountinMerchantCurrency":"0","totalLoyaltyPointsAmount":"0","merchantCurrencyCode":"USD","refundReason":{"name":"OutOfStock"},"products":[{"cartItemId":"19af49c8-d7f2-4036-b044-638d0dfc8969","refundQuantity":"1","refundAmountInShopperCurrency":"36.0000","refundAmountInMerchantCurrency":"21.5900","refundAmountPercent":"0.0","refundReason":"Missing Item","sku":"26128940","productCode":"26128940","productGroupCode":"G001629718"}],"refundComponents":[{"amountInShopperCurrency":"4.6800","amountInMerchantCurrency":"3.36","isChargedToMerchant":"FALSE","componentType":"Duties"},{"amountInShopperCurrency":"36.00","amountInMerchantCurrency":"21.59","isChargedToMerchant":"TRUE","componentType":"Products"}]},{"refundID":"101515","currencyCode":"CAD","totalAmountInShopperCurrency":"5.43","dutiesAmountInShopperCurrency":"5.43","shippingAmountInShopperCurrency":"0.0","customerPrepaidAmountInShopperCurrency":"0","customerPrepaidAmountInMerchantCurrency":"0.000000","totalGiftCardsAmountInShopperCurrency":"0","totalGiftCardsAmountinMerchantCurrency":"0","totalLoyaltyPointsAmount":"0","merchantCurrencyCode":"USD","refundReason":{"name":"Return"},"refundComponents":[{"amountInShopperCurrency":"5.43","amountInMerchantCurrency":"3.25664250","isChargedToMerchant":"TRUE","componentType":"Duties"}],"refundComments":"Auto generated refund DT"},{"refundID":"101516","initiatedBy":"mawhite","currencyCode":"CAD","dutiesRefund":true,"totalAmountInShopperCurrency":"9.03","totalAmountInMerchantCurrency":"4.80","serviceGestureAmountInShopperCurrency":"0","dutiesAmountInShopperCurrency":"1.0400","shippingAmountInShopperCurrency":"0.0","customerPrepaidAmountInShopperCurrency":"0","customerPrepaidAmountInMerchantCurrency":"0.000000","totalGiftCardsAmountInShopperCurrency":"0","totalGiftCardsAmountinMerchantCurrency":"0","totalLoyaltyPointsAmount":"0","merchantCurrencyCode":"USD","refundReason":{"name":"OutOfStock"},"products":[{"cartItemId":"34be17d3-5ede-4621-9fc9-36a3a45aad95","refundQuantity":"1","refundAmountInShopperCurrency":"7.9900","refundAmountInMerchantCurrency":"4.8000","refundAmountPercent":"0.0","refundReason":"Damaged Item","sku":"26133085","productCode":"26133085","productGroupCode":"G000629789"}],"refundComponents":[{"amountInShopperCurrency":"1.0400","amountInMerchantCurrency":"0.75","isChargedToMerchant":"FALSE","componentType":"Duties"},{"amountInShopperCurrency":"7.99","amountInMerchantCurrency":"4.80","isChargedToMerchant":"TRUE","componentType":"Products"}]},{"refundID":"101517","currencyCode":"CAD","totalAmountInShopperCurrency":"1.20","dutiesAmountInShopperCurrency":"1.20","shippingAmountInShopperCurrency":"0.0","customerPrepaidAmountInShopperCurrency":"0","customerPrepaidAmountInMerchantCurrency":"0.000000","totalGiftCardsAmountInShopperCurrency":"0","totalGiftCardsAmountinMerchantCurrency":"0","totalLoyaltyPointsAmount":"0","merchantCurrencyCode":"USD","refundReason":{"name":"Return"},"refundComponents":[{"amountInShopperCurrency":"1.20","amountInMerchantCurrency":"0.71970000","isChargedToMerchant":"TRUE","componentType":"Duties"}],"refundComments":"Auto generated refund DT"}],"refundableAmount":{"currencyCode":"CAD","totalAmountInShopperCurrency":"292.76","shippingAmountInShopperCurrency":"8","dutiesAmountInShopperCurrency":"32.76","products":[{"lineItemId":"19af49c8-d7f2-4036-b044-638d0dfc8969","sku":"26128940","productCode":"26128940","productGroupCode":"G000629789","totalAmountInShopperCurrency":"108"},{"lineItemId":"34be17d3-5ede-4621-9fc9-36a3a45aad95","sku":"26133085","productCode":"26133085","productGroupCode":"G000629789","totalAmountInShopperCurrency":"0"},{"lineItemId":"a80ffb73-0382-45ad-9bae-e29a9f3b08f1","sku":"26128933","productCode":"26128933","productGroupCode":"G000629789","totalAmountInShopperCurrency":"144"}]}}';
        GERefundHistoryResponseWrapper result =  GERefundHistoryResponseWrapper.parse(json);
        return result;
    } 




    @isTest(SeeAllData=true)
    public static void refundClaimTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(refundResponsePayload()));
        String outputClaim = GEServiceCallOuts.refund(refundRequestPayload('Claim'));
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void refundClaimFailure400Test(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure(refundResponsePayload(), 400 ));
        String outputClaim = GEServiceCallOuts.refund(refundRequestPayload('Claim'));
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void refundClaimFailure401Test(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure(refundResponsePayload(), 401 ));
        String outputClaim = GEServiceCallOuts.refund(refundRequestPayload('Claim'));
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void refundClaimFailure500Test(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure(refundResponsePayload(), 500 ));
        String outputClaim = GEServiceCallOuts.refund(refundRequestPayload('Claim'));
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void refundShippingTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(refundResponsePayload()));
        String outputClaim = GEServiceCallOuts.refund(refundRequestPayload('Shipping'));
        Test.stopTest();
    }

    public static String refundRequestPayload(String type){
        GEServiceCallOuts.Input input = new GEServiceCallOuts.Input();
        input.actionType = type;
        input.request.orderType = 'VSD-GLOBALE';
        input.request.orderId = 'G000003733';

        GERefundWrapperRequest.LineItems ordLine = new GERefundWrapperRequest.LineItems ();
        ordLine.sku = '26604152';
        ordLine.refundCondition = 'CCC SS: Short Ship'   ;
        ordLine.refundBasisValue = 1.0;
        ordLine.refundBasisType = 'Quantity';
        ordLine.reasonCode = 'CCC SS (Short Ship) Return';
        ordLine.id = '01675392-17bb-4c46-9aee-7376bc932d21';
        ordLine.comments = 'test';

        List<GERefundWrapperRequest.LineItems> listOrdLine = new List<GERefundWrapperRequest.LineItems>();
        listOrdLine.add(ordLine);
        input.request.lineItems = listOrdLine;
        input.request.dutiesTaxesRefund.amount = 0.0;
        input.request.dutiesTaxesRefund.type =  'Full';
        input.request.comments = 'test';
        input.request.actionByUser = 'ssaha';
        return JSON.serialize(input);
    }

    public static GERefundWrapperResponse refundResponsePayload(){
        GERefundWrapperResponse response = new GERefundWrapperResponse();
        response.totalAmountInShopperCurrency = '123';
        response.totalAmountInMerchantCurrency = '12.30';
        response.success = true;
        response.refundId = '74125';
        response.messageID = null;
        response.message = null;
        response.httpStatusCode = '200';
        response.error = null;
        response.customMessage = null;

        GERefundWrapperResponse.Components comp = new GERefundWrapperResponse.Components();
        comp.type = 'Products';
        comp.amountInShopperCurrency = '123';
        comp.amountInMerchantCurrency = '12.30';

        List<GERefundWrapperResponse.Components> listComp = new List<GERefundWrapperResponse.Components>();
        listComp.add(comp);
        response.components = listComp;
        response.code = null;
        return response;
    }

    @istest
    public static void jsonParseMethodTest(){
        String input = '{"currency":"ALL","actionByUser":"epohan","lineItems":[{"comments":"","id":"64983a88-f24d-4065-9737-2c58e702fac5","reasonCode":"RT","refundBasisType":"Amount","refundBasisValue":500,"refundCondition":"","sku":"26671684"}],"orderId":"G000072600","orderType":"VSD-GLOBALE"}';
        GERefundWrapperRequest.jsonParse(input);

        String res = '{"totalAmountInShopperCurrency":"500","totalAmountInMerchantCurrency":"5.13","success":true,"refundId":"88808","messageID":null,"message":null,"httpStatusCode":"200","error":null,"customMessage":null,"components":[{"type":"Products","amountInShopperCurrency":"500","amountInMerchantCurrency":"5.13"}],"code":null}';
        GERefundWrapperResponse.jsonParse(res);

        String cancelpayload = '{"Process":"OrderLineCancel","OrderLine":[{"ReasonId":"Customer Request","Quantity":"1","OrderLineId":"d25e4baf-10fa-409e-9232-3b077b9d6f83","AssociateId":"ssaha"}],"OrderId":"G000003967"}';
        INTLOrderCancellation.parse(cancelpayload);


        
    }
	@istest
    public static void getShoppingCurrencyTest(){
        GEServiceCallOuts.getShoppingCurrency('SEK');
        
    }
	@istest
    public static void getCountrySettingTest(){
        GEServiceCallOuts.getCountrySetting();
        
    }
    @istest
    public static void getClaimPicklistDependencyTest(){
        GEServiceCallOuts.getClaimPicklistDependency();
        
    }
    

}