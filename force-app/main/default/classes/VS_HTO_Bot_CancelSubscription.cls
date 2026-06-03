public with sharing class VS_HTO_Bot_CancelSubscription {
  public class CancelInput {
    @InvocableVariable
    public String subscriberEmail;
  }
  public class ApiOutput {
    @InvocableVariable
    public Boolean isCancelSubscriptionApiCallSuccess;
  }
  @InvocableMethod(label='HTO - Cancel Subscription')
  public static List<ApiOutput> bot_CancelSubscription(
    List<CancelInput> cancel_input
  ) {
    ApiOutput api_output_instance = new ApiOutput();
    List<ApiOutput> api_outputs = new List<VS_HTO_Bot_CancelSubscription.ApiOutput>();
    api_output_instance.isCancelSubscriptionApiCallSuccess = false;
    try {
      if (String.isNotEmpty(cancel_input[0].subscriberEmail)) {
        VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper responseWrapper = new VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper();
        responseWrapper = VS_HomeTryOnServicesCallout.unSubscription(
          cancel_input[0].subscriberEmail,
          '',
          '',
          'Simone'
        );
        if (
          responseWrapper.statusCode == 200 ||
          responseWrapper.statusCode == 201 ||
          responseWrapper.statusCode == 204
        ) {
          api_output_instance.isCancelSubscriptionApiCallSuccess = true;
        } else {
          Logger.error(
            'Simone-Error while cancelling HTO Subscription' +
            JSON.serialize(responseWrapper.response)
          );
          Logger.saveLog();
        }
        api_outputs.add(api_output_instance);
      }
      return api_outputs;
    } catch (Exception e) {
      Logger.error(
        'Simone-Exception while cancelling HTO Subscription at line number ' +
          e.getStackTraceString() +
          'and the exception is: ' +
          e.getMessage()
      );
      Logger.saveLog();
      return api_outputs;
    }
  }
}