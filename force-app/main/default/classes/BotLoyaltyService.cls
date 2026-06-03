public with sharing class BotLoyaltyService {

    @InvocableMethod(label='Get Loyalty Id and Status')
    public static List<Output> callOutLoyaltyService(List<Input> inputs){

        System.debug('BotLoyaltyService :: ' + inputs[0].chatkey);
        System.debug('BotLoyaltyService :: ' + inputs[0].email);

        List<Output> out = new List<Output>();
        Output o = new Output();

        ebotdata__Bot_Session__c[] ebotSession = [SELECT Id, Loyalty_Id__c, Loyalty_Status__c, Customer_Full_Name__c FROM ebotdata__Bot_Session__c WHERE ebotdata__Live_Agent_Session_Id__c = :inputs[0].chatkey limit 1];
        System.debug(ebotSession);

        if(ebotSession.size() > 0 && String.isEmpty(ebotSession[0].Loyalty_Id__c)){
            LoyaltyAccountIntegration.Input input = new  LoyaltyAccountIntegration.Input();
            input.email = inputs[0].email;
            input.brand = 'VSS';
            String requestBody = JSON.serialize(input);
            String response =  LoyaltyAccountIntegration.loyaltyDetailsLookup(requestBody); 
            LoyaltyAccountIntegration.GetCustomerLoyalty getCustomerLoyalty = (LoyaltyAccountIntegration.GetCustomerLoyalty) JSON.deserialize( response, LoyaltyAccountIntegration.GetCustomerLoyalty.class);

            if (getCustomerLoyalty.customer.size() > 0) {
                o.loyaltyId = !String.isEmpty(getCustomerLoyalty.customer[0].loyalty.id) ? getCustomerLoyalty.customer[0].loyalty.id : 'NA' ;
                o.loyaltyStatus = !String.isEmpty(getCustomerLoyalty.customer[0].loyalty.status) ? getCustomerLoyalty.customer[0].loyalty.status : 'NA';
                o.customerName = getCustomerLoyalty.customer[0].firstName + ' ' + getCustomerLoyalty.customer[0].lastName;
                out.add(o);
                System.debug(out);

                try {
                    ebotdata__Bot_Session__c eb = new ebotdata__Bot_Session__c();
                    eb.Id = ebotSession[0].Id;
                    eb.Customer_Full_Name__c =  o.customerName;
                    eb.Loyalty_Id__c = o.loyaltyId ;
                    eb.Loyalty_Status__c = o.loyaltyStatus;
                    update eb;
                } catch (Exception e) {
                    System.debug( 'Line ==> ' + e.getLineNumber() +  'BotLoyaltyService:: Unable to update : ' + e.getMessage());
                }
            }
            out.add(o);
            System.debug(out);
            return out;
        }else if(ebotSession.size() > 0) {
            o.customerName = ebotSession[0].Customer_Full_Name__c;
            o.loyaltyId = ebotSession[0].Loyalty_Id__c;
            o.loyaltyStatus = ebotSession[0].Loyalty_Status__c;
            out.add(o);
        } 
        out.add(o);
        return out;
    }
    
    public class Input{

        @InvocableVariable(required=true)
        public String chatkey;

        @InvocableVariable(required=true)
        public String email;
    }

    public class Output{
        
        @InvocableVariable
        public String loyaltyId = 'NA';

        @InvocableVariable
        public String loyaltyStatus = 'NA';

        @InvocableVariable
        public String customerName =  'NA';

    }

}