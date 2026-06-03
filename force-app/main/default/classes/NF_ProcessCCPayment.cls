/*****************************************************************************************************@@
Class Name     :  NF_ProcessCCPayment
Purpose        :  Class to make callout to create payment link for chat associates to display to users. Called via flow
History:
-------
VERSION  AUTHOR                   DATE                	DETAIL                      	TICKET REFERENCE/ NO.
1.       zali              	    2/14/2022            Original Version             			   	DP-49936
2.       zali                   4/5/2022             Removed hardcoded URL routes				Request during UAT
*********************************************************************************************************/
public with sharing class NF_ProcessCCPayment {
  public static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMap = LBrands_API_Integration_Setting__mdt.getAll();
  private static LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
    private static Integer tout = (Integer)lbAPI.Timeout__c==null?5000:lbAPI.Timeout__c.intValue();

  public static String chatKey;
  private static List<ResponseLog> responseLogs = new List<ResponseLog>();


  private static HttpRequest buildRequest(String orderNumber) {
    HttpRequest request = new HttpRequest();
        LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get( 'CCProcessPayment' );
        String endpoint = lbAPIMDT.Endpoint__c+orderNumber;
    request.setEndpoint(endpoint);
    request.setMethod('GET');
    request.setTimeout(tout);
    system.debug('ZA: Building HttpRequest String');
    return request;
  }
  @InvocableMethod(label='Get Payment Link' callout=true)
  public static List<String> getPaymentLink(List<String> orderNumbers){
    List<String> urlList=new List<String>();
    String URL;
    String randomId = genRand(32);
    try{
      HttpRequest request =buildRequest(orderNumbers[0]);
      HttpResponse response = new Http().send(request);
      system.debug('ZA: Payment Link response: ' + response.getStatusCode());
      Map<String,Object> respBody = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
      if(respBody.containsKey('data')&&respBody.get('data')!=null){
        URL=buildURL(orderNumbers[0], respBody);
        system.debug('ZA: Returned URL: ' + URL);
      }
      urlList.add(URL);
      return urlList;
            
    }
    catch(Exception e){
      return parseException(e, randomId);
    }
  }

  private static String buildURL(String orderNumber, Map<String, Object> respBody) {
    LBrands_API_Integration_Setting__mdt lbAPIMDT = lbAPIIntegSettingsMap.get( 'Payment_Link' );
          	Map<String,Object> dataBody = (Map<String,Object>)respBody.get('data'); 
            String URL=lbAPIMDT.Endpoint__c;
    String orgId;
    String orderToken;
            orgId = (String)dataBody.get('OrgId');
            orderToken = (String)dataBody.get('OrderToken');
            URL +='orderId='+orderNumber+'&orgId='+orgId+'&token='+orderToken;
    return URL;
  }

    public static List<String> parseException(Exception e, String randomId){
    List<String> responseList = new List<String>();
    NF_OrderServiceN.APIResponse apiResp = new NF_OrderServiceN.APIResponse();
    apiResp.status = 'Failed';
        apiResp.statusCode = 0;
        if(e.getMessage() == 'Read timed out'){
      apiResp.responseError = 'API Timeout';
        }else{
      apiResp.responseError = e.getMessage();
    }

    String serializedResp = JSON.serialize(apiResp);
        if(lbAPI != null && (lbAPI.Error_Logging__c == true || lbAPI.All_Logging__c == true)){
            responseLogs.add(new ResponseLog(randomId, serializedResp, serializedResp, chatKey));
            if(!responseLogs.isEmpty()){
        createResponseLog(JSON.serialize(responseLogs));
        responseLogs.clear();
      }
    }
    responseList.add(serializedResp);
    return responseList;
  }


    private static String genRand(Integer len){
    Blob blobKey = Crypto.generateAesKey(128);
    String key = EncodingUtil.convertToHex(blobKey);
        String uuid = key.substring(0,len);
    return uuid;
  }
  /**TODO: return bad response to user */
  @future
    private static void createResponseLog(String serializedLog){

        List<ResponseLog> resLogs = (List<ResponseLog>)(JSON.deserialize(serializedLog, List<ResponseLog>.class));

        if(resLogs != null && !resLogs.isEmpty()){

      //Collect ChatKeys
      Set<String> chatKeys = new Set<String>();
            for(ResponseLog rl : resLogs){
                if(String.isNotBlank(rl.chatKey)){
          chatKeys.add(rl.chatKey);
        }
      }

            //Fetch bot sessions
            List<ebotdata__Bot_Session__c> botSessions = [SELECT Id, ebotdata__Live_Agent_Session_Id__c FROM ebotdata__Bot_Session__c WHERE ebotdata__Live_Agent_Session_Id__c IN :chatKeys];
      Map<String, Id> chatKeyBySessionIdMap = new Map<String, Id>();
      
            if(!botSessions.isEmpty()){
          //Fillup the session map
                for(ebotdata__Bot_Session__c session : botSessions){
                    if(String.isNotBlank(String.valueOf(session.ebotdata__Live_Agent_Session_Id__c)) && !chatKeyBySessionIdMap.containsKey(session.ebotdata__Live_Agent_Session_Id__c)){
                        chatKeyBySessionIdMap.put(session.ebotdata__Live_Agent_Session_Id__c, session.Id);
          }
        }
      }

      //Fillup List to of logs insert
      List<Response__c> responeToInsert = new List<Response__c>();
            for(ResponseLog rl : resLogs){
        Response__c resp = new Response__c();
        resp.X_Request_Id__c = rl.randomId;
        resp.Deserialized__c = rl.serializedResp;
        resp.Raw__c = rl.raw;
                if(rl.chatKey != null && chatKeyBySessionIdMap.containsKey(rl.chatKey)){
          resp.Bot_Session__c = chatKeyBySessionIdMap.get(rl.chatKey);
        }
        responeToInsert.add(resp);
      }

            if(!responeToInsert.isEmpty()){
        insert responeToInsert;
      }
    }
  }

    public class ResponseLog{
    public String randomId;
    public String serializedResp;
    public String raw;
    public String chatKey;

        public ResponseLog(String randomId, String serializedResp, String raw, String chatKey){
      this.randomId = randomId;
      this.serializedResp = serializedResp;
      this.raw = raw;
      this.chatKey = chatKey;
    }
  }
}