/******************************************************************************************************************************
* Program Name         : LB_ParentObjPersonAccountEdit
* Version              : 1.0
* Modification Log      : 06 April, 2023 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   SK_01          DP-64109      1.1       Sumit Saha      04/06/2023      Chat: Add Customer Details for Authenticated Customer                                                                                                                   
********************************************************************************************************************************/

public with sharing class LB_ParentObjPersonAccountEdit {

    @InvocableMethod(label='Calling LoyaltyAccountIntegration to get the customer details' )
    public static List<Output> getAccountDetails(List<Input> input){
        String response =  LoyaltyAccountIntegration.loyaltyDetailsLookup(JSON.serialize(input[0]));          
        LoyaltyAccountIntegration.GetCustomerLoyalty g = (LoyaltyAccountIntegration.GetCustomerLoyalty)  JSON.deserializeStrict(response, LoyaltyAccountIntegration.GetCustomerLoyalty.class);
        List<Output> output = new  List<Output>();

        System.debug('LB_ParentObjPersonAccountEdit :: Case Id ==>' + input[0].caseID);

        try{
            Account account = new Account();
            account.Id = (Id) g.customer[0].sfAccountRecordId;
            account.FirstName = !String.isEmpty(g.customer[0].firstName) ? g.customer[0].firstName : null;
            account.LastName = !String.isEmpty(g.customer[0].lastName) ? g.customer[0].lastName : null;
            account.CID__c =   !String.isEmpty(g.customer[0].Id) ? g.customer[0].Id : null ;
            account.PersonEmail = !String.isEmpty(g.customer[0].email) ? g.customer[0].email : null;
            account.phone =  !String.isEmpty(g.customer[0].phone) ? g.customer[0].phone : null;

            account.PersonMailingStreet = !String.isEmpty(g.customer[0].shipAddress.streetAddress1) ? g.customer[0].shipAddress.streetAddress1 : null;
            account.PersonMailingCity = !String.isEmpty(g.customer[0].shipAddress.city) ? g.customer[0].shipAddress.city : null;
            account.PersonMailingState = !String.isEmpty(g.customer[0].shipAddress.state) ? g.customer[0].shipAddress.state : null;
            account.PersonMailingPostalCode = !String.isEmpty(g.customer[0].shipAddress.postalCode) ? g.customer[0].shipAddress.postalCode : null;
            account.PersonMailingCountry = !String.isEmpty(g.customer[0].shipAddress.country) ? g.customer[0].shipAddress.country : null;
           
            upsert account;

            Case cs = new Case();
            cs.Id = input[0].caseID;
            cs.AccountId = account.Id;
            update cs;

            Output out = new output();
            out.accountID = account.Id;
            output.add(out);

            System.debug( 'LB_ParentObjPersonAccountEdit :: Account Id ==> ' + account.Id);

            return output;

        }catch(Exception e){
            System.debug( 'LB_ParentObjPersonAccountEdit::Exception ' + e.getLineNumber() + ' --> ' + e.getMessage() );
        }

        return output;

    }

    public class Input{

        @InvocableVariable(required=true)
        public String brand;

        @InvocableVariable(required=true)
        public String email;

        @InvocableVariable(required=true)
        public String caseID;
    }

    public class Output{

        @invocableVariable
        public String accountID;

    }
}