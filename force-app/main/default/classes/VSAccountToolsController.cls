/*
 ************˜***********************************************************************************************
 * Program Name      : VSAccountToolsController
 * Description       : Controller class to show and manage data on LWC component vsAccountTools
 * Version           : 1.1
 * Modification Log  : 26-05-2021
 *----------------------------------------------------------------------------------------------------------
 * RequirementId     JiraId      Version     Developer           Date            Description
 *----------------------------------------------------------------------------------------------------------
 * REQ_01            DP-37149    1.1         Ravikant Kedia      13-05-2021      Created class for vsAccountTools data
 * REQ_02            DP-37149    1.2         Ravikant Kedia      26-05-2021      commenting and hit Proper API to get
 *                                                                               the data.
 ***********************************************************************************************************
 */
public class VSAccountToolsController {
  public static Map<String, LBrands_API_Integration_Setting__mdt> endPointMetaData = LBrands_API_Integration_Setting__mdt.getAll();

  @AuraEnabled
  public static String getAccountEmail(String recordId, String objectName) {
    String queryString = 'SELECT Id, ';
    queryString += (objectName == 'Case')
      ? 'Account.PersonEmail'
      : 'EndUserContact.Email';
    queryString += ' FROM ' + objectName + ' WHERE Id = :recordId';

    List<sObject> recordList = Database.query(queryString);
    return JSON.serialize(recordList[0]);
  }

  @AuraEnabled
  public static String getDetails(String email) {
    // Created Service class object
    CCCToolsVSAccountRestService serviceObj = new CCCToolsVSAccountRestService();
    RestResponse response = new RestResponse();
    LBrands_API_Integration_Setting__mdt endPointMetadataObj = endPointMetaData.get('CCCTools_VSAccountTools');
    serviceObj.endPointMetadataObj = endPointMetadataObj;
    if (endPointMetadataObj.Active__c) {
      
      // Created Get Request Object
      PostRequest postreq = new PostRequest();
      //REQ_02
      //REQ_02

      postreq.setBody('{"email": "' + email + '"}');

      // call service class method and store responce in RestResponse class object
      response = serviceObj.doPost(postreq);
      String responseData = (String) response.getData();  
      if (responseData != null) {
      	response.setData(JSON.serialize((CCCToolsVSAccountDetailsWrapper) System.JSON.deserialize(responseData, CCCToolsVSAccountDetailsWrapper.class)));
      }    
      return JSON.serialize(response);
    } else {
      RestServiceError serviceError = new RestServiceError();
      serviceError.setMessage(
        endPointMetadataObj.Status_Code_500_Message__c
      );
      serviceError.setErrorCode(500);
      response.setError(serviceError);
      return JSON.serialize(response);
    }
  }

  @AuraEnabled
  public static String deleteCustomerAccount(
    String email,
    String recordId,
    String objectName
  ) {
    // Created Service class object
    CCCToolsVSAccountRestService serviceObj = new CCCToolsVSAccountRestService();
    LBrands_API_Integration_Setting__mdt endPointMetadataObj = endPointMetaData.get('CCCTools_VSAccountTools_DeleteCustomer');
    serviceObj.endPointMetadataObj = endPointMetadataObj;
    RestResponse response = new RestResponse();
    if (
      endPointMetadataObj.Active__c
    ) {
      
      PostRequest postReq = new PostRequest();
      postReq.setBody('{"email": "' + email + '"}');

      // call service class method and store responce in RestResponse class object
      response = serviceObj.doPost(postReq);
      if(response.getStatusCode() ==200){
        response.setData(endPointMetadataObj.Status_Code_200_Message__c );
      }  
      return JSON.serialize(response);
    } else {
      RestServiceError serviceError = new RestServiceError();
      serviceError.setMessage(
        endPointMetadataObj.Status_Code_500_Message__c
      );
      serviceError.setErrorCode(500);
      response.setError(serviceError);
      return JSON.serialize(response);
    }
  }
}