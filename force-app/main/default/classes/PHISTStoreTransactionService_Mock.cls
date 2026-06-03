global class PHISTStoreTransactionService_Mock implements HttpCalloutMock {
    private Integer statusCode=200;
    public PHISTStoreTransactionService_Mock(Integer statusCode) {
        this.statusCode = statusCode;
    }
    public PHISTStoreTransactionService_Mock() {
        this.statusCode=200;
    }

    global HTTPResponse respond( HTTPRequest request ) {
        HttpResponse res = new HttpResponse();
        if( request.getEndpoint() == 'searchByCustomerStoreTransaction' && 
            request.getBody().contains( 'customerId' ) && 
            request.getBody().contains( 'TestCIDException' )
        ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByCustomerStoreTransaction' && request.getBody().contains( 'customerId' ) ){
            res.setBody( '{ "transactions" : [{"OMS":"POS", "OrderId":"50133001015502112021"}]}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'searchByCustomerStoreTransaction' && request.getBody().contains( 'Invalid' ) ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByCustomerStoreTransaction' && request.getBody().contains( 'Valid' ) ){
            res.setBody( '{ "transactions" : [{"OMS":"POS", "OrderId":"50133001015502112021"}]}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'searchByStoreTransactionIdExceptionId' ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByStoreTransactionIdstoreTransactionTestId' ){
            res.setBody( '{"OMS":"POS", "OrderId":"50133001015502112021"}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'searchByStoreOrder' && request.getBody().contains( 'IncorrectAmount' ) ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByStoreOrder' && request.getBody().contains( 'CorrectAmount' ) ){
            res.setBody( '{ "transactions" : [{"OMS":"POS", "OrderId":"50133001015502112021"}]}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'searchByStoreOrder' && request.getBody().contains( 'Cash' ) ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByStoreOrder' && request.getBody().contains( 'Credit' ) ){
            res.setBody( '{ "transactions" : [{"OMS":"POS", "OrderId":"50133001015502112021"}]}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'searchByEmail' && request.getBody().contains( 'exceptionEmail' ) ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 404 );
        } else if( request.getEndpoint() == 'searchByEmail' ){
            res.setBody( '{"OMS":"POS", "OrderId":"50133001015502112021"}' );
            res.setStatusCode( statusCode );
        } else if( request.getEndpoint() == 'searchByOrderNumberExceptionNumber' ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByOrderNumberorderTestNumber' ){
            res.setBody( '{"OMS":"POS", "OrderId":"50133001015502112021"}' );
            res.setStatusCode( statusCode );
        } else if( request.getEndpoint().contains( 'purchasehistory' ) && request.getEndpoint().contains( '12345678901234567999' ) ){
            res.setBody( '{"OMS":"POS", "OrderId":"12345678901234567999","CreatedTimestamp":"08-16-2021T14:46:53","Extended":{"DeviceId":"Device","OriginStore":"Store"}}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint().contains( 'purchasehistory' ) && request.getEndpoint().contains( 'BADTEST' ) ){
            res.setBody( '{"OMS":"POS", "OrderId":"BADTEST"}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint().contains( 'purchasehistory' ) && request.getEndpoint().contains( 'BADDIGITAL' ) ){
            res.setBody( '{}' );
            res.setStatusCode( 400 );
        } else if( request.getEndpoint().contains( 'purchasehistory' ) && request.getEndpoint().contains( 'ORDERTEST2' ) ){
            res.setBody( '{"OMS":"POS", "OrderType": {"OrderTypeId":"Order_Type_Id"},"OrderId":"ORDERTEST2","CreatedTimestamp":"2021-08-16T14:46:53Z","Extended":{"DeviceId":"Device","OriginStore":"Store"}}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'searchByCustomerDigitalOrder' && request.getBody().contains( 'Invalid' ) ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'searchByCustomerDigitalOrder' && request.getBody().contains( 'Valid' ) ){
            res.setBody( '{ "transactions" : [{"OMS":"POS", "OrderId":"50133001015502112021"}]}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint().contains( 'authenticationEndpoint' ) ){
            Map<String,Object> resposeData = new Map<String,Object>();
            resposeData.put( 'access_token', 'access-token' );
            resposeData.put( 'expires_in', 7200 );
            resposeData.put( 'token_type', 'Bearer' );
            res.setBody( JSON.serialize(resposeData) );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint().contains( 'authenticationCancelOrderEndpoint' ) ){
            Map<String,Object> resposeData = new Map<String,Object>();
            resposeData.put( 'access_token', 'access-token' );
            resposeData.put( 'expires_in', 7200 );
            resposeData.put( 'token_type', 'Bearer' );
            res.setBody( JSON.serialize(resposeData) );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint().contains( 'checkStatusId' ) ){
            res.setBody( '{"success":true,"header":{"totalCount":"1","page":0,"size":100},"data":[{"Messages":null,"MaxFulfillmentStatusId":"3000","CreatedTimestamp":"2021-05-27T19:55:52.607","OrderId":"W008083628","MinFulfillmentStatusId":"3000","DoNotReleaseBefore":"2021-05-27T20:25:53.178"}],"messageKey":null,"message":null,"errors":[],"exceptions":[],"messages":{"Message":[],"Size":0},"rootCause":null,"cloudComponent":"com-manh-cp-order:order,docker,omni,all,cloud,kubernetes,all-kubernetes,lmit,s,lmits,lmitosf11o:8080","cloudComponentHostName":"all-com-manh-cp-order-56dcbf666-pz2rr","requestUri":null,"statusCode":"OK"}' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint().contains( 'authenticationException' ) ){
            res.setBody( '{"Error" : "Error"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'doGetSuccess' ){
            res.setBody( 'SuccessRequest' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'doGetFailure' ){
            res.setBody( '{ "message" : "Transaction Not Found" }' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'doPostSuccess' ){
            res.setBody( 'SuccessRequest' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'doPostFailure' ){
            res.setBody( '{ "message" : "Transaction Not Found" }' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'doPostFailureAuth' && request.getHeader( 'Authorization' ) == null ){
            res.setBody( 'Auth Failed' );
            res.setStatusCode( 401 );
        } else if( request.getEndpoint() == 'doPostFailureAuth' ){
            res.setBody( 'SuccessRequest' );
            res.setStatusCode( 200 );
        } else if( request.getEndpoint() == 'cancelOrder' && request.getBody().contains( 'ExceptionOrder' ) ){
            res.setBody( '{"Failure" : "Failure"}' );
            res.setStatusCode( 403 );
        } else if( request.getEndpoint() == 'cancelOrder' && statusCode!=200){
            res.setBody( '{"Failure" : "Failure"}' );
            res.setStatusCode( statusCode );
        }else if( request.getEndpoint() == 'cancelOrder' ){
            res.setBody( 'SuccessRequest' );
            res.setStatusCode( 200 );
        }
        else if( request.getEndpoint() == 'MaxFulfillmentStatusId' ){
            res.setBody( '{"success":true,"header":{"totalCount":"1","page":0,"size":100},"data":[{"Messages":null,"MaxFulfillmentStatusId":"2000","CreatedTimestamp":"2021-07-19T13:34:13.41","OrderId":"W008085973","MinFulfillmentStatusId":"3000","DoNotReleaseBefore":"2021-07-19T14:04:18.712"}],"messageKey":null,"message":null}' );
            res.setStatusCode( 200 );
        }
        return res;
    }
}