/****************************************************************************************************************
* Program Name         : AccountIntegrationService
* Description          : This class is used to send the Account record changes to CGrid.
* Version              : 1.1
* Modification Log     : 12 May, 2021 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-37893       1.1       Divyanshu Kumar      05/12/2021      This class is used to send the Account record changes to CGrid.
*                                                                                Accepts Account record as incoming param. Called from account trigger.
*   SM_01          NA              1.2      Shujaath Mohammed    07/09/2021      Testing a component deploy for pipeline fixes.
*   PW_01          NA              1.3      Peter Waddington     09/10/2021      Making classes visible to be used in other related functions
*                  DP-62497        1.4      Sharath Vadla        11/23/2022      Sending the salesforce shipping address(Person Mailing address fields) to CGRID billing address object                                                                                                                             
*****************************************************************************************************************/


public with sharing class AccountIntegrationService extends CallOutService implements Queueable, Database.AllowsCallouts{
    private Account acc;
    List<String> changedFields;
    GetAccountResponseWrapper accountDetailsFromCGrid;
    public AccountIntegrationService(Account acc,List<String> changedFields){
        this.acc = acc;
        this.changedFields = changedFields;
        System.debug('changed fields :: '+changedFields);
    }
    public void execute(QueueableContext qtx){
        try{
            sendAccountData(acc);
        }
        catch(Exception e){
            LoggerUtility.insertLog('AccountIntegrationService','execute',e);
        }
    }
    public void sendAccountData(Account acc){
        GetCustomerByIdWrapper objReq = new GetCustomerByIdWrapper();
        objReq.brand = 'VS';
        objReq.id= acc.CID__c;
        //objReq.phone = '999-111-2222';
        //----------------------------Get Metadata------------------//
        C_Grid_API_Config__mdt  getCustomerMetadata = C_Grid_API_Config__mdt.getInstance('GETCustomer');
        C_Grid_API_Config__mdt  saveCustomerMetadata = C_Grid_API_Config__mdt.getInstance('SAVECustomer');
        
        String requestBody = JSON.serialize( objReq );
        PostRequest postRequest   = new PostRequest();
        postRequest.setRelativeEndpoint(getCustomerMetadata.Endpoint__c);
        postRequest.setBody( requestBody );
        
        RestResponse responseCall = doPost( postRequest );
        System.debug('Response Body POST::  '+String.valueOf(responseCall.getData()));
        if( responseCall.getStatusCode() == 200 ){
            List<GetAccountResponseWrapper> resApiObj = ( List<GetAccountResponseWrapper>)JSON.deserialize(String.valueOf(responseCall.getData() ), List<GetAccountResponseWrapper>.class);
            if(!resApiObj.isEmpty()){
                accountDetailsFromCGrid = resApiObj[0];
                SaveCustomerRequestWrapper objSaveReq = createSaveCallRequest();
                PostRequest postReq   = new PostRequest();
                postReq.setRelativeEndpoint(saveCustomerMetadata.Endpoint__c);
                postReq.setBody( JSON.serialize( objSaveReq ) );
                RestResponse responsePostCall = doPost(postReq);
                System.debug('Request Body POST::  '+ JSON.serialize( objSaveReq ));
                if( responsePostCall.getStatusCode() == 200 ){
                    SaveCustomerResponseWrapper resSaveApiObj = (SaveCustomerResponseWrapper)JSON.deserialize(String.valueOf(responsePostCall.getData() ), SaveCustomerResponseWrapper.class);
                    System.debug('Response Body POST::  '+String.valueOf(responsePostCall.getData()));
                }
                else{
                    //-----Log if Save Customer API throws error(Status != 200)--------
                    LoggerUtility.insertLog('AccountIntegrationService','sendAccountData',new LoggerUtility.Logger( JSON.serialize(objSaveReq), String.valueOf( responsePostCall.getData() ) ) );
                }
            }
        }
        else{
            //-----Log if GET Customer API throws error(Status != 200)--------
            LoggerUtility.insertLog('AccountIntegrationService','sendAccountData',new LoggerUtility.Logger(requestBody,String.valueOf(responseCall.getData() ) ) );
        }
    }

    private SaveCustomerRequestWrapper createSaveCallRequest(){
        SaveCustomerRequestWrapper objSaveReq = new SaveCustomerRequestWrapper();
        objSaveReq.id = acc.CID__c;
        objSaveReq.firstName = changedFields.contains('FirstName') ? acc.FirstName : accountDetailsFromCGrid.firstName;
        objSaveReq.lastName = changedFields.contains('LastName') ? acc.LastName : accountDetailsFromCGrid.lastName;
        objSaveReq.email = changedFields.contains('PersonEmail') ? acc.PersonEmail : accountDetailsFromCGrid.email;
        objSaveReq.brand = accountDetailsFromCGrid.brand;
        objSaveReq.direct = accountDetailsFromCGrid.direct;
        objSaveReq.phone = changedFields.contains('Phone') ? acc.Phone : accountDetailsFromCGrid.phone;
        objSaveReq.channel = 'SALESFORCE';
        objSaveReq.middleName = changedFields.contains('MiddleName') ? acc.MiddleName : null;
        //-----------Match Address-----------------
         // objSaveReq.address.state = changedFields.contains('BillingState') ? acc.BillingState : accountDetailsFromCGrid.address.state;
         // objSaveReq.address.city = changedFields.contains('BillingCity') ? acc.BillingCity : accountDetailsFromCGrid.address.city;
         // objSaveReq.address.country = changedFields.contains('BillingCountry') ? acc.BillingCountry : accountDetailsFromCGrid.address.country;
          //objSaveReq.address.postalCode = changedFields.contains('BillingPostalCode') ? acc.BillingPostalCode : accountDetailsFromCGrid.address.postalCode;
          //objSaveReq.address.pobox = accountDetailsFromCGrid.address.pobox;
        //--------Revised Shipping Address fields Mapping to Cgrid api billing address fields
        objSaveReq.address.state = changedFields.contains('PersonMailingState') ? acc.PersonMailingState : accountDetailsFromCGrid.address.state;
        objSaveReq.address.city = changedFields.contains('PersonMailingCity') ? acc.PersonMailingCity : accountDetailsFromCGrid.address.city;
        objSaveReq.address.country = changedFields.contains('PersonMailingCountry') ? acc.PersonMailingCountry : accountDetailsFromCGrid.address.country;
        objSaveReq.address.postalCode = changedFields.contains('PersonMailingPostalCode') ? acc.PersonMailingPostalCode : accountDetailsFromCGrid.address.postalCode;
        objSaveReq.address.pobox = accountDetailsFromCGrid.address.pobox;
        //----------------Match Shipping Address------------
        //objSaveReq.shipAddress.state = changedFields.contains('PersonMailingState') ? acc.PersonMailingState : accountDetailsFromCGrid.shipAddress.state;
        //objSaveReq.shipAddress.city = changedFields.contains('PersonMailingCity') ? acc.PersonMailingCity : accountDetailsFromCGrid.shipAddress.city;
        //objSaveReq.shipAddress.country = changedFields.contains('PersonMailingCountry') ? acc.PersonMailingCountry : accountDetailsFromCGrid.shipAddress.country;
        //objSaveReq.shipAddress.postalCode = changedFields.contains('PersonMailingPostalCode') ? acc.PersonMailingPostalCode : accountDetailsFromCGrid.shipAddress.postalCode;
        //objSaveReq.shipAddress.pobox = accountDetailsFromCGrid.shipAddress.pobox;
        objSaveReq = processAccountStreetDetails(objSaveReq);
        return objSaveReq;
    }

    private SaveCustomerRequestWrapper processAccountStreetDetails(SaveCustomerRequestWrapper objSaveReq){
        List<String> lstMailingStreet;
        List<String> lstBillingStreet;
        if(changedFields.contains('PersonMailingStreet')){
            lstMailingStreet = acc.PersonMailingStreet.split('\n');
        }
        if(changedFields.contains('BillingStreet')){
            lstBillingStreet = acc.BillingStreet.split('\n');
        }
        //--------Revised Shipping Address fields Mapping to Cgrid api billing address fields
        objSaveReq.address.streetAddress1 = (lstMailingStreet != null && lstMailingStreet[0] != null) ?   lstMailingStreet[0] : accountDetailsFromCGrid.address.streetAddress1;
        //-----Address Street------------
       // objSaveReq.address.streetAddress1 = (lstBillingStreet != null && lstBillingStreet[0] != null) ?  lstBillingStreet[0] : accountDetailsFromCGrid.address.streetAddress1;
        //---Ship Address Street----------
        //objSaveReq.shipAddress.streetAddress1 = (lstMailingStreet != null && lstMailingStreet[0] != null) ?   lstMailingStreet[0] : accountDetailsFromCGrid.shipAddress.streetAddress1;
        try{
            objSaveReq.address.streetAddress2 = (lstMailingStreet != null && lstMailingStreet[1] != null) ?   lstMailingStreet[1] : accountDetailsFromCGrid.address.streetAddress2;
            objSaveReq.address.streetAddress3 = (lstBillingStreet != null && lstBillingStreet[2] != null) ?  lstBillingStreet[2] : accountDetailsFromCGrid.address.streetAddress3;
        }
        catch(Exception e){
            System.debug('ADDRESS EXCEPTION :: LIST INDEX OUT OF BOUNDS FOR STREET BILLING ADDRESS '+ e.getMessage());
        }
        // try{
        //     objSaveReq.shipAddress.streetAddress2 = (lstMailingStreet != null && lstMailingStreet[1] != null) ?   lstMailingStreet[1] : accountDetailsFromCGrid.shipAddress.streetAddress2;
        //     objSaveReq.shipAddress.streetAddress3 = (lstMailingStreet != null && lstMailingStreet[2] != null) ?  lstMailingStreet[2] : accountDetailsFromCGrid.shipAddress.streetAddress3;
        // }
        // catch(Exception e){
        //     System.debug('ADDRESS EXCEPTION :: LIST INDEX OUT OF BOUNDS FOR STREET SHIPPING ADDRESS '+ e.getMessage());
        // }
        return objSaveReq;
    }

    public class GetCustomerByIdWrapper{
        public String brand;
        public String id;
        //String phone;
    }
    public class GetAccountResponseWrapper {
        public String id;	
        public String rid;	
        public String brand;	
        public String email;	
        public String phone;	
        public String firstName;	
        public String lastName;	
        public boolean direct;
        public AdressWrapper address;
        public ShipmentAddressWrapper shipAddress;
        public String lastUpdateTime;	
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
    public class SaveCustomerRequestWrapper{
        public String id;
        public String brand;	
        public String firstName;	
        public String lastName;	
        public String middleName;	
        public String email;	
        public String phone;	
        public boolean direct;
        public AdressWrapper address;
        public ShipmentAddressWrapper shipaddress;
        public String channel;
        public SaveCustomerRequestWrapper(){
            this.address = new AdressWrapper();
            this.shipaddress = new ShipmentAddressWrapper();
        }	
    }
    public class SaveCustomerResponseWrapper{
        public String customerID;	
	    public String customerRID;	
    }
}