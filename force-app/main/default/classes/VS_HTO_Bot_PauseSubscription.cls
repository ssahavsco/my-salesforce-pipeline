public with sharing class VS_HTO_Bot_PauseSubscription {
  public class PauseInput {
    @InvocableVariable
    public String subscriberEmail;
    @InvocableVariable
    public String pauseFrequency;
  }
  public class ApiOutput {
    @InvocableVariable
    public Boolean isPauseApiCallSuccess;
  }
  @InvocableMethod(label='HTO - Pause Subscription')
  public static List<ApiOutput> bot_pauseSubscription(
    List<PauseInput> pause_input
  ) {
    ApiOutput api_output_instance = new ApiOutput();
    List<ApiOutput> api_outputs = new List<VS_HTO_Bot_PauseSubscription.ApiOutput>();
    api_output_instance.isPauseApiCallSuccess = false;
    try {
      if (
        String.isNotEmpty(pause_input[0].subscriberEmail) &&
        String.isNotEmpty(pause_input[0].pauseFrequency)
      ) {
        VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper responseWrapper = new VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper();
        responseWrapper = VS_HomeTryOnServicesCallout.pauseSubscription(
          pause_input[0].pauseFrequency,
          pause_input[0].subscriberEmail
        );
        if (
          responseWrapper.statusCode == 200 ||
          responseWrapper.statusCode == 201 ||
          responseWrapper.statusCode == 204
        ) {
          api_output_instance.isPauseApiCallSuccess = true;
        } else {
          Logger.error(
            'Simone-Error while Pausing HTO Subscription' +
            JSON.serialize(responseWrapper.response)
          );
          Logger.saveLog();
        }
        api_outputs.add(api_output_instance);
      }
      return api_outputs;
    } catch (Exception e) {
      Logger.error(
        'Simone-Exception while Pausing HTO Subscription at line number ' +
          e.getStackTraceString() +
          'and the exception is : ' +
          e.getMessage()
      );
      Logger.saveLog();
      return api_outputs;
    }
  }
}