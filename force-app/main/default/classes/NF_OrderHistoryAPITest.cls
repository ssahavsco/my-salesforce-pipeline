@IsTest
public class NF_OrderHistoryAPITest {
    
    @TestSetup public static void setup(){
        
        LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
        LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.Host__c = 'apitest.victoriassecret.com';
        LBrandCustomS.Origin__c = 'https://test.victoriassecret.com';
        LBrandCustomS.Client_Secret__c = 'eJv4s59Hd7Y7lzIjJboqJwhTIVS4';
        LBrandCustomS.Client_ID__c = 'sfccs';
        LBrandCustomS.All_Logging__c = true;
        LBrandCustomS.Error_Logging__c = true;
        LBrandCustomS.AES_Key__c = 'PeSgVkYp3s6v9y$B&E)H@McQfTjWmaaa';
        LBrandCustomS.OrderDetails__c = '/orderdetails/v8/orders';
        insert LBrandCustomS;
    }
    @IsTest
    static void searchOrderWithEmailTest() {
        String email = '123@gmail.com';
        String orderId = 'S000123333';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        System.assertNotEquals(null, NF_OrderHistoryAPI.searchOrder(email,true), 'should have value');
        Test.stopTest();
    }
    @IsTest
    static void searchOrderWithEmailAndPhoneZipTest() {
        String email = '123@gmail.com';
        String orderId = 'S000123333';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        System.assertNotEquals(null, NF_OrderHistoryAPI.searchOrder(email,'','',true), 'should have value');
        Test.stopTest();
    }
    @IsTest
    static void orderByIdAndEmailTest() {
        String email = '123@gmail.com';
        String orderId = 'S000123333';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        System.assertNotEquals(null,NF_OrderHistoryAPI.orderByIdAndEmail(orderId,email,true), 'should have value');
        Test.stopTest();
    }
    @IsTest
    static void getAuthTokenTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        System.assertNotEquals(NF_OrderHistoryAPI.getAuthToken(), 'should have value');
        Test.stopTest();
    }

    @IsTest
    static void ordersTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
	    //NF_OrderHistoryAPI.orders('WQJEWirfeiwofzjdfsfuifhfh');
        Test.stopTest();
    } 

    @isTest
    static void validate_1(){
        Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
        Test.startTest();
        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = '12345';
        insert session;
        NF_OrderHistoryAPI.chatKey = '12345';
        NF_OrderHistoryAPI.parseException(new System.DmlException(), '123456');
        NF_OrderHistoryAPI.parseException(new System.CalloutException(), '123456');
        NF_OrderHistoryAPI.searchOrder('123@gmail.com','123456789','4566-546',false,2);
        NF_OrderHistoryAPI.searchOrderWithLimit('123@gmail.com','123456789','4566-546',2);
        NF_OrderHistoryAPI.orders('4646446464656464454644646644646464',2);
        Test.stopTest();
    }
}