/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Description : Home Try-On skip box from simone
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Sharath Vadla  <svadla@victoria.com>
 * @version        1.0
 * @created        08/22/2023
 * @modified       10/22/2023
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * Modifications Log
 * Ver   Story#     Date         Author              Modification
 * 1.0   CCS-43      08/22/2023   Sharath Vadla        Initial Version.
 * 1.1               10/22/2023   Sharath Vadla        Added Nebula Loggers
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class VS_HTO_Bot_SkipNextBox {
  public class SkipInput {
    @InvocableVariable
    public String subscriberEmail;
    @InvocableVariable
    public Integer skipMonth;
    @InvocableVariable
    public Integer skipYear;
    @InvocableVariable
    public String skipSource;
  }
  public class ApiOutput {
    @InvocableVariable
    public Boolean isSkipApiCallSuccess;
  }
  @InvocableMethod(label='HTO - SKIP NEXT BOX')
  public static List<ApiOutput> skipNextBox(List<SkipInput> skip_input) {
    ApiOutput api_output_instance = new ApiOutput();
    List<ApiOutput> api_outputs = new List<VS_HTO_Bot_SkipNextBox.ApiOutput>();
    api_output_instance.isSkipApiCallSuccess = false;
    try {
      if (
        String.isNotEmpty(skip_input[0].subscriberEmail) &&
        skip_input[0].skipMonth != null &&
        skip_input[0].skipYear != null &&
        String.isNotEmpty(skip_input[0].skipSource)
      ) {
        VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper responseWrapper = new VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper();
        responseWrapper = VS_HomeTryOnServicesCallout.skipBox(
          skip_input[0].skipMonth,
          skip_input[0].skipYear,
          skip_input[0].skipSource,
          skip_input[0].subscriberEmail
        );
        if (
          responseWrapper.statusCode == 200 ||
          responseWrapper.statusCode == 201 ||
          responseWrapper.statusCode == 204
        ) {
          api_output_instance.isSkipApiCallSuccess = true;
        } else {
          Logger.error(
            'Simone-Error while skipping next box' +
            JSON.serialize(responseWrapper.response)
          );
          Logger.saveLog();
        }
        api_outputs.add(api_output_instance);
      }
      return api_outputs;
    } catch (Exception e) {
      Logger.error(
        'Simone-Exception while skipping next box at line number ' +
          e.getStackTraceString() +
          'and the exception is : ' +
          e.getMessage()
      );
      Logger.saveLog();
      return api_outputs;
    }
  }
}