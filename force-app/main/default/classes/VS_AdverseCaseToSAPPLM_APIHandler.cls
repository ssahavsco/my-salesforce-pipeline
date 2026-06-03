/**************************************************************************************************************************
 * Program Name         : VS_AdverseCaseToSAPPLM_APIHandler
 * Description          : Handler class to push adverse case data to SAP
 * Version              : 1.0
 * Modification Log     : 11 September, 2024
 *--------------------------------------------------------------------------------------------------------------------------
 *  JiraId        Version    Developer               Date           Description
 *--------------------------------------------------------------------------------------------------------------------------
 *  CCS-527       1.0       Himanshu Mishra        09/11/2024       Initial commit
 *  CCS-1072      1.1       Himanshu Mishra        12/17/2024       Allow mulitple articles
 *  CCS-1345      1.2       Himanshu Mishra        03/29/2026       Migrated Credentials to ECA
 ***************************************************************************************************************************/

public with sharing class VS_AdverseCaseToSAPPLM_APIHandler {
  private static final String METADATA_NAMESPACE = 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata';
  private static final String ERROR_CODE_001 = 'ERROR/001';
  private static final String ERROR_CODE_002 = 'ERROR/002';
  private static final String DEFAULT_ERROR_MSG = 'Bad Request';
  private static final String DEFAULT_ERROR_CODE = 'ERROR';
  private static final String CSRF_TOKEN_HEADER = 'x-csrf-token';
  private static final String SET_COOKIE_HEADER = 'set-cookie';
  private static final String COOKIE_HEADER = 'Cookie';
  private static final String CONTENT_TYPE_HEADER = 'Content-Type';

  private static ServiceIntegration__c authTokenService = ServiceIntegration__c.getInstance(
    'SAP_Auth_Token'
  );
  private static ServiceIntegration__c csrfTokenService = ServiceIntegration__c.getInstance(
    'SAP_CSRF_Token'
  );
  private static ServiceIntegration__c sapCalloutService = ServiceIntegration__c.getInstance(
    'SAP_Callout_Service'
  );

  /**
   * @description Processes records to push adverse case data to SAP.
   * @param input - The input data containing adverse case details.
   * @return List of FlowOutput indicating the success or failure of the operation.
   */
  public static List<VS_AdverseCaseToSAPPLM_API.FlowOutput> processRecords(
    VS_AdverseCaseToSAPPLM_API.FlowInput input
  ) {
    List<VS_AdverseCaseToSAPPLM_API.FlowOutput> flowOutputList = new List<VS_AdverseCaseToSAPPLM_API.FlowOutput>();
    VS_AdverseCaseToSAPPLM_API.FlowOutput flowOutput = new VS_AdverseCaseToSAPPLM_API.FlowOutput();
    flowOutput.isSuccess = false;

    // Prepare common fields
    String adverseEventDate = prepareAdverseEventDate(input.adverseEventDate);
    String sfCaseNumber = input.sfCaseNumber;
    String eventType = input.eventType;
    String beautyAdverseReactionSurvey = input.beautyAdverseReactionSurvey;

    Map<String, String> surveyDetails = parseSurveyDetails(
      beautyAdverseReactionSurvey
    );
    String symptoms = surveyDetails.get('symptoms');
    String skinArea = surveyDetails.get('skinArea');
    String symptomsDuration = surveyDetails.get('symptomsDuration');

    List<String> rawArticles = splitAndNormalizeArticles(input.articleNo);

    ReqWrapper baseWrapper = prepareRequestWrapper(
      eventType,
      sfCaseNumber,
      adverseEventDate,
      symptomsDuration,
      skinArea,
      symptoms
    );

    Case caseRecord = [SELECT Id FROM Case WHERE Id = :input.recordId LIMIT 1];

    // Get CSRF token once per transaction
    List<String> csrfTokenList = generatecsrfToken();
    if (csrfTokenList.isEmpty() || String.isBlank(csrfTokenList[0])) {
      flowOutput.isSuccess = false;
      flowOutput.apiResponseStatusCode = 401;
      flowOutput.errorMessage = 'Failed to fetch CSRF token';
      flowOutputList.add(flowOutput);
      logger.saveLog();
      return flowOutputList;
    }

    String csrf = csrfTokenList[0];
    String cookie = prepareCookie(csrfTokenList);

    // Prepare HTTP reusables
    String endpoint =
      sapCalloutService.Base_Url__c + sapCalloutService.Suffix_URL__c;
    String methodName = sapCalloutService.Method_Name__c;
    String contentType = sapCalloutService.Content_Type__c;

    // Per-article callout and result aggregation
    Boolean anyFailed = false;
    Integer lastCode;
    String lastError;
    String failedArticles = '';
    CalloutException sapCalloutException;

    for (String article : rawArticles) {
      ReqWrapper req = baseWrapper.deepCopy();
      req.Article = article;
      String reqBody = JSON.serialize(req);

      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint(endpoint);
      request.setMethod(methodName);
      request.setHeader(CSRF_TOKEN_HEADER, csrf);
      request.setHeader(CONTENT_TYPE_HEADER, contentType);
      if (!String.isBlank(cookie)) {
        request.setHeader(COOKIE_HEADER, cookie);
      }
      request.setBody(reqBody);
      logger.info('Request body: ' + reqBody);

      try {
        HttpResponse response = http.send(request);
        Integer statusCode = response.getStatusCode();

        if (statusCode == 201) {
          // Article pushed successfully
        } else if (statusCode == 400) {
          anyFailed = true;
          Dom.Document doc = new Dom.Document();
          doc.load(response.getBody());
          Dom.XmlNode rootNode = doc.getRootElement();
          // Extract error details from XML using helper method
          String errCode = getNodeText(
            rootNode,
            'code',
            METADATA_NAMESPACE,
            DEFAULT_ERROR_CODE
          );
          String errMsg = getNodeText(
            rootNode,
            'message',
            METADATA_NAMESPACE,
            DEFAULT_ERROR_MSG
          );

          CalloutException apiCalloutException = new CalloutException();
          apiCalloutException.setMessage(errMsg);
          lastError = errMsg;
          // Handle record lock error codes
          if (errCode == ERROR_CODE_001 || errCode == ERROR_CODE_002) {
            sapCalloutException = apiCalloutException;
            failedArticles += article + ', ';
          } else {
            logger.error(
              'Article ' +
                article +
                ' failed. Code: ' +
                errCode +
                ' Message: ' +
                errMsg,
              caseRecord,
              apiCalloutException
            );
          }
        } else {
          anyFailed = true;
          logger.error(
            'SAP Failure for article ' +
              article +
              ' ---> ' +
              statusCode +
              ' Body ---> ' +
              response.getBody(),
            caseRecord
          );
          lastError = 'Failed to publish data to SAP';
        }
        lastCode = statusCode;
      } catch (Exception ex) {
        logger.error(
          'Unexpected error for article ' + article + ': ' + ex.getMessage(),
          caseRecord,
          ex
        );
        lastCode = 500;
        lastError = 'Unexpected error during callout';
      }
    }

    if (String.isNotBlank(failedArticles)) {
      logger.error(
          'Articles ' + failedArticles + ' failed due to record lock error',
          caseRecord,
          sapCalloutException
        )
        .setField(LogEntryEvent__e.isDataPublishedToSAP__c, false)
        .setField(LogEntryEvent__e.SAP_Articles__c, failedArticles);
    }

    // Aggregate result for Flow
    flowOutput.isSuccess = !anyFailed;
    flowOutput.apiResponseStatusCode = lastCode;
    flowOutput.errorMessage = lastError;
    flowOutputList.add(flowOutput);

    logger.saveLog();
    return flowOutputList;
  }

  /**
   * @description Prepares the adverse event date string from a DateTime input.
   * @param adverseEventDateTime - The DateTime input.
   * @return Formatted date string YYYYMMDD or empty string if null.
   */
  private static String prepareAdverseEventDate(DateTime adverseEventDateTime) {
    if (adverseEventDateTime == null) {
      return '';
    }
    Date adEventDate = adverseEventDateTime.date();
    return String.valueOf(adEventDate.year()) +
      String.valueOf(adEventDate.month()).leftPad(2, '0') +
      String.valueOf(adEventDate.day()).leftPad(2, '0');
  }

  /**
   * @description Parses the survey string to extract symptoms, skin area, and duration.
   * @param surveyString - The raw survey string.
   * @return Map containing symptoms, skinArea, and symptomsDuration.
   */
  private static Map<String, String> parseSurveyDetails(String surveyString) {
    Map<String, String> result = new Map<String, String>{
      'symptoms' => '',
      'skinArea' => '',
      'symptomsDuration' => ''
    };

    if (String.isBlank(surveyString)) {
      return result;
    }

    String[] symptomsParts = surveyString.split('Symptoms: ');
    if (symptomsParts.size() < 2) {
      return result;
    }

    String afterSymptoms = symptomsParts[1].replaceAll('\\?: ', '');
    String[] symptomSplit = afterSymptoms.split('<br>');
    result.put(
      'symptoms',
      String.valueOf(symptomSplit[0]).replaceAll(';', ',')
    );

    if (afterSymptoms.contains('Part of Body')) {
      String partBody = afterSymptoms.split('Part of Body')[1];
      String[] pbSplit = partBody.split('<br>');
      if (!pbSplit.isEmpty()) {
        result.put('skinArea', String.valueOf(pbSplit[0]));
      }
    }

    if (afterSymptoms.contains('How long did the symptoms persist')) {
      String dur = afterSymptoms.split('How long did the symptoms persist')[1];
      String[] dSplit = dur.split('<br>');
      if (!dSplit.isEmpty()) {
        result.put('symptomsDuration', String.valueOf(dSplit[0]));
      }
    }

    return result;
  }

  /**
   * @description Splits and normalizes a comma-separated article number string.
   * @param articleNo - Raw comma-separated article numbers.
   * @return List of trimmed, non-blank article numbers.
   */
  private static List<String> splitAndNormalizeArticles(String articleNo) {
    List<String> rawArticles = new List<String>();
    if (!String.isBlank(articleNo)) {
      for (String a : articleNo.split(',')) {
        String trimmed = a != null ? a.trim() : null;
        if (!String.isBlank(trimmed)) {
          rawArticles.add(trimmed);
        }
      }
    }
    return rawArticles;
  }

  /**
   * @description Safely prepares the cookie string from the CSRF token list.
   * @param csrfTokenList - List containing CSRF token and raw cookie string.
   * @return Formatted cookie string or empty string if insufficient segments.
   */
  private static String prepareCookie(List<String> csrfTokenList) {
    if (csrfTokenList.size() < 2 || String.isBlank(csrfTokenList[1])) {
      return '';
    }
    String[] cookieParts = csrfTokenList[1].split(';');
    if (cookieParts.size() < 5) {
      // Fall back to the full raw cookie if not enough segments
      return csrfTokenList[1];
    }
    return cookieParts[2] + ';' + cookieParts[3] + ';' + cookieParts[4];
  }

  /**
   * @description Helper method to safely extract text from an XML node.
   * @param parentNode - The parent XML node.
   * @param nodeName - The name of the child node.
   * @param namespace - The namespace of the child node.
   * @param defaultValue - The default value if the node is null.
   * @return String - The text content of the node or the default value.
   */
  private static String getNodeText(
    Dom.XmlNode parentNode,
    String nodeName,
    String namespace,
    String defaultValue
  ) {
    Dom.XmlNode childNode = parentNode.getChildElement(nodeName, namespace);
    return childNode != null ? childNode.getText() : defaultValue;
  }

  /**
   * @description Generates a CSRF token by calling the SAP CSRF token service.
   * @return List containing the CSRF token and cookie string.
   */
  public static List<String> generatecsrfToken() {
    List<String> csrfList = new List<String>();
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String endpoint =
      csrfTokenService.Base_Url__c + csrfTokenService.Suffix_URL__c;
    request.setEndpoint(endpoint);
    request.setMethod(csrfTokenService.Method_Name__c);
    request.setHeader(CSRF_TOKEN_HEADER, 'FETCH');

    HttpResponse response = http.send(request);
    if (response.getStatusCode() == 200) {
      String csrfToken = response.getHeader(CSRF_TOKEN_HEADER);
      String setCookie = response.getHeader(SET_COOKIE_HEADER);
      if (csrfToken != null) {
        csrfList.add(csrfToken);
      }
      if (setCookie != null) {
        csrfList.add(setCookie);
      }
      logger.info('CSRF token and cookie retrieved successfully.');
    } else {
      logger.error(
        'SAP Get CSRF Token Failure ---> ' +
          response.getStatusCode() +
          ' Body ---> ' +
          response.getBody()
      );
    }
    return csrfList;
  }
  /**
   * @description Prepares the base request wrapper with common fields.
   * @return Populated ReqWrapper instance.
   */
  private static ReqWrapper prepareRequestWrapper(
    String eventType,
    String sfCaseNumber,
    String adverseEventDate,
    String symptomsDuration,
    String skinArea,
    String symptoms
  ) {
    ReqWrapper baseWrapper = new ReqWrapper();
    baseWrapper.EventType = eventType;
    baseWrapper.SfCaseNumber = sfCaseNumber;
    baseWrapper.EventDate = adverseEventDate;
    baseWrapper.Duration = symptomsDuration;
    baseWrapper.SkinArea = skinArea;
    baseWrapper.Symptoms = symptoms;
    baseWrapper.Type = '';
    baseWrapper.Message = '';
    baseWrapper.LogNo = '';
    return baseWrapper;
  }
  /**
   * @description Wrapper class for the SAP PLM API request payload.
   *              Contains all fields required for the SAP API callout
   *              and provides a deepCopy method for per-article requests.
   */
  public class ReqWrapper {
    /** @description Article number to be pushed to SAP */
    public String Article;
    /** @description Event date in YYYYMMDD format */
    public String EventDate;
    /** @description Salesforce Case Number */
    public String SfCaseNumber;
    /** @description Type of adverse event */
    public String EventType;
    /** @description Duration of symptoms */
    public String Duration;
    /** @description Affected skin area */
    public String SkinArea;
    /** @description Symptoms reported */
    public String Symptoms;
    /** @description Type of request */
    public String Type;
    /** @description Message or description */
    public String Message;
    /** @description SAP Log Number */
    public String LogNo;

    /**
     * @description Creates a deep copy of this wrapper instance.
     *              Copies all fields except Article, which is set per iteration.
     * @return New ReqWrapper instance with copied field values.
     * @example
     *   ReqWrapper base = new ReqWrapper();
     *   base.EventDate = '20240101';
     *   ReqWrapper copy = base.deepCopy();
     *   copy.Article = '12345';
     */
    public ReqWrapper deepCopy() {
      ReqWrapper copy = new ReqWrapper();
      copy.EventDate = this.EventDate;
      copy.SfCaseNumber = this.SfCaseNumber;
      copy.EventType = this.EventType;
      copy.Duration = this.Duration;
      copy.SkinArea = this.SkinArea;
      copy.Symptoms = this.Symptoms;
      copy.Type = this.Type;
      copy.Message = this.Message;
      copy.LogNo = this.LogNo;
      // Note: Article is intentionally NOT copied
      // as it is set per article in the loop
      return copy;
    }
  }
}