/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Home Try On Order Lookup class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Pooja Korrapati  <lkorrapati@victoria.com>
* @version        1.0
* @created        07/05/2023
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class VS_HomeTryOnOrderLookup {
  public static Map<String,String> mapfulfillmentStatusId = new Map<String,String>();
  static{
    List<AO_Status_Code_Mapping__mdt> lststatuscode = AO_Status_Code_Mapping__mdt.getAll().values();
    for(AO_Status_Code_Mapping__mdt statuscodeobj:lststatuscode){
      mapfulfillmentStatusId.put(statuscodeobj.MasterLabel,statuscodeobj.Status_Name__c);
    }
  }
  
  //Method to get  HTO Order details from AO 
  @InvocableMethod(label='Get HTO Order Lookup')
  public static List<Output> invokeGetHtoOrder(List<Input> inputs) {
    try {
      List<Output> outputResponse = new List<Output>();
      Output outputInstance = new Output();
      NF_CreateOrderTransaction.InitialResponse transactionResponseWrapper = new NF_CreateOrderTransaction.InitialResponse();

      // make callout to pHist by order ID to get HTO order details 
      transactionResponseWrapper = NF_CreateOrderTransaction.getOrderTransactionDetail(inputs[0].orderId);
      
      if (transactionResponseWrapper.statusCode == 200 || transactionResponseWrapper.statusCode == 201 ) {
        if (transactionResponseWrapper.successData != null && transactionResponseWrapper.successData.transactions.size()>0) {
          String statuscode =(String) transactionResponseWrapper.successData.transactions[0].MaxFulfillmentStatusId;
          outputInstance.homeTryOnStance = statuscode;
          if(mapfulfillmentStatusId!=null && mapfulfillmentStatusId.get(statuscode) != null){
            outputInstance.homeTryOnStance =(String)mapfulfillmentStatusId.get(statuscode) ;
          }
          
        }  
      } 
      outputInstance.htoStatusCode = transactionResponseWrapper.statusCode ;
      outputResponse.add(outputInstance);
      
      return outputResponse;
    } catch (Exception ex) {
      Logger.error(
        'Error while calling HTO Order Lookup in AO' +
        String.valueOf(ex.getMessage())
      );
      Logger.saveLog();
      system.debug(
        'Exception in VS_HomeTryOnBotServiceCalls' + ex.getMessage()
      );
      return null;
    }
  }

  //Input parameters from Simon
  public class Input {
    @InvocableVariable(required=true)
    public String chatkey;

    @InvocableVariable(required=true)
    public String email;

    @InvocableVariable(required=true)
    public String orderId;
  }
  
  //Output parameters to  Simon
  public class Output {
    @InvocableVariable
    public String homeTryOnStance;
    @InvocableVariable
    public Integer htoStatusCode;    
  }

  public class HtoOrderResponse {
    public String htoOrderPlaceHolder;
  }
 
}