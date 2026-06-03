global class AOOrderCancellationControllerMock implements HttpCalloutMock {
    global HTTPResponse respond( HTTPRequest request ) {
        HttpResponse res = new HttpResponse();
        if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'AuthFail' ) && !request.getHeader('Authorization').contains('valid_token') ) {
            res.setBody( '{ "Authentication": "Failed" }' );
            res.setStatusCode( 401 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'Order200' ) ) {
            res.setBody( '{ "success": true, "header": null, "data": null, "messageKey": null, "message": null, "errors": [], "exceptions": [], "messages": { "Message": [], "Size": 0 }, "rootCause": null, "cloudComponent": "com-manh-cp-order:order,docker,omni,rest,cloud,kubernetes,rest-kubernetes,lmit,s,lmits,lmitosf11o:8080", "cloudComponentHostName": "com-manh-cp-order-868fc96c9f-skmks", "requestUri": null, "statusCode": "OK" }' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'Order400' ) ) {
            res.setBody( '{ "message": "Error" }' );
            res.setStatusCode( 400 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'Order500' ) ) {
            res.setBody( '{ "message": "Error" }' );
            res.setStatusCode( 500 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'Order404' ) ) {
            res.setBody( '{ "message": "Error" }' );
            res.setStatusCode( 404 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'Order503' ) ) {
            res.setBody( '{ "message": "Error" }' );
            res.setStatusCode( 503 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'Order510' ) ) {
            res.setBody( '{ "success": false, "header": null, "data": null, "messageKey": "error.400", "message": "error.400", "errors": [], "exceptions": [ { "messageData": {}, "resource": "Throwable", "messageKey": "Throwable", "message": "Throwable with cause of type com.manh.cp.om.lib.omni.exception.OmniRuntimeException was caught and handled by CustomErrorController (see logs for the trace)", "stackTrace": "java.lang.Throwable: Throwable with cause of type com.manh.cp.om.lib.omni.exception.OmniRuntimeException was caught and handled by CustomErrorController (see logs for the trace)\n" } ], "messages": { "Message": [ { "Type": "ERROR", "Code": "ord::10007", "Description": "Order is not allowed to perform the following modification for Status: Released, Mod Type: Order::Cancel, Order Id: W008087551.", "ShortDescription": null, "ErrorCode": "10007", "ErrorField": null, "ResourceId": null, "QuickInfo": false, "BusinessKeys": null } ], "Size": 1 }, "rootCause": "java.lang.Throwable: Throwable with cause of type com.manh.cp.om.lib.omni.exception.OmniRuntimeException was caught and handled by CustomErrorController (see logs for the trace)", "cloudComponent": "com-manh-cp-order:order,docker,omni,rest,cloud,kubernetes,rest-kubernetes,lmit,s,lmits,lmitosf11o:8080", "cloudComponentHostName": "com-manh-cp-order-868fc96c9f-8ln59", "requestUri": "error", "statusCode": "BAD_REQUEST" }' );
            res.setStatusCode( 510 );
        } else if( request.getEndpoint() == 'Cancel_Order' && request.getBody().contains( 'ExeptionOrder' ) ) {
            res.setBody( '{ "success": 123, "header": null, "data": null, "messageKey": "error.400", "message": "error.400", "errors": [], "exceptions": [ { "messageData": {}, "resource": "Throwable", "messageKey": "Throwable", "message": "Throwable with cause of type com.manh.cp.om.lib.omni.exception.OmniRuntimeException was caught and handled by CustomErrorController (see logs for the trace)", "stackTrace": "java.lang.Throwable: Throwable with cause of type com.manh.cp.om.lib.omni.exception.OmniRuntimeException was caught and handled by CustomErrorController (see logs for the trace)\n" } ], "messages": { "Message": [ { "Type": "ERROR", "Code": "ord::10007", "Description": "Order is not allowed to perform the following modification for Status: Released, Mod Type: Order::Cancel, Order Id: W008087551.", "ShortDescription": null, "ErrorCode": "10007", "ErrorField": null, "ResourceId": null, "QuickInfo": false, "BusinessKeys": null } ], "Size": 1 }, "rootCause": "java.lang.Throwable: Throwable with cause of type com.manh.cp.om.lib.omni.exception.OmniRuntimeException was caught and handled by CustomErrorController (see logs for the trace)", "cloudComponent": "com-manh-cp-order:order,docker,omni,rest,cloud,kubernetes,rest-kubernetes,lmit,s,lmits,lmitosf11o:8080", "cloudComponentHostName": "com-manh-cp-order-868fc96c9f-8ln59", "requestUri": "error", "statusCode": "BAD_REQUEST" }' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'Auth_Access_Token' ) {
            Map<String,Object> resposeData = new Map<String,Object>();
            resposeData.put( 'access_token', 'valid_token' );
            res.setBody( JSON.serialize(resposeData) );
            res.setStatusCode( 200 );
        }
        return res;
    }
}