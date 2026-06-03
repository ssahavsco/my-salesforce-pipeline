public class VS_AdverseCaseToSAPPLM_APIHandlerMock implements HttpCalloutMock {
  public Boolean isSuccess;
  public String statusCode;
  public String errorCode; //Added to support ERROR/001 and ERROR/002

  public VS_AdverseCaseToSAPPLM_APIHandlerMock(
    Boolean isSuccess,
    String statusCode
  ) {
    this.isSuccess = isSuccess;
    this.statusCode = statusCode;
    this.errorCode = null;
  }

  //Added constructor to support error code scenarios
  public VS_AdverseCaseToSAPPLM_APIHandlerMock(
    Boolean isSuccess,
    String statusCode,
    String errorCode
  ) {
    this.isSuccess = isSuccess;
    this.statusCode = statusCode;
    this.errorCode = errorCode;
  }

  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse resp = new HttpResponse();
    String endpoint = req.getEndpoint();

    if (
      endpoint ==
      'https://nonprod.test.apimanagement.us10.hana.ondemand.com/v1/plm/oAuth/Token'
    ) {
      //Auth Token Response
      resp.setStatusCode(200);
      Map<String, Object> responseData = new Map<String, Object>();
      responseData.put('access_token', '0X2CZVCJNT6ID--T-KDOLQ');
      responseData.put('expires_in', 7200);
      responseData.put('token_type', 'Bearer');
      resp.setBody(JSON.serialize(responseData));
    } else if (
      endpoint ==
      'https://nonprod.test.apimanagement.us10.hana.ondemand.com/advevent/adverseeventSet?$format=json'
    ) {
      //CSRF Token Response
      resp.setStatusCode(200);
      resp.setHeader('x-csrf-token', 'WQTYUDWDASVBNMSSHDS');
      resp.setHeader(
        'set-cookie',
        'SAP_SESSIONID_QR2_320=jJtX2dk1vlciVFQAGErfklmqFfFm5BHvsNYAUFaR58U%3d;' +
          'path=/;' +
          'sap-usercontext=sap-client=320;' +
          'secure;' +
          'HttpOnly'
      );
    } else {
      //SAP Callout Response
      if (isSuccess) {
        // Success - 201
        resp.setStatusCode(201);
      } else if (!isSuccess && statusCode == '400' && errorCode != null) {
        //Fixed - 400 with XML error body for ERROR/001 or ERROR/002
        resp.setStatusCode(400);
        String xmlBody =
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<error xmlns="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">' +
          '<code>' +
          errorCode +
          '</code>' +
          '<message>Record is locked</message>' +
          '</error>';
        resp.setBody(xmlBody);
        resp.setHeader('Content-Type', 'application/xml');
      } else if (!isSuccess && statusCode == '400') {
        //Fixed - 400 with unknown error code
        resp.setStatusCode(400);
        String xmlBody =
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<error xmlns="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">' +
          '<code>ERROR/999</code>' +
          '<message>Unknown error occurred</message>' +
          '</error>';
        resp.setBody(xmlBody);
        resp.setHeader('Content-Type', 'application/xml');
      } else if (!isSuccess && statusCode == '403') {
        //Fixed - Returns 403 now instead of 201
        resp.setStatusCode(403);
        Map<String, Object> responseData = new Map<String, Object>();
        responseData.put('errorMessage', 'Unauthorized access');
        resp.setBody(JSON.serialize(responseData));
      } else {
        //Default failure
        resp.setStatusCode(500);
        resp.setBody('Internal Server Error');
      }
    }

    return resp;
  }
}