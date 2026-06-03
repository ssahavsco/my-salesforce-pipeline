/*****************************************************************************************************@@
Class Name     :  NF_ProcessCCPaymentMockAPI
Purpose        :  Class to test NF_ProcessCCPayment class
History:
-------
VERSION  AUTHOR                   DATE                	DETAIL                      	TICKET REFERENCE/ NO.
1.       zali              	    2/14/2022            Original Version             			   	DP-49936
       
*********************************************************************************************************/
global class NF_ProcessCCPaymentMockAPI implements HttpCalloutMock{ 
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        system.debug(req);
        String endPoint = req.getEndpoint();
        if(endPoint=='https://apitest.victoriassecret.com/controlplaneproxy/v2/order/api/order/order/orderId/W009319980'){
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"data":{"OrgId":"test","OrderToken":"12355860"}}');
            response.setStatus('OK');
            response.setStatusCode(200);
        }
        
        return response;
    }
}