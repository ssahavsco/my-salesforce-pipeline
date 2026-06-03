/*****************************************************************************************************************
Class Name     :  NF_OrderHistoryAPI
Purpose        :  Apex class for all the order api endpoints.
History:
-------
VERSION  AUTHOR                   DATE                	DETAIL                      	TICKET REFERENCE/ NO.
1.       mcasella              	09/24/2020            Original Version             			   	-
2.       Manishi             	09/03/2021            Modifying order API endpoints           DP-39915
3.       Sharath Vadla          01/02/2023            Adding Nebula logger methods
4.       Sumit Saha             03/30/2023            Predictive Delivery Data Range         DP-64109, DP-61438    
5.       Himanshu               07/12/2023            Added the Nebula logger statements     DP-67748
6.       Himanshu               10/09/2024            Commented line no 230 & 231             DP-89759 
7.       Himanshu               10/16/2024            Added code to replace input resp        CCS-580  
******************************************************************************************************************/
public class NF_OrderHistoryAPI {
  public static LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
  public static Integer tout = (Integer) lbAPI.Timeout__c == null
    ? 5000
    : lbAPI.Timeout__c.intValue();
  public static String chatKey;
  private static List<ResponseLog> responseLogs = new List<ResponseLog>();

  private static HttpRequest makeSearchRequest(String email, String randomId) {
    HttpRequest request = new HttpRequest();
    String endpoint = lbAPI.Order_Endpoint__c;
    /* DP-39915 orderhistory endpoint modified */
    endpoint += '/orderhistory/v9/search';
    request.setEndpoint(endpoint);
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + lbAPI.access_token__c);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('X-Request-Id', randomId);
    request.setBody('{"email": "' + email + '","limit": 75}');
    request.setTimeout(tout);
    return request;
  }

  private static HttpRequest makeSearchRequest(
    String email,
    String phone,
    String zipCode,
    String randomId
  ) {
    HttpRequest request = makeSearchRequest(email, randomId);
    request.setBody(
      '{"email": "' +
        email +
        '","phone": "' +
        phone +
        '","zipCode": "' +
        zipCode +
        '","limit": 75}'
    );
    return request;
  }

  private static HttpRequest makeSearchRequest(
    String email,
    String phone,
    String zipCode,
    Integer noOfOrders,
    String randomId
  ) {
    HttpRequest request = makeSearchRequest(email, randomId);
    request.setBody(
      '{"email": "' +
        email +
        '","phone": "' +
        phone +
        '","zipCode": "' +
        zipCode +
        '","limit": ' +
        noOfOrders +
        '}'
    );
    return request;
  }

  public static String searchOrder(String email) {
    String randomId = genRand(32);
    try {
      HttpRequest request = makeSearchRequest(email, randomId);
      System.debug('@@@@ request ==>> ' + request.getEndpoint());
      HttpResponse response = new Http().send(request);
      System.debug('@@@@ response.getBody() ==>> ' + response.getBody());
      //refresh token and retry in case of expired token
      if (response.getStatusCode() == 401) {
        getAuthToken();
        request.setHeader('Authorization', 'Bearer ' + lbAPI.access_token__c);
        response = new Http().send(request);
        update lbAPI;
      }
      return getResponseDetails(request, response, true, randomId);
    } catch (Exception e) {
      Logger.error(parseException(e, randomId));
      Logger.saveLog();
      return parseException(e, randomId);
    }
  }

  public static NF_OrderServiceN.APIResponse searchOrderX(String email) {
    String randomId = genRand(32);
    try {
      HttpRequest request = makeSearchRequest(email, randomId);
      System.debug('@@@@ request ==>> ' + request.getEndpoint());
      HttpResponse response = new Http().send(request);
      //   System.debug('@@@@ response.getBody() ==>> ' + response.getBody());
      //refresh token and retry in case of expired token
      if (response.getStatusCode() == 401) {
        getAuthToken();
        request.setHeader('Authorization', 'Bearer ' + lbAPI.access_token__c);
        response = new Http().send(request);
        update lbAPI;
      }
      return (NF_OrderServiceN.APIResponse) JSON.deserialize(
        getResponseDetails(request, response, true, randomId, false),
        NF_OrderServiceN.APIResponse.class
      );
    } catch (Exception e) {
      Logger.error(parseException(e, randomId));
      Logger.saveLog();
      return (NF_OrderServiceN.APIResponse) JSON.deserialize(
        parseException(e, randomId),
        NF_OrderServiceN.APIResponse.class
      );
    }
  }

  public static String searchOrder(String email, String phone, String zipCode) {
    String randomId = genRand(32);
    try {
      HttpRequest request = makeSearchRequest(email, phone, zipCode, randomId);
      HttpResponse response = new Http().send(request);
      //refresh token and retry in case of expired token
      if (response.getStatusCode() == 401) {
        getAuthToken();
        request.setHeader('Authorization', 'Bearer ' + lbAPI.access_token__c);
        response = new Http().send(request);
        update lbAPI;
      }
      return getResponseDetails(request, response, true, randomId);
    } catch (Exception e) {
      Logger.error(parseException(e, randomId));
      Logger.saveLog();
      return parseException(e, randomId);
    }
  }

  public static String searchOrderWithLimit(
    String email,
    String phone,
    String zipCode,
    Integer noOfOrders
  ) {
    String randomId = genRand(32);
    try {
      HttpRequest request = makeSearchRequest(
        email,
        phone,
        zipCode,
        noOfOrders,
        randomId
      );
      HttpResponse response = new Http().send(request);
      //refresh token and retry in case of expired token
      if (response.getStatusCode() == 401) {
        getAuthToken();
        request.setHeader('Authorization', 'Bearer ' + lbAPI.access_token__c);
        response = new Http().send(request);
        update lbAPI;
      }
      return getResponseDetails(request, response, true, randomId);
    } catch (Exception e) {
      Logger.error(parseException(e, randomId));
      Logger.saveLog();
      return parseException(e, randomId);
    }
  }

  public static NF_OrderServiceN.APIResponse orders(
    String encrypted_auth_token,
    Integer noOfOrders
  ) {
    String randomId = genRand(32);
    try {
      String auth_token;
      if (lbAPI.AES_Key__c != null) {
        String secretKey = lbAPI.AES_Key__c;
        Blob key = Blob.valueOf(secretKey);
        Blob IV = EncodingUtil.convertFromHex(
          '00000000000000000000000000000000'
        );
        Blob data = EncodingUtil.base64Decode(encrypted_auth_token);
        Blob decryptedBlob = Crypto.decrypt('AES256', key, IV, data);
        auth_token = decryptedBlob.toString();
      } else {
        throw new APIException('lbAPI.AES_Key__c is blank');
      }
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      /* DP-39915 orderhistory endpoint modified for authenticated customers */
      request.setEndpoint(
        lbAPI.Order_Endpoint__c +
          '/orderhistory/v9/orders?limit=' +
          noOfOrders +
          '&activeCountry=US'
      );
      request.setMethod('GET');
      //request.setHeader('Content-Type', 'application/json');
      request.setHeader('Connection', 'keep-alive');
      if (lbAPI.Origin__c != null) {
        request.setHeader('Origin', lbAPI.Origin__c);
      }
      request.setHeader('Cookie', 'auth_token=' + auth_token);
      request.setHeader('X-Request-Id', randomId);
      request.setTimeout(tout);
      System.debug('@@@@ request ==>> ' + request.getEndpoint());
      HttpResponse response = http.send(request);
      //   System.debug('@@@@ response.getBody() ==>> ' + response.getBody());
      //the fifth param "false" means no immediate log will be created for this call just data will be added to the global list
      return (NF_OrderServiceN.APIResponse) JSON.deserialize(
        getResponseDetails(request, response, true, randomId, false),
        NF_OrderServiceN.APIResponse.class
      );
    } catch (Exception e) {
      Logger.error(parseException(e, randomId));
      Logger.saveLog();
      return (NF_OrderServiceN.APIResponse) JSON.deserialize(
        parseException(e, randomId),
        NF_OrderServiceN.APIResponse.class
      );
    }
  }

  public static String orderByIdAndEmail(String orderId, String email) {
    String randomId = genRand(32);
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    /* DP-39915 order detail endpoint modified for unauthenticated customers */
    // request.setEndpoint(lbAPI.Order_Endpoint__c + '/orderdetails/v4/orderByIdAndEmail');
    request.setEndpoint(lbAPI.Order_Endpoint__c + lbAPI.orderdetails__c); // ==> /orderdetails/v4/orders
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('X-Request-Id', randomId);
    request.setBody(
      '{"email": "' +
        email +
        '","orderId": "' +
        orderId +
        '","activeCountry" : "US"}'
    );
    request.setTimeout(tout);
    try {
      HttpResponse response = http.send(request);
      return getResponseDetails(request, response, false, randomId);
    } catch (Exception e) {
      Logger.error(parseException(e, randomId));
      Logger.saveLog();
      return parseException(e, randomId);
    }
  }

  public static NF_OrderServiceN.APIResponse searchOrder(
    String email,
    String phone,
    String zipCode,
    Boolean log
  ) {
    String resp = NF_OrderHistoryAPI.searchOrder(email, phone, zipCode);
    NF_OrderServiceN.APIResponse apiResp = (NF_OrderServiceN.APIResponse) JSON.deserialize(
      resp,
      NF_OrderServiceN.APIResponse.class
    );
    if (log) {
      createResponse(
        email + '-' + phone + '-' + zipCode,
        apiResp.rawBody,
        JSON.serialize(apiResp.orders)
      );
    }
    return apiResp;
  }

  public static NF_OrderServiceN.APIResponse searchOrder(
    String email,
    String phone,
    String zipCode,
    Boolean log,
    Integer noOfOrders
  ) {
    String resp = NF_OrderHistoryAPI.searchOrderWithLimit(
      email,
      phone,
      zipCode,
      noOfOrders
    );
    NF_OrderServiceN.APIResponse apiResp = (NF_OrderServiceN.APIResponse) JSON.deserialize(
      resp,
      NF_OrderServiceN.APIResponse.class
    );
    if (log) {
      createResponse(
        email + '-' + phone + '-' + zipCode,
        apiResp.rawBody,
        JSON.serialize(apiResp.orders)
      );
    }
    return apiResp;
  }

  public static NF_OrderServiceN.APIResponse searchOrder(
    String email,
    Boolean log
  ) {
    String resp = NF_OrderHistoryAPI.searchOrder(email);
    NF_OrderServiceN.APIResponse apiResp = (NF_OrderServiceN.APIResponse) JSON.deserialize(
      resp,
      NF_OrderServiceN.APIResponse.class
    );
    if (log) {
      createResponse(email, apiResp.rawBody, JSON.serialize(apiResp.orders));
    }
    return apiResp;
  }
  public static NF_OrderServiceN.APIResponse orderByIdAndEmail(
    String orderId,
    String email,
    Boolean log
  ) {
    String resp = NF_OrderHistoryAPI.orderByIdAndEmail(orderId, email);
    NF_OrderServiceN.APIResponse apiResp = (NF_OrderServiceN.APIResponse) JSON.deserialize(
      resp,
      NF_OrderServiceN.APIResponse.class
    );
    logger.info('API Resp -> ' + apiResp);
    logger.saveLog();
    if (log) {
      createResponse(
        email + '-' + orderId,
        apiResp.rawBody,
        JSON.serialize(apiResp.order)
      );
    }
    return apiResp;
  }

  @future
  private static void createResponse(
    String parameters,
    String raw,
    String deserialized
  ) {
    Integer maxSize = 131071;
    if (String.isNotBlank(raw) && raw.length() > maxSize) {
      raw = raw.substring(0, maxSize);
    }
    if (deserialized.length() > maxSize) {
      deserialized = deserialized.substring(0, maxSize);
    }
    Database.upsert(
      new Response__c(
        Parameters__c = parameters,
        Raw__c = raw,
        Deserialized__c = deserialized
      ),
      Schema.Response__c.Parameters__c
    );
  }

  public static String getResponseDetails(
    HttpRequest request,
    HttpResponse response,
    Boolean isBulk,
    String randomId
  ) {
    return getResponseDetails(request, response, isBulk, randomId, true);
  }

  public static String getResponseDetails(
    HttpRequest request,
    HttpResponse response,
    Boolean isBulk,
    String randomId,
    Boolean createLogImmediately
  ) {
    Integer statusCode = response.getStatusCode();
    String status = response.getStatus();
    String resp = response.getBody();
    // System.debug(resp);
    //Commented as it seems we don't receive these attributes in api response
    // and causing limit exception - Himanshu
    //resp = resp.replaceAll('"type":','"paymenttype":');
    //resp = resp.replaceAll('"number":', '"itemNumber":');
    /* Added by Himanshu - CCS-580 */
    resp = resp.contains('Retail Delivery Fee')
      ? resp.replaceAll('"Retail Delivery Fee":', '"retailDeliveryFee":')
      : resp;
    resp = resp.contains('PIF & RSF')
      ? resp.replaceAll('"PIF & RSF":', '"pifRsf":')
      : resp;
    resp = resp.contains('FACILITY CHARGE')
      ? resp.replaceAll('"FACILITY CHARGE":', '"facilityCharge":')
      : resp;
    NF_OrderServiceN.APIResponse apiResp = new NF_OrderServiceN.APIResponse();

    //Added for Callout Test Page
    if (request != null) {
      apiResp.requestURL = request.getEndpoint();
      apiResp.requestBody = request.getBody();
    }

    if (statusCode != 200) {
      try {
        NF_OrderServiceN.FailedResponse failedResp = (NF_OrderServiceN.FailedResponse) JSON.deserialize(
          resp,
          NF_OrderServiceN.FailedResponse.class
        );
        apiResp.status = 'Failed';
        apiResp.responseError = failedResp.message;
        Logger.error(failedResp.message);
        Logger.saveLog();
      } catch (Exception e) {
        //resp not json
        apiResp.status = 'Failed';
        apiResp.responseError = resp;
        Logger.error(e.getMessage(), resp);
        Logger.saveLog();
      }
    } else {
      apiResp.status = 'Success';
    }
    apiResp.statusCode = statusCode;

    if (isBulk) {
      apiResp.orders = (List<NF_OrderServiceN.ListOfOrderResponse>) JSON.deserialize(
        resp,
        List<NF_OrderServiceN.ListOfOrderResponse>.class
      );
    } else {
      apiResp.order = (NF_OrderServiceN.OrderResponse) JSON.deserialize(
        resp,
        NF_OrderServiceN.OrderResponse.class
      );
    }
    apiResp.rawBody = resp;

    String serializedApiResp = JSON.serialize(apiResp);

    if (
      lbAPI != null &&
      (lbAPI.All_Logging__c == true ||
      (lbAPI.Error_Logging__c == true &&
      statusCode != 200))
    ) {
      responseLogs.add(
        new ResponseLog(randomId, serializedApiResp, serializedApiResp, chatKey)
      );
      if (createLogImmediately && !responseLogs.isEmpty()) {
        createResponseLog(JSON.serialize(responseLogs));
        responseLogs.clear();
      }
    }

    return JSON.serialize(apiResp);
  }

  public static String parseException(Exception e, String randomId) {
    NF_OrderServiceN.APIResponse apiResp = new NF_OrderServiceN.APIResponse();
    apiResp.status = 'Failed';
    apiResp.statusCode = 0;
    if (e.getMessage() == 'Read timed out') {
      apiResp.responseError = 'API Timeout';
    } else {
      apiResp.responseError = e.getMessage();
    }

    String serializedResp = JSON.serialize(apiResp);
    if (
      lbAPI != null &&
      (lbAPI.Error_Logging__c == true ||
      lbAPI.All_Logging__c == true)
    ) {
      responseLogs.add(
        new ResponseLog(randomId, serializedResp, serializedResp, chatKey)
      );
      if (!responseLogs.isEmpty()) {
        createResponseLog(JSON.serialize(responseLogs));
        responseLogs.clear();
      }
    }
    return serializedResp;
  }

  public static String getAuthToken() {
    String randomId = genRand(32);
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String endpoint = lbAPI.Order_Endpoint__c;
    endpoint += '/apiauthentication/v1/token?';
    endpoint += 'grant_type=client_credentials';
    endpoint += '&client_secret=' + lbAPI.Client_Secret__c;
    endpoint += '&client_id=' + lbAPI.Client_ID__c;
    request.setEndpoint(endpoint);
    request.setMethod('POST');
    request.setHeader('Host', lbAPI.Host__c);
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setHeader('X-Request-Id', randomId);
    HttpResponse response = http.send(request);
    if (response.getStatusCode() == 200) {
      Map<String, Object> r = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      lbAPI.access_token__c = (String) r.get('access_token');
    }
    return response.getBody();
  }
  public virtual class APIException extends Exception {
  }

  private static String genRand(Integer len) {
    Blob blobKey = Crypto.generateAesKey(128);
    String key = EncodingUtil.convertToHex(blobKey);
    String uuid = key.substring(0, len);
    return uuid;
  }

  //Added to log errors and responses
  @future
  private static void createResponseLog(String serializedLog) {
    List<ResponseLog> resLogs = (List<ResponseLog>) (JSON.deserialize(
      serializedLog,
      List<ResponseLog>.class
    ));

    if (resLogs != null && !resLogs.isEmpty()) {
      //Collect ChatKeys
      Set<String> chatKeys = new Set<String>();
      for (ResponseLog rl : resLogs) {
        if (String.isNotBlank(rl.chatKey)) {
          chatKeys.add(rl.chatKey);
        }
      }

      //Fetch bot sessions
      List<ebotdata__Bot_Session__c> botSessions = [
        SELECT Id, ebotdata__Live_Agent_Session_Id__c
        FROM ebotdata__Bot_Session__c
        WHERE ebotdata__Live_Agent_Session_Id__c IN :chatKeys
      ];
      Map<String, Id> chatKeyBySessionIdMap = new Map<String, Id>();

      if (!botSessions.isEmpty()) {
        //Fillup the session map
        for (ebotdata__Bot_Session__c session : botSessions) {
          if (
            String.isNotBlank(
              String.valueOf(session.ebotdata__Live_Agent_Session_Id__c)
            ) &&
            !chatKeyBySessionIdMap.containsKey(
              session.ebotdata__Live_Agent_Session_Id__c
            )
          ) {
            chatKeyBySessionIdMap.put(
              session.ebotdata__Live_Agent_Session_Id__c,
              session.Id
            );
          }
        }
      }

      //Fillup List to of logs insert
      List<Response__c> responeToInsert = new List<Response__c>();
      for (ResponseLog rl : resLogs) {
        Response__c resp = new Response__c();
        resp.X_Request_Id__c = rl.randomId;
        resp.Deserialized__c = rl.serializedResp;
        resp.Raw__c = rl.raw;
        if (
          rl.chatKey != null && chatKeyBySessionIdMap.containsKey(rl.chatKey)
        ) {
          resp.Bot_Session__c = chatKeyBySessionIdMap.get(rl.chatKey);
        }
        responeToInsert.add(resp);
      }

      if (!responeToInsert.isEmpty()) {
        insert responeToInsert;
      }
    }
  }

  public class ResponseLog {
    public String randomId;
    public String serializedResp;
    public String raw;
    public String chatKey;

    public ResponseLog(
      String randomId,
      String serializedResp,
      String raw,
      String chatKey
    ) {
      this.randomId = randomId;
      this.serializedResp = serializedResp;
      this.raw = raw;
      this.chatKey = chatKey;
    }
  }
}