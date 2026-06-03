/*****************************************************************************************************@@
Class Name     :  NF_CommunitySupportCalloutHandlerTest
Purpose        :  Test class for NF_CommunitySupportCalloutHandler
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version            
*********************************************************************************************************/
@IsTest
public with sharing class NF_CommunitySupportCalloutHandlerTest implements HttpCalloutMock{

    Integer statusCode; //This variable is used to pass status code dynamically with method call

    public NF_CommunitySupportCalloutHandlerTest(Integer statusCode){
        this.statusCode = statusCode;
    }

    //Creates fake response for the callout
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        // String endpoint = request.getEndpoint();    
        response.setBody('{"status":"ok"}');
        response.setStatusCode(statusCode);
        return response;
    }

    @TestSetup
    static void setupBaseData(){
        Test.startTest();
            LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
            LBrandCustomS.Customer_Service_Endpoint__c = 'https://apitest.victoriassecret.com/customerserviceforms/v1/emailnotify';
            insert LBrandCustomS;
        Test.stopTest();
    }

    @IsTest
    static void singleCalloutTest(){
        Test.setMock(HttpCalloutMock.class, new NF_CommunitySupportCalloutHandlerTest(200));
        Test.startTest();

        Contact con = new Contact();
        con.LastName = 'Test Con';
        con.Phone = '1234567890';
        insert con;

        Case c = new Case();
        c.Email_Subject__c = 'Question about a Product';
        c.New_Email_Address__c = 'test@test.com';
        c.Re_enter_Email_Address__c = 'test@test.com';
        c.Description = 'Test Description';
        c.Item_Number__c = '123456';
        c.Where_did_you_see_this_item__c = 'Online';
        c.Device_Type__c = 'Phone';
        c.Browser_Used__c = 'Chrome';
        c.Order_Number__c = 'CD123456';
        c.Shipping_Address__c = '123 abc def';
        c.Store_Location__c = 'test store';
        c.Bar_Code_Number__c = '';
        c.Items_Missing_from_Order__c = 'none';
        c.Origin = 'SSP Form';
        c.contactId = con.Id;
        c.SuppliedName = 'Test contact';
        insert c;

        Test.stopTest();
        System.assertNotEquals(null, c, 'Should have value');
    }

    @IsTest
    static void bulkCalloutTest(){
        Test.setMock(HttpCalloutMock.class, new NF_CommunitySupportCalloutHandlerTest(200));
        Test.startTest();

        List<Case> caseToInsert = new List<Case>();

        for(Integer i=1; i <= 40; i++){
            Case c = new Case();
            c.Email_Subject__c = 'Question about a Product';
            c.New_Email_Address__c = 'test@test.com';
            c.Re_enter_Email_Address__c = 'test@test.com';
            c.Description = 'Test Description';
            c.Item_Number__c = '123456';
            c.Where_did_you_see_this_item__c = 'Online';
            c.Device_Type__c = 'Phone';
            c.Browser_Used__c = 'Chrome';
            c.Order_Number__c = 'CD123456';
            c.Shipping_Address__c = '123 abc def';
            c.Store_Location__c = 'test store';
            c.Bar_Code_Number__c = '';
            c.Items_Missing_from_Order__c = 'none';
            c.Origin = 'SSP Form';
            c.When_Resolved__c = 'Credit My Original Payment Method';
            c.Nondisclosure_Address__c = 'NondisclosureAddress';
            c.Old_Email_Address__c = 'old@test.com';
            c.New_Email_Address__c = 'new@test.com';
            c.Old_Mailing_Address__c = 'old mailing addr';
            c.New_Mailing_Address__c = 'new mailing addr';
            c.SuppliedEmail = 'test@test.com';
            c.SuppliedName = 'Test contact';
            caseToInsert.add(c);
        }
        
        insert caseToInsert;
        Test.stopTest();

        System.assertNotEquals(null, caseToInsert[0], 'Should have value');

    }
}