/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Home Try On Services callout class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sharath Vadla  <svadla@victoria.com>
* @version        1.0
* @created        07/05/2023
* ──────────────────────────────────────────────────────────────────────────────────────────────────

*/
public with sharing class VS_HomeTryOnServicesCallout {
  private static String accessToken;
  public final static String POST_METHOD = 'POST';
  public final static String GET_METHOD = 'GET';
  public final static String ACCESS_TOKEN = 'access_token';
  public final static String TOKEN_TYPE = 'Bearer';
  public final static String AUTH_HEADER_KEY = 'Authorization';
  public final static String AUTH_SECRET_KEY = 'client_secret=';
  public final static String AUTH_ID_KEY = '&client_id=';
  public final static String GRANT_KEY = '&grant_type=';
  public final static String DASHBOARD_BY_EMAIL = 'Dashboard_By_Email';
  public final static String EXTEND_KEEP_RETURN = 'Extend_Keep_Return';
  public final static String MARK_BOX_AS_DELIVERED = 'Mark_Box_As_Delivered';
  public final static String PAUSE_SUBSCRIPTION = 'Pause_Subscription';
  public final static String RESUME_SUBSRIPTION = 'Resume_Subscription';
  public final static String SKIP_BOX = 'Skip_Box';
  public final static String UNSUBSCRIBE = 'Unsubscribe';
  public final static String UPDATE_BOX_FREQUENCY = 'Update_Box_Frequency';
  public final static String BOX_DETAILS_BY_EMAIL = 'Box_Details_By_Email';
  public final static String BOX_HISTORY_BY_EMAIL = 'Box_History_By_Email';
  public static String environment;
  // Token generation method
  private static String authenticateHomeTryOn() {
    try {
      environment = runningInASandbox();
      Home_Try_On_Authentication__c authSettings = Home_Try_On_Authentication__c.getValues(
        environment
      );

      HttpRequest request = new HttpRequest();
      String endpoint =
        authSettings.Base_Url__c +
        AUTH_SECRET_KEY +
        authSettings.Client_Secret__c +
        AUTH_ID_KEY +
        authSettings.Client_Id__c +
        GRANT_KEY +
        authSettings.Grant_Type__c;
      request.setEndpoint(endpoint);
      request.setMethod(POST_METHOD);
      request.setTimeout(Integer.valueOf(authSettings.Time_Out__c));
      HttpResponse response = new Http().send(request);
      System.debug(response);

      if (response.getStatusCode() == 200) {
        Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        accessToken = (String) authResponse.get(ACCESS_TOKEN);
      } else {
        accessToken = '';
        if (!Test.isRunningTest()) {
          Logger.error(
            'Error while authenticating Experience service' + response.getBody()
          );
          Logger.saveLog();
        }
      }
      return accessToken;
    } catch (Exception ex) {
      Logger.error(
        'Exception while authenticating Experience services' + ex.getMessage()
      );
      Logger.saveLog();
    }
    return '';
  }
  //HTTP utility method for all api service calls
  public static HomeTryOnServiceResponseWrapper utilHomeTryOnServiceCall(
    String customerEmail,
    String serviceName,
    String methodType,
    String requestBody
  ) {
    try {
      environment = runningInASandbox();
      Home_Try_On_Authentication__c authSettings = Home_Try_On_Authentication__c.getValues(
        environment
      );
      Home_Try_On_Setting__mdt hto_mdt = Home_Try_On_Setting__mdt.getInstance(
        serviceName
      );
      String endPoint = hto_mdt.Base_Url__c + customerEmail;
      HttpRequest request = new HttpRequest();
      request.setEndpoint(endPoint);
      if (methodType == POST_METHOD) {
        request.setMethod(methodType);
        request.setBody(requestBody);
      } else {
        request.setMethod(methodType);
      }
      request.setTimeout(Integer.valueOf(authSettings.Time_Out__c));
      request.setHeader(
        AUTH_HEADER_KEY,
        TOKEN_TYPE + ' ' + authenticateHomeTryOn()
      );

      HttpResponse response = new Http().send(request);
      HomeTryOnServiceResponseWrapper respInstance = new HomeTryOnServiceResponseWrapper();

      if (response.getStatusCode() == 200) {
        respInstance.statusCode = response.getStatusCode();
        Object parsedResponse = JSON.deserializeUntyped(response.getBody());
        if (parsedResponse instanceof Map<String, Object>) {
          respInstance.response = (Map<String, Object>) parsedResponse;
        } else if (parsedResponse instanceof List<Object>) {
          respInstance.listResponse = (List<Object>) parsedResponse;
        }
        system.debug('Response' + respInstance);
        return respInstance;
      } else if (response.getStatusCode() == 204) {
        respInstance.statusCode = response.getStatusCode();
        respInstance.response = (Map<String, Object>) JSON.deserializeUntyped(
          '{}'
        );
        return respInstance;
      } else {
        respInstance.statusCode = response.getStatusCode();
        Logger.error('Home Try on Service callout error' + response.getBody());
        Logger.saveLog();
        respInstance.response = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        system.debug(serviceName + '--' + respInstance);
        return respInstance;
      }
    } catch (Exception ex) {
      Logger.error(
        'Exception while calling Home Try on service' +
        String.valueOf(ex.getMessage())
      );
      Logger.saveLog();
      system.debug(
        'Exception while calling Home Try on service' + ex.getMessage()
      );
      throw new AuraHandledException('Exception occured in' + ex.getMessage());
    }
  }
  // Get Dashboard_By_Email service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper getHTODashBoardDetails(
    String customerEmailId
  ) {
    return utilHomeTryOnServiceCall(
      customerEmailId,
      DASHBOARD_BY_EMAIL,
      GET_METHOD,
      ''
    );
  }
  //Extend Keep Return Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper extendKeepReturnBox(
    String subscriber_email,
    String box_id
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeStringField('boxId', box_id);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      EXTEND_KEEP_RETURN,
      POST_METHOD,
      gen.getAsString()
    );
  }
  //Extend Keep Return Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper markBoxAsDelivered(
    String subscriber_email,
    String box_id
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('boxId', box_id);
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      MARK_BOX_AS_DELIVERED,
      POST_METHOD,
      gen.getAsString()
    );
  }
  //Update Box Frequency Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper udpateBoxFrequency(
    String box_frequency,
    String subscriber_email
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('boxFrequency', box_frequency);
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      UPDATE_BOX_FREQUENCY,
      POST_METHOD,
      gen.getAsString()
    );
  }
  //Skip Box Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper skipBox(
    Integer month,
    Integer year,
    String source,
    String subscriber_email
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeNumberField('month', month);
    gen.writeNumberField('year', year);
    gen.writeStringField('source', source);
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      SKIP_BOX,
      POST_METHOD,
      gen.getAsString()
    );
  }
  //Pause Subscription Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper pauseSubscription(
    String pause_frequency,
    String subscriber_email
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('pauseFrequency', pause_frequency);
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      PAUSE_SUBSCRIPTION,
      POST_METHOD,
      gen.getAsString()
    );
  }

  //Unsubscription Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper unSubscription(
    String subscriber_email,
    String reason_text,
    String unsubscribe_reason,
    String source
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeStringField('reasonText', reason_text);
    gen.writeStringField('unsubscribeReason', unsubscribe_reason);
    gen.writeStringField('source', source);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      UNSUBSCRIBE,
      POST_METHOD,
      gen.getAsString()
    );
  }
  //Resume Subscription Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper resumeSubscrition(
    String subscriber_email
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      RESUME_SUBSRIPTION,
      POST_METHOD,
      gen.getAsString()
    );
  }
  //Box History Service call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper boxHistoryByEmail(
    String customerEmailId
  ) {
    return utilHomeTryOnServiceCall(
      customerEmailId,
      BOX_HISTORY_BY_EMAIL,
      GET_METHOD,
      ''
    );
  }
  //Box Details Service Call
  @AuraEnabled
  public static HomeTryOnServiceResponseWrapper boxDetailsByEmail(
    String subscriber_email,
    String box_order_id
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('boxOrderNumber', box_order_id);
    gen.writeStringField('subscriberEmail', subscriber_email);
    gen.writeEndObject();
    return utilHomeTryOnServiceCall(
      '',
      BOX_DETAILS_BY_EMAIL,
      POST_METHOD,
      gen.getAsString()
    );
  }
  public static string runningInASandbox() {
    string environment;
    if ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox) {
      environment = 'Sandbox';
    } else {
      environment = 'Production';
    }
    return environment;
  }
  @AuraEnabled(cacheable=true)
  public static List<HTO_Box_Status_Setting__mdt> getBoxStatusSettings() {
    try {
      return HTO_Box_Status_Setting__mdt.getAll().values();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  public static HomeTryOnServiceResponseWrapper getOrderhistoryByCustomerId(String customerid){
    HomeTryOnServiceResponseWrapper htoresponsewrapper = new HomeTryOnServiceResponseWrapper();
    
    htoresponsewrapper.successData = new PHISTorderTransactionWrapper.ResponseTransactions();

    GetRequest getReq = new GetRequest();
    PostRequest postReq = new PostRequest();
    RestResponse response = new RestResponse();
    PHISTStoreTransactionService phstService = new PHISTStoreTransactionService();

    String integrationMDTName = 'PHIST_Search_By_Customer_Id';
    LBrands_API_Integration_Setting__mdt lbAPIMDT = phstService.lbAPIIntegSettingsMap.get(integrationMDTName);

    if (lbAPIMDT.Active__c){
      String endpoint =lbAPIMDT.Endpoint__c + '?id='+customerid+'&sortedby=createdtimestamp&lastMonthsToSearch=12&htoOrders=true';
        getReq.setRelativeEndpoint(endpoint);
        response = phstService.doGet(getReq);
        if (response.getStatusCode() == 200){
          htoresponsewrapper.successData= (PHISTorderTransactionWrapper.ResponseTransactions)JSON.deserialize(String.valueOf(response.getData()), PHISTorderTransactionWrapper.ResponseTransactions.class);
        } else{
            Logger.error('Error response from Phist :: '+response.getData());
            Logger.saveLog();
        }
        htoresponsewrapper.statusCode=response.getStatusCode() ;

    }
    return htoresponsewrapper;
}

    
  public class HomeTryOnServiceResponseWrapper {
    @AuraEnabled
    public Map<String, Object> response;
    @AuraEnabled
    public List<Object> listResponse;
    @AuraEnabled
    public Integer statusCode;
    @AuraEnabled
    public PHISTorderTransactionWrapper.ResponseTransactions successData;
  }
}