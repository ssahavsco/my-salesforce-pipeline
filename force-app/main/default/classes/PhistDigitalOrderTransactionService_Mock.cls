@isTest
global class PhistDigitalOrderTransactionService_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('GET', req.getMethod());
        
        System.debug('Req' +req.getEndpoint());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String endpoint = req.getEndpoint();
        //res.setBody('{"successData": {"transactions": [{"CreatedTimestamp":"2023-04-21T12:32:47.000+0000", "CarrierCode": "USPS","PromisedDeliveryDate": "2023-04-23T12:32:47.000+0000","orderDate": "04/21/2023","ShippingMethodId": "N","Country": "US"}]},"success": true,"errorMessage": "Error"}');
        if( endpoint.contains('orderNumber1')){
            res.setBody('{"CreatedTimestamp":"2023-04-21T12:32:47.000+0000", "OrderLine":[{"PromisedDeliveryDate": "2023-04-23T12:32:47.000+0000","ShippingMethodId":"N","ShipFromAddress": {"Address":{"State": "BC", "Country": "CA"}},"FulfillmentDetail":[{"CarrierCode": "USPS"}]}],"orderDate": "04/21/2023","ShippingMethodId": "N","Country": "US","State":"OH","success": true,"errorMessage": "Error"}');
            res.setStatusCode(200);
        } else if( endpoint.contains('orderNumber2') ){
            res.setBody('{"CreatedTimestamp":"2023-04-21T12:32:47.000+0000", "OrderLine":[{"PromisedDeliveryDate": "2023-04-23T12:32:47.000+0000","ShippingMethodId":"S","ShipFromAddress": {"Address":{"State": "BC", "Country": "CA"}},"FulfillmentDetail":[{"CarrierCode": "USPS"}]}],"orderDate": "04/21/2023","ShippingMethodId": "N","Country": "US","State":"OH","success": true,"errorMessage": "Error"}');
            res.setStatusCode(200);
        }
        else if( endpoint.contains('orderNumber3') ){
            res.setBody('{"CreatedTimestamp":"2023-04-21T12:32:47.000+0000", "OrderLine":[{"PromisedDeliveryDate": "2023-04-23T12:32:47.000+0000","ShippingMethodId":"G","ShipFromAddress": {"Address":{"State": "BC", "Country": "CA"}},"FulfillmentDetail":[{"CarrierCode": "USPS"}]}],"orderDate": "04/21/2023","ShippingMethodId": "N","Country": "US","State":"OH","success": true,"errorMessage": "Error"}');
            res.setStatusCode(200);
        }
        else if( endpoint.contains('orderNumber4') ){
            res.setBody('{"CreatedTimestamp":"2023-04-21T12:32:47.000+0000", "OrderLine":[{"PromisedDeliveryDate": "2023-04-23T12:32:47.000+0000","ShippingMethodId":"X","ShipFromAddress": {"Address":{"State": "BC", "Country": "CA"}},"FulfillmentDetail":[{"CarrierCode": "USPS"}]}],"orderDate": "04/21/2023","ShippingMethodId": "N","Country": "US","State":"OH","success": true,"errorMessage": "Error"}');
            res.setStatusCode(200);
        }
        else if( endpoint.contains('orderNumber5') ){
            res.setBody('{"CreatedTimestamp":"2023-04-21T12:32:47.000+0000", "OrderLine":[{"PromisedDeliveryDate": "2023-04-23T12:32:47.000+0000","ShippingMethodId":"P","ShipFromAddress": {"Address":{"State": "BC", "Country": "CA"}},"FulfillmentDetail":[{"CarrierCode": "USPS"}]}],"orderDate": "04/21/2023","ShippingMethodId": "N","Country": "US","State":"OH","success": true,"errorMessage": "Error"}');
            res.setStatusCode(200);
        }
        
        return res;
    }
}