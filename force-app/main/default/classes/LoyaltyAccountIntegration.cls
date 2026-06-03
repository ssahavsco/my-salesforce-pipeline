/****************************************************************************************************************
* Program Name         : LoyaltyAccountIntegration
* Description          : This class is used to get the Loyalty details from CGrid.
* Version              : 1.1
* Modification Log     : 19 July, 2022 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   SK_01          DP-37893       1.1       Sumit Saha      07/19/2022      This class is used to get the Loyalty details to CGrid.

*                  DP-62332       1.2       Sharath Vadla   12/07/2022      Created ZipCode wrapper to Accomdate the Name and Zip code Search functionality    

                   DP-61909       1.3       Sharath Vadla   12/16/2022       Adding Nebula Logger methods

                   DP-64087       1.4       Sumit Saha      02/27/2023       Reporting for VSCC Cardholders for Bread Financial 
                   DP-63906       1.4       Sumit Saha      03/01/2023       Adding Sf account record Id in response back to lwc              
********************************************************************************************************************************/

public with sharing class LoyaltyAccountIntegration extends CallOutService {
  @AuraEnabled
  public static String getAccountCID(String accountId) {
    String cid;
    try {
      List<Account> account = [
        SELECT
          id,
          Name,
          CID__c,
          Loyalty_ID__pc,
          Loyalty_account_Status__pc,
          Customer_Type__pc
        FROM account
        WHERE id = :accountId
      ];
      Map<String, LoyaltyCustomerTypeMap__mdt> mapType = LoyaltyCustomerTypeMap__mdt.getAll();

      if (account.size() > 0) {
        if (!String.isEmpty((String) account[0].get('CID__c'))) {
          cid = (String) account[0].get('CID__c');
        }

        Loyalty loyalty = new Loyalty();

        if (
          (String.isEmpty((String) account[0].get('Loyalty_ID__pc')) ||
          String.isEmpty(
            (String) account[0].get('Loyalty_account_Status__pc')
          ) ||
          String.isEmpty((String) account[0].get('Customer_Type__pc'))) &&
          !String.isEmpty(cid)
        ) {
          String str = getLoyaltyDetailsByCID(cid);
          List<GetAccountResponseWrapper> res = (List<GetAccountResponseWrapper>) JSON.deserialize(
            string.valueOf(str),
            List<GetAccountResponseWrapper>.class
          );

          Map<String, LoyaltyStatusMap__mdt> lsm = LoyaltyStatusMap__mdt.getAll();

          if (
            !String.isEmpty(res[0].Loyalty.Id) ||
            !String.isEmpty(res[0].Loyalty.status)
          ) {
            loyalty.id = res[0].Loyalty.Id;
            loyalty.status = (String) lsm.get(res[0].Loyalty.status)
              .get('CCS_Display_Status__c');
            updateLayaltyDetails(res, accountId);
          }
        }

        if (string.isEmpty(loyalty.id)) {
          loyalty.id = (String) account[0].get('Loyalty_ID__pc');
          loyalty.status = (String) account[0]
            .get('Loyalty_account_Status__pc');
        }
        return JSON.serialize(loyalty);
      }
      return null;
    } catch (Exception e) {
      Logger.error(
        'Exception in Storing Loyalty ID of to Account :: ' + e.getMessage()
      );
      Logger.saveLog();
      return null;
      // throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String getLoyaltyDetailsByCID(String cid) {
    String cgridResponse;
    GetCustomerWrapper objReq = new GetCustomerWrapper();
    objReq.id = cid;

    C_Grid_API_Config__mdt getCustomerMetadata = C_Grid_API_Config__mdt.getInstance(
      'GetLoyaltyCustomer'
    );

    String requestBody = JSON.serialize(objReq);
    PostRequest postReq = new PostRequest();
    postReq.setRelativeEndpoint(getCustomerMetadata.Endpoint__c);
    postReq.setBody(requestBody);

    RestResponse responseCall = new CallOutService().doPost(postReq);
    List<GetAccountResponseWrapper> resPostApiObj;

    if (responseCall.getStatusCode() == 200) {
      resPostApiObj = (List<GetAccountResponseWrapper>) JSON.deserialize(
        String.valueOf(responseCall.getData()),
        List<GetAccountResponseWrapper>.class
      );
      if (!resPostApiObj.isEmpty()) {
        cgridResponse = JSON.serialize(resPostApiObj);
      }
    } else {
      Logger.error(
        'API Error in getting Loyalty Account Details :: ' +
        String.valueOf(responseCall.getData())
      );
      Logger.saveLog();
    }
    return cgridResponse;
  }

  @AuraEnabled
  public static String loyaltyDetailsLookup(String searchParam) {
    system.debug(searchParam);
    String cgridResponse;
    String requestBody;
    Input input = (Input) JSON.deserialize(
      string.valueOf(searchParam),
      Input.class
    );
    if (input.postalCode != null) {
      GetZipSearchWrapper obj = new GetZipSearchWrapper();
      obj.brand = input.brand;
      obj.firstName = input.firstName;
      obj.lastName = input.lastName;
      obj.postalCode = input.postalCode;
      requestBody = JSON.serialize(obj);
    } else {
      GetCustomerWrapper obj = new GetCustomerWrapper();
      obj.brand = input.brand;
      obj.Id = input.Id;
      obj.email = input.email;
      obj.phone = input.phone;
      obj.direct = input.direct;

      if (input.LoyaltyId != null) {
        obj.loyaltyId.id = input.LoyaltyId.id;
      }
      requestBody = JSON.serialize(obj);
    }

    try {
      Logger.debug('Request Body to call Customer/v4 api->' + requestBody);
      C_Grid_API_Config__mdt getCustomerMetadata = C_Grid_API_Config__mdt.getInstance(
        'GetLoyaltyCustomer'
      );

      PostRequest postReq = new PostRequest();
      postReq.setRelativeEndpoint(getCustomerMetadata.Endpoint__c);
      postReq.setBody(requestBody);

      RestResponse responsePostCall = new CallOutService().doPost(postReq);

      List<GetAccountResponseWrapper> resPostApiObj;

      if (responsePostCall.getStatusCode() == 200) {
        resPostApiObj = (List<GetAccountResponseWrapper>) JSON.deserialize(
          String.valueOf(responsePostCall.getData()),
          List<GetAccountResponseWrapper>.class
        );

        if (!resPostApiObj.isEmpty()) {
          Map<String, LoyaltyStatusMap__mdt> mapStatus = LoyaltyStatusMap__mdt.getAll();
          Map<String, LoyaltyCustomerTypeMap__mdt> mapType = LoyaltyCustomerTypeMap__mdt.getAll();
          Map<String, LoyaltyTierCodeMap__mdt> mapTierCode = LoyaltyTierCodeMap__mdt.getAll();

          GetCustomerLoyalty getCustomerLoyalty = new GetCustomerLoyalty();
          getCustomerLoyalty.customer = resPostApiObj;

          List<String> cid = new List<String>();

          for (Integer i = 0; i < getCustomerLoyalty.customer.size(); i++) {
            cid.add(getCustomerLoyalty.customer[i].id);

            String tierCode = getCustomerLoyalty.customer[i].loyalty.tierCode;
            String status = getCustomerLoyalty.customer[i].loyalty.status;
            String customerType = getCustomerLoyalty.customer[i]
              .loyalty.customerType;

            try {
              getCustomerLoyalty.customer[i].loyalty.tierCode = !String.isEmpty(
                  tierCode
                ) && !String.isEmpty(customerType)
                ? (String) mapTierCode.get(tierCode).get(customerType + '__c')
                : null;
            } catch (System.NullPointerException e) {
              getCustomerLoyalty.customer[i].loyalty.tierCode = null;
              //    LoggerUtility.insertLog('LoyaltyAccountIntegration','getAccountDetailsByCID',new LoggerUtility.Logger(requestBody,String.valueOf(responsePostCall.getData())));
              Logger.error(
                'Exception in reading status from cgrid api call: ' +
                String.valueOf(e.getMessage())
              );
            }

            try {
              getCustomerLoyalty.customer[i].loyalty.status = !String.isEmpty(
                  status
                )
                ? (String) mapStatus.get(status).get('CCS_Display_Status__c')
                : null;
            } catch (System.NullPointerException e) {
              getCustomerLoyalty.customer[i].loyalty.status = null;
              //    LoggerUtility.insertLog('LoyaltyAccountIntegration','getAccountDetailsByCID',new LoggerUtility.Logger(requestBody,String.valueOf(responsePostCall.getData())));
              Logger.error(
                'Exception in reading status from cgrid api call: ' +
                String.valueOf(e.getMessage())
              );
            }

            try {
              getCustomerLoyalty.customer[i]
                .loyalty.customerType = !String.isEmpty(customerType)
                ? (String) mapType.get(customerType).get('Description__c')
                : null;
              Boolean isEnrolled = !String.isEmpty(customerType) &&
                mapType?.get(customerType)?.get('Is_Enrolled__c') != null
                ? (Boolean) mapType?.get(customerType)?.get('Is_Enrolled__c')
                : false;
              getCustomerLoyalty.customer[i].loyalty.vsccStatus = isEnrolled
                ? 'Enrolled'
                : 'Not Enrolled';
            } catch (System.NullPointerException e) {
              getCustomerLoyalty.customer[i].loyalty.customerType = null;
              // LoggerUtility.insertLog('LoyaltyAccountIntegration','getAccountDetailsByCID',new LoggerUtility.Logger(requestBody,String.valueOf(responsePostCall.getData())));
              Logger.error(
                'Exception in reading status from cgrid api call: ' +
                String.valueOf(e.getMessage())
              );
            }
          }

          Response response = new Response();
          response.statusCode = responsePostCall.getStatusCode();
          response.statusMessage = responsePostCall.getStatusCode() == 200
            ? 'Success'
            : null;
          getCustomerLoyalty.response = response;

          Account[] acc = [SELECT Id, cid__c FROM Account WHERE cid__c = :cid];
          for (Integer i = 0; i < acc.size(); i++) {
            for (Integer j = 0; j < getCustomerLoyalty.customer.size(); j++) {
              if (acc[i].CID__c == getCustomerLoyalty.customer[j].id) {
                getCustomerLoyalty.customer[i].sfAccountRecordId = acc[i].Id;
              }
            }
          }

          cgridResponse = JSON.serialize(getCustomerLoyalty);
          Logger.debug('Response from Customer/V4 api Call->' + cgridResponse);
        } else if (responsePostCall.getStatusCode() == 200) {
          GetCustomerLoyalty getCustomerLoyalty = new GetCustomerLoyalty();
          getCustomerLoyalty.customer = resPostApiObj;

          Response response = new Response();
          response.statusCode = responsePostCall.getStatusCode();
          response.statusMessage = responsePostCall.getStatusCode() == 200
            ? 'Success'
            : null;
          getCustomerLoyalty.response = response;

          cgridResponse = JSON.serialize(getCustomerLoyalty);
          // System.debug( LoggingLevel.DEBUG  , '@@@ Response from CGRID :: ' + cgridResponse);
          Logger.debug('Response from Customer/V4 api Call->' + cgridResponse);
        }
      } else {
        //  LoggerUtility.insertLog('LoyaltyAccountIntegration','getAccountDetailsByCID',new LoggerUtility.Logger(requestBody,String.valueOf(responsePostCall.getError()) ) );
        Logger.error(String.valueOf(responsePostCall.getError()));
        Response response = new Response();
        response.statusCode = responsePostCall.getStatusCode();
        response.statusMessage = String.valueOf(responsePostCall.getError());

        GetCustomerLoyalty getCustomerLoyalty = new GetCustomerLoyalty();
        getCustomerLoyalty.response = response;
        cgridResponse = JSON.serialize(getCustomerLoyalty);
        // System.debug( LoggingLevel.DEBUG  , '@@@ Response from CGRID :: ' + cgridResponse);
        Logger.debug('Response from Customer/V4 api Call->' + cgridResponse);
      }
      Logger.saveLog();

      return cgridResponse;
    } catch (Exception ex) {
      system.debug('Expection logger ' + ex.getLineNumber());
      Logger.error('Exception in Customer/v4 api call :: ' + ex.getMessage());
      Logger.saveLog();

      return null;
    }
  }

  public static void updateLayaltyDetails(
    List<GetAccountResponseWrapper> res,
    String accountId
  ) {
    Account acc = new Account();
    acc = [
      SELECT id, Loyalty_ID__pc, Loyalty_account_Status__pc
      FROM account
      WHERE id = :accountId
    ];

    Map<String, LoyaltyStatusMap__mdt> lsm = LoyaltyStatusMap__mdt.getAll();
    Map<String, LoyaltyCustomerTypeMap__mdt> mapType = LoyaltyCustomerTypeMap__mdt.getAll();

    try {
      acc.Loyalty_ID__pc = res[0].Loyalty.Id;
      acc.Loyalty_account_Status__pc = (String) lsm.get(res[0].Loyalty.status)
        .get('CCS_Display_Status__c');
      acc.Customer_Type__pc = !String.isEmpty(res[0].loyalty.customerType)
        ? (String) mapType.get(res[0].loyalty.customerType)
            .get('Description__c')
        : null;

      update acc;
    } catch (Exception e) {
      Logger.error(
        'Exception in updating Loyalty ID and status :: ' + e.getMessage()
      );
      Logger.saveLog();
      // System.debug('Exception :: ' + e.getMessage());
      // LoggerUtility.insertLog('LoyaltyAccountIntegration','updateLayaltyDetails',new LoggerUtility.Logger('Failed to update the Loyalty Id/status for recordId: ' + accountId ,String.valueOf(e.getMessage())));
    }
  }

  public class GetCustomerWrapper {
    public String brand;
    public String id;
    public String email;
    public String phone;
    public Boolean direct;
    public LoyaltyId loyaltyId;

    public GetCustomerWrapper() {
      this.loyaltyId = new LoyaltyId();
    }
  }
  public class GetZipSearchWrapper {
    public String brand;
    public String firstName;
    public String lastName;
    public String postalCode;
  }
  public class GetCustomerLoyalty {
    public List<GetAccountResponseWrapper> customer;
    public Response response;

    public GetCustomerLoyalty() {
      this.customer = new List<GetAccountResponseWrapper>();
      this.response = new Response();
    }
  }

  public class GetAccountResponseWrapper {
    public String id;
    public String sfAccountRecordId;
    public String rid;
    public String brand;
    public String email;
    public String phone;
    public String phoneType;
    public String birthDate;
    public String firstName;
    public String lastName;
    public boolean direct;
    public AdressWrapper address;
    public ShipmentAddressWrapper shipAddress;
    public Loyalty loyalty;
    public String lastUpdateTime;

    public GetAccountResponseWrapper() {
      this.loyalty = new Loyalty();
      this.address = new AdressWrapper();
      this.shipAddress = new ShipmentAddressWrapper();
    }
  }

  public class AdressWrapper {
    public String streetAddress1;
    public String streetAddress2;
    public String streetAddress3;
    public String pobox;
    public String city;
    public String state;
    public String postalCode;
    public String country;
  }

  public class ShipmentAddressWrapper {
    public String streetAddress1;
    public String streetAddress2;
    public String streetAddress3;
    public String pobox;
    public String city;
    public String state;
    public String postalCode;
    public String country;
  }

  public class Loyalty {
    public String id;
    public String type;
    public String adsID;
    public String status;
    public String statusReason;
    public String tierCode;
    public String customerType;
    public String vsccStatus;
  }

  public class Response {
    public Integer statusCode;
    public string statusMessage;
  }

  public class Input {
    public String brand;
    public String firstName;
    public String lastName;
    public String postalCode;
    public String id;
    public String email;
    public String phone;
    public Boolean direct;
    public LoyaltyId loyaltyId;

    public Input() {
      this.loyaltyId = new LoyaltyId();
    }
  }

  public class LoyaltyId {
    public String id;
  }
}