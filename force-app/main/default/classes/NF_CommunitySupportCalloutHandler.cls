/*****************************************************************************************************@@
Class Name     :  NF_CommunitySupportCalloutHandler
Purpose        :  Handler class for community case support callout 
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version           
2.       Matt McKinley          10/21/20 

@Testsuite:  {NF_CommunitySupportCalloutHandlerTest}                                       
*********************************************************************************************************/
public without sharing class NF_CommunitySupportCalloutHandler{

    //Get Info from Custom Settings
    public static LBrandsAPI__c lbAPI = LBrandsAPI__c.getOrgDefaults();
    
    /**
     * @name createCalloutChunks
     * @params List<Id> caseIds
     * @description Creates async chunks for the cases to be processed
     */
    @InvocableMethod(label='Create Community Support Case Callout' description='Creates callout for community support case' category='Case')
    public static void createCalloutChunks(List<Id> caseIds) {        
        //Fill request bodies from cases
        for(Case c : [SELECT ID, Mailing_Address__c,Email_Subject__c, SuppliedEmail, Re_enter_Email_Address__c, Description, Item_Number__c, Where_did_you_see_this_item__c, 
                     Device_Type__c, Browser_Used__c, SuppliedPhone, Order_Number__c, Shipping_Address__c, Store_Location__c, Bar_Code_Number__c,
                     Items_Missing_from_Order__c, SuppliedName, When_Resolved__c, Nondisclosure_Address__c, Old_Email_Address__c, Old_Mailing_Address__c,
                     New_Email_Address__c, New_Mailing_Address__c FROM Case WHERE ID IN :caseIds]){

            //Create Wrapper Instance
            CaseCalloutWrapper ccw      = new CaseCalloutWrapper();
            ccw.contactName             = c.SuppliedName;
            ccw.emailSubject            = c.Email_Subject__c;
            ccw.emailAddress            = c.SuppliedEmail;
            ccw.reEnterEmailAddress     = c.Re_enter_Email_Address__c;
            ccw.comments                = c.Description;
            ccw.itemNumberOrDescription = c.Item_Number__c;
            ccw.whereDidYouSeeThisItem  = c.Where_did_you_see_this_item__c;
            ccw.deviceUsed              = c.Device_Type__c;
            ccw.browser                 = c.Browser_Used__c;
            ccw.daytimePhone            = c.SuppliedPhone;
            ccw.orderNumber             = c.Order_Number__c;
            ccw.shippingAddress         = c.Shipping_Address__c;
            ccw.storeVisited            = c.Store_Location__c;
            ccw.barCodeNumberOnReceipt  = c.Bar_Code_Number__c;
            ccw.itemsMissingFromOrder   = c.Items_Missing_from_Order__c;
            ccw.whenResolved            = c.When_Resolved__c;
            ccw.nonDisclosureAddress    = c.Nondisclosure_Address__c;
            ccw.oldEmailAddress         = c.Old_Email_Address__c;
            ccw.newEmailAddress         = c.New_Email_Address__c;
            ccw.oldMailingAddress       = c.Old_Mailing_Address__c;
            ccw.newMailingAddress       = c.New_Mailing_Address__c;
            ccw.mailingAddress          = c.Mailing_Address__c;
            
            if(Limits.getFutureCalls() >= Limits.getLimitFutureCalls()){
                break;
            }
            processRequest(JSON.serialize(ccw),c.Id);
        }
    }

    /**
     * @name processRequests
     * @params List<String> singleChunkRequestBodies
     * @description This method actually make callouts
     */
    @future(callout=true)
    public static void processRequest(String reqBody,Id caseId){    
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(lbAPI.Customer_Service_Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(reqBody);
            HttpResponse res = new Http().send(req);

            //save Response__c
            Response__c r = new Response__c(Raw__c =res.getBody(), Request_Body__c = reqBody, Status__c =res.getStatus(),Parameters__c = caseId);
            insert r;
            if(res.getStatusCode()==200){
                update new case(Id=caseId,emailCalloutSuccessful__c=true);
            }
        } catch (Exception e){
            System.debug(LoggingLevel.DEBUG, e.getMessage());
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
    }

    public class CaseCalloutWrapper{
        public String contactName;
        public String emailSubject;
        public String emailAddress;
        public String reEnterEmailAddress;
        public String comments;
        public String itemNumberOrDescription;
        public String whereDidYouSeeThisItem;
        public String deviceUsed;
        public String browser;
        public String daytimePhone;
        public String orderNumber;
        public String shippingAddress;
        public String storeVisited;
        public String barCodeNumberOnReceipt;
        public String itemsMissingFromOrder;
        public String whenResolved;
        public String nonDisclosureAddress;
        public String oldEmailAddress;
        public String newEmailAddress;
        public String oldMailingAddress;
        public String newMailingAddress;
        public String mailingAddress;
    }
}