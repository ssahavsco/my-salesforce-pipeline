@isTest
public with sharing class NF_CalloutTestPageControllerTest implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }

    @isTest
    static void validate(){
        Test.setMock(HttpCalloutMock.class, new NF_CalloutTestPageControllerTest());
        Test.startTest();
        NF_CalloutTestPageController.searchOrder('abc@test.com');
        NF_CalloutTestPageController.searchOrder_1('abc@test.com','1234567890','132-456');
        NF_CalloutTestPageController.searchOrderWithLimit('abc@test.com','1234567890','132-456',10);
        NF_CalloutTestPageController.orders('134564646464646', 10);
        NF_CalloutTestPageController.orderByIdAndEmail('1354646','abc@test.com');
        Test.stopTest();
    }
}