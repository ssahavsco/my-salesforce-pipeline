/*****************************************************************************************************@@
Class Name     :  NF_OrderHistoryControllerTest
Purpose        :  Test class for NF_OrderHistoryController
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Ravikant                                   Original Version            

*********************************************************************************************************/
@IsTest
public with sharing class NF_OrderHistoryControllerTest {
    
    /**
    * @name testSetupData
    * @description test setup method for test records
    */
    @TestSetup
    static void testSetupData(){

        // LBrandsAPI__c lbAPI = new LBrandsAPI__c(
        //     Active_Omni_Link__c = 'https://lmits.omni.manh.com/customerengagementfacade/app/orderstatus?orderId={orderNumber}&isArchived=false'
        // );
        // insert lbAPI;
        LBrandsAPI__c LBrandCustomS = new LBrandsAPI__c();
        LBrandCustomS.Active_Omni_Link__c = 'https://lmits.omni.manh.com/customerengagementfacade/app/orderstatus?orderId={orderNumber}&isArchived=false';
        LBrandCustomS.Order_Endpoint__c = 'https://apitest.victoriassecret.com';
        LBrandCustomS.Client_Secret__c = 'eJv4s59Hd7Y7lzIjJboqJwhTIVS4';
        LBrandCustomS.Client_ID__c = 'sfccs';
        LBrandCustomS.orderdetails__c = '/orderdetails/v8/orders';
        insert LBrandCustomS;
        // Create common test account
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(LastName = 'Test',PersonEmail='test@gmail.com',RecordTypeId = devRecordTypeId);
        insert acc;
        // Create common test contact
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com');
        insert con;
        // Create common test case
        Case cas = new Case(Status = 'New',Origin='Chat',ContactId = con.Id);
        insert cas;
        // Create common test LiveChatVisitor
        /*LiveChatVisitor livechatvisitor = new LiveChatVisitor();
        insert livechatvisitor;
        // Create common test LiveChatTranscript
        LiveChatTranscript livchattrans = new LiveChatTranscript(ContactId = con.Id,LiveChatVisitorId = livechatvisitor.Id);
        insert livchattrans;*/
        String routableId = NF_UtilTest.insertMessagingSessionWithContact(con.Id);
    }

    /**
    * @name getCustomSettingsInfoTest
    *@description test method for getCustomSettingsInfo class method
    */
    @IsTest
    static void getCustomSettingsInfoTest(){

        Test.startTest();
            String res = NF_OrderHistoryController.getCustomSettingsInfo();
            System.assertNotEquals(null,res, 'should have value');

            List<LBrandsAPI__c> lbAPIList = [ SELECT Id FROM LBrandsAPI__c ];
            delete lbAPIList;
            res = NF_OrderHistoryController.getCustomSettingsInfo();
            System.assertEquals( null, res , 'should have value');
        Test.stopTest();
    }
    
    /**
    * @name orderByIdAndEmailTest
    *@description test method for orderByIdAndEmail class method
    */
    @IsTest
    static void orderByIdAndEmailTest(){

        Contact con = [ SELECT Id, Email FROM Contact LIMIT 1 ];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
            String res = NF_OrderHistoryController.orderByIdAndEmail( 'W008076351', con.Email );
            System.assertNotEquals( null, res , 'should have value');
        	String res1 = NF_OrderHistoryController.orderByIdAndEmail( '', 'abc');
            System.assertNotEquals( null, res1 , 'should have value');
        Test.stopTest();
    }

    /**
    * @name getEmailTest
    *@description test method for getEmail class method
    */
    @IsTest
    static void getEmailTest(){
        Test.startTest();
            Account acct = [SELECT Id,PersonEmail FROM Account LIMIT 1];
            String acctEmail =  NF_OrderHistoryController.getEmail(acct.Id);
            System.assertEquals(acctEmail, acct.PersonEmail, 'should have correct email');
            Contact con = [SELECT Id,Email FROM Contact LIMIT 1];
            String conEmail = NF_OrderHistoryController.getEmail(con.Id);
            System.assertEquals(conEmail, con.Email, 'should have correct email');
            Case cas = [SELECT Id,Contact.Email FROM Case LIMIT 1];
            String caseEmail = NF_OrderHistoryController.getEmail(cas.Id);
            System.assertEquals(caseEmail, cas.Contact.Email, 'should have correct email');
            MessagingSession livech = [SELECT Id,EndUserContact.Email FROM MessagingSession LIMIT 1];
            String liveChatEmail = NF_OrderHistoryController.getEmail(livech.Id);
            System.assertEquals(liveChatEmail, livech.EndUserContact.Email, 'should have correct email');
        Test.stopTest();
    }
    
    /**
    * @name searchOrderTest
    *@description test method for searchOrder class method
    */
    @IsTest
    static void searchOrderTest(){

        Contact con = [ SELECT Id, Email FROM Contact LIMIT 1 ];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
            String res = NF_OrderHistoryController.searchOrder('123@gmail.com');
            System.assertNotEquals( null, res, 'should have value' );
        Test.stopTest();
    }
    
     @IsTest
    static void searchOrderTest2(){

        Contact con = [ SELECT Id, Email FROM Contact LIMIT 1 ];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NF_OrderMockAPI());
            String res = NF_OrderHistoryController.searchOrder('1234@gmail.com');
            System.assertNotEquals( null, res, 'should have value' );
        Test.stopTest();
    }
}