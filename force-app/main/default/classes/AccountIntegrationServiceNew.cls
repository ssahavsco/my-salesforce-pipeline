public class AccountIntegrationServiceNew{
    Static GetAccountResponseWrapper accountDetailsFromCGrid;
     
    @InvocableMethod(label='Get Updated Customer Details' description='Get Updated Customer Details')
    public static void getCustomer(List<Input> input){
        System.debug('Input -> '+input);
        logger.info('Input -> '+input);
        logger.saveLog();
        if(input[0].CID != ''){
            String email = input[0].email;
            List<String> changedFields = new List<String>{'PersonEmail'};
            GetCustomerByIdWrapper objReq = new GetCustomerByIdWrapper();
            objReq.brand = 'VS';
            objReq.id= input[0].CID;
            C_Grid_API_Config__mdt  getCustomerMetadata = C_Grid_API_Config__mdt.getInstance('GETCustomer');
            C_Grid_API_Config__mdt  saveCustomerMetadata = C_Grid_API_Config__mdt.getInstance('SAVECustomer');
            HttpRequest request = new HttpRequest();
            request.setEndpoint(getCustomerMetadata.Endpoint__c);
            request.setMethod('POST'); 
            String requestBody = JSON.serialize( objReq );
            request.setBody(requestBody);
            Http http = new Http();
            // Send the HTTP request and get the response
            HttpResponse response = http.send(request);
            // Process the response
            logger.info('CGRID GET Request Response '+response);
            logger.saveLog();
            System.debug('Resp '+response.getBody());
            if (response.getStatusCode() == 200) {
                System.debug('Resp '+response.getBody());
                List<GetAccountResponseWrapper> resGetApiObj = ( List<GetAccountResponseWrapper>)JSON.deserialize(String.valueOf(response.getBody() ), List<GetAccountResponseWrapper>.class);
                system.debug('resGetApiObj' +resGetApiObj);
                if(!resGetApiObj.isEmpty()){
                    accountDetailsFromCGrid = resGetApiObj[0];
                    SaveCustomerRequestWrapper objSaveReq = createSaveCallRequest(input);
                    HttpRequest postRequest = new HttpRequest();
                    postRequest.setEndpoint(saveCustomerMetadata.Endpoint__c);
                    postRequest.setMethod('POST'); 
                    postRequest.setBody(JSON.serialize(objSaveReq));
                    Http httpPost = new Http();
                    // Send the HTTP request and get the response
                    HttpResponse postResponse = httpPost.send(postRequest);
                    System.debug('Post '+postResponse);
                    logger.info('CGRID POST Request Response '+postResponse);
                    logger.saveLog();
                    if(postResponse.getStatusCode() != 200){
                        CalloutException e = new CalloutException();
                        e.setMessage(String.valueOf(postResponse.getStatusCode()));
                        Logger.error('Exception Occured while updating account details. CGRID Response Status Code - '+postResponse.getStatusCode());
                        Logger.saveLog();
                        throw e;
                    } else{
                        System.debug('CGRID data updated successfully');
                    }
                }
            }
        }
    }
    private static SaveCustomerRequestWrapper createSaveCallRequest(List<Input> input){
        SaveCustomerRequestWrapper objSaveReq = new SaveCustomerRequestWrapper();
        objSaveReq.id = input[0].CID;
        objSaveReq.firstName = accountDetailsFromCGrid.firstName != input[0].firstName ? input[0].firstName : accountDetailsFromCGrid.firstName;
        objSaveReq.lastName = accountDetailsFromCGrid.lastName != input[0].lastName ? input[0].lastName : accountDetailsFromCGrid.lastName;
        objSaveReq.email = accountDetailsFromCGrid.email != input[0].email ? input[0].email : accountDetailsFromCGrid.email;
        objSaveReq.brand = accountDetailsFromCGrid.brand;
        objSaveReq.direct = accountDetailsFromCGrid.direct;
        objSaveReq.phone = accountDetailsFromCGrid.phone != input[0].phone ? input[0].phone : accountDetailsFromCGrid.phone;
        objSaveReq.channel = 'SALESFORCE';
        //objSaveReq.middleName = accountDetailsFromCGrid.middleName != input[0].email ? acc.MiddleName : null;
        //-----------Match Address-----------------
         // objSaveReq.address.state = changedFields.contains('BillingState') ? acc.BillingState : accountDetailsFromCGrid.address.state;
         // objSaveReq.address.city = changedFields.contains('BillingCity') ? acc.BillingCity : accountDetailsFromCGrid.address.city;
         // objSaveReq.address.country = changedFields.contains('BillingCountry') ? acc.BillingCountry : accountDetailsFromCGrid.address.country;
          //objSaveReq.address.postalCode = changedFields.contains('BillingPostalCode') ? acc.BillingPostalCode : accountDetailsFromCGrid.address.postalCode;
          //objSaveReq.address.pobox = accountDetailsFromCGrid.address.pobox;
        //--------Revised Shipping Address fields Mapping to Cgrid api billing address fields
        objSaveReq.address.state = accountDetailsFromCGrid.address.state != input[0].state ? input[0].state : accountDetailsFromCGrid.address.state;
        objSaveReq.address.city = accountDetailsFromCGrid.address.city != input[0].city ? input[0].city : accountDetailsFromCGrid.address.city;
        objSaveReq.address.country = accountDetailsFromCGrid.address.country != input[0].country ? input[0].country : accountDetailsFromCGrid.address.country;
        objSaveReq.address.postalCode = accountDetailsFromCGrid.address.postalCode != input[0].postalCode ? input[0].postalCode : accountDetailsFromCGrid.address.postalCode;
        objSaveReq.address.pobox = accountDetailsFromCGrid.shipAddress.pobox;
        //----------------Match Shipping Address------------
        //objSaveReq.shipAddress.state = changedFields.contains('PersonMailingState') ? acc.PersonMailingState : accountDetailsFromCGrid.shipAddress.state;
        //objSaveReq.shipAddress.city = changedFields.contains('PersonMailingCity') ? acc.PersonMailingCity : accountDetailsFromCGrid.shipAddress.city;
        //objSaveReq.shipAddress.country = changedFields.contains('PersonMailingCountry') ? acc.PersonMailingCountry : accountDetailsFromCGrid.shipAddress.country;
        //objSaveReq.shipAddress.postalCode = changedFields.contains('PersonMailingPostalCode') ? acc.PersonMailingPostalCode : accountDetailsFromCGrid.shipAddress.postalCode;
        //objSaveReq.shipAddress.pobox = accountDetailsFromCGrid.shipAddress.pobox;
        objSaveReq = processAccountStreetDetails(objSaveReq, input);
        return objSaveReq;
    }

    private static SaveCustomerRequestWrapper processAccountStreetDetails(SaveCustomerRequestWrapper objSaveReq, List<Input> input){
        List<String> lstMailingStreet = input[0].street.split('\n');
        //List<String> lstBillingStreet = input[0].street.split('\n');
        
        //--------Revised Shipping Address fields Mapping to Cgrid api billing address fields
        objSaveReq.address.streetAddress1 = (lstMailingStreet != null && lstMailingStreet[0] != null && accountDetailsFromCGrid.shipAddress.streetAddress1 != lstMailingStreet[0]) ?   lstMailingStreet[0] : accountDetailsFromCGrid.shipAddress.streetAddress1;
        //-----Address Street------------
       // objSaveReq.address.streetAddress1 = (lstBillingStreet != null && lstBillingStreet[0] != null) ?  lstBillingStreet[0] : accountDetailsFromCGrid.address.streetAddress1;
        //---Ship Address Street----------
        //objSaveReq.shipAddress.streetAddress1 = (lstMailingStreet != null && lstMailingStreet[0] != null) ?   lstMailingStreet[0] : accountDetailsFromCGrid.shipAddress.streetAddress1;
        /* Commented By Himanshu - 06/19
        try{
            objSaveReq.address.streetAddress2 = (lstBillingStreet != null && lstBillingStreet[1] != null && accountDetailsFromCGrid.shipAddress.streetAddress2 != lstBillingStreet[1]) ?  lstBillingStreet[1] : accountDetailsFromCGrid.address.streetAddress2;
            objSaveReq.address.streetAddress3 = (lstBillingStreet != null && lstBillingStreet[2] != null && accountDetailsFromCGrid.shipAddress.streetAddress3 != lstBillingStreet[2]) ?  lstBillingStreet[2] : accountDetailsFromCGrid.address.streetAddress3;
        }
        catch(Exception e){
            System.debug('ADDRESS EXCEPTION :: LIST INDEX OUT OF BOUNDS FOR STREET BILLING ADDRESS '+ e.getMessage());
        } */
        try{
            objSaveReq.shipAddress.streetAddress2 = (lstMailingStreet != null && lstMailingStreet[1] != null && accountDetailsFromCGrid.shipAddress.streetAddress2 != lstMailingStreet[1]) ?   lstMailingStreet[1] : accountDetailsFromCGrid.shipAddress.streetAddress2;
            objSaveReq.shipAddress.streetAddress3 = (lstMailingStreet != null && lstMailingStreet[2] != null && accountDetailsFromCGrid.shipAddress.streetAddress3 != lstMailingStreet[2]) ?  lstMailingStreet[2] : accountDetailsFromCGrid.shipAddress.streetAddress3;
        }
        catch(Exception e){
            System.debug('ADDRESS EXCEPTION :: LIST INDEX OUT OF BOUNDS FOR STREET SHIPPING ADDRESS '+ e.getMessage());
        }
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
    public class Input{
        @InvocableVariable(required=false)
        public String firstName;
        @InvocableVariable(required=false)
        public String lastName;
        @InvocableVariable(required=false)
        public String email;
        @InvocableVariable(required=false)
        public String phone;
        @InvocableVariable(required=false)
        public String street;
        @InvocableVariable(required=false)
        public String city;
        @InvocableVariable(required=false)
        public String postalCode;
        @InvocableVariable(required=false)
        public String country;
        @InvocableVariable(required=false)
        public String state;
        @InvocableVariable(required=false)
        public String CID;
    }
}