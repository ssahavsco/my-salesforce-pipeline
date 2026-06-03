/****************************************************************************************************************
* Program Name         : BitlyUtility_Test
* Description          : Test class for BitlyUtility 
* Version              : 1.2
* Modification Log     : 24-Feb-2022 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   PK_01          DP-53595      1.1    Pooja Korrapati    24-Feb-2022    Test class for urlShortner  LWC
*****************************************************************************************************************/


@isTest(seeAllData = false)
public with sharing class BitlyUtility_Test {
     /**
    * @description Test method for bitlyUrlShortner Flow
    * @author Pooja Korrapati  
    **/
    public static testMethod void testBehavior() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpMock(
            200, 'OK', '{"plan_limits":[{"name":"encodes","limit":1000,"count":2}]}')
                    );
     
        List<BitlyUtility.FlowRequestWrapper> requestInputs = new    List<BitlyUtility.FlowRequestWrapper>();
        BitlyUtility.FlowRequestWrapper requestInput = new   BitlyUtility.FlowRequestWrapper();
        requestInput.caseNumber = '00310002';
        requestInput.sourceType = 'PayByLink';
        requestInput.urlToShorten = 'http://google.com';
        requestInputs.add(requestInput);
        BitlyUtility.bitlyUrlShortner(requestInputs);
        Test.stopTest();
    }
    
    /**
    * @description Setup Data for test class
    * @author Pooja Korrapati  | 04-22-2021
    **/
    @TestSetup
    static void makeData(){
        
        String recordTypeIdPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(
            RecordTypeId = recordTypeIdPA,
            FirstName    = 'Test',
            LastName     = 'Account'
        );
        insert testAccount;
        
        RecordType recType = [ SELECT Id FROM RecordType WHERE sObjectType = 'Case' LIMIT 1 ];
        Case testCase = new Case(
            RecordTypeId = recType.Id,
            AccountId = testAccount.Id
        );
        
        insert testCase;
        // Create common test contact
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com');
        insert con;
        
        
        LiveChatVisitor livechatvisitor = new LiveChatVisitor();
        insert livechatvisitor;
        // Create common test LiveChatTranscript
        LiveChatTranscript livchattrans = new LiveChatTranscript(ContactId = con.Id,LiveChatVisitorId = livechatvisitor.Id, caseID=testCase.id);
        insert livchattrans;
        LiveChatTranscript liveChat = [SELECT Id,Contact.Email FROM LiveChatTranscript LIMIT 1];
        system.debug('liveChat'+liveChat);
        insert new Support_Time_Threshold__c(Name = 'VS');
    }
        
    /**
    * @description Test method for bitlyUrlShortner
    * @author Pooja Korrapati  
    **/
    public static testMethod void generateShortURLTest(){
        Test.startTest();
        
        Case case1 = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        LiveChatTranscript liveChat = [SELECT Id,Contact.Email FROM LiveChatTranscript LIMIT 1];
        system.debug('liveChat'+liveChat);
        
        Test.setMock(HttpCalloutMock.class, new TestHttpMock(
            200, 'OK', '{"plan_limits":[{"name":"encodes","limit":1000,"count":2}]}')
                    );
        
        BitlyUtility.bitlyUrlShortner(String.ValueOf(liveChat.Id),'https://login.salesforce.com', 'ChatUI');
        
        System.assertEquals(
            null, BitlyUtility.bitlyUrlShortner(
                null, null, null
            ), 'Null Response'
        );
        
        Test.stopTest();
    } 
    
}