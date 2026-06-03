public class VSCCS_SIQMock implements HttpCalloutMock {
    
    public Boolean isSuccess;
    public String statusCode;
    public VSCCS_SIQMock(Boolean isSucess, String statusCode){
        this.isSuccess = isSucess;
        this.statusCode = statusCode;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        String endPoint = req.getEndpoint();
        if(isSuccess){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            
            Datetime dt1 = Datetime.newInstance(2024, 1, 2, 3, 4, 5);
            Datetime dt2 = Datetime.newInstance(2025, 12, 31, 23, 59, 59);

            Map<String, Object> s1 = new Map<String, Object>{ 'lostClaimEligibleDate' => dt1 };
            Map<String, Object> s2 = new Map<String, Object>{ 'lostClaimEligibleDate' => null };
            Map<String, Object> s3 = new Map<String, Object>{ 'lostClaimEligibleDate' => dt2 };
            List<Object> shipments = new List<Object>{ s1, s2, s3 };
            Map<String, Object> root = new Map<String, Object>{ 'shipments' => shipments };
            String body = JSON.serialize(root);

            res.setBody(body);
            return res;
        } else {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{ "message": "Internal Server Error" }');
            return res;
        }
    }
}