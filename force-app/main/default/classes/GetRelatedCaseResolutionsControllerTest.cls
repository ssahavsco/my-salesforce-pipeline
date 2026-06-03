@isTest
public class GetRelatedCaseResolutionsControllerTest {
	@testSetup static void setup() {
        // Create common test case and case resoltuions
        Case sampleCase = new Case();
        sampleCase.Origin = 'Phone';
        insert sampleCase;
        
        Case_Resolution__c crObj = new Case_Resolution__c();
        crObj.Related_Case__c = sampleCase.Id;
        crObj.Store_Number_Text__c = 'Test Store 098761';
        crObj.Case_Resolution_Type__c = 'BOPIS';
        
        insert crObj;
        
        Case caseObj = new Case();
        caseObj.Origin = 'Phone';
        insert caseObj;
        
        Case_Resolution__c crObj2 = new Case_Resolution__c();
        crObj2.Related_Case__c = caseObj.Id;
        crObj2.Store_Number_Text__c = 'Test Store 098762';
        crObj2.Case_Resolution_Type__c = 'Issue Gift Card';
        crObj2.Requested_Gift_Card_Type__c = 'Electronic Gift Card';
        crObj2.Amount__c = 10;
        insert crObj2;

        Gift_Card_Request__c gfCard = new Gift_Card_Request__c();
        gfCard.Recipient_Email__c = 'testuser@testing.com';
        gfCard.Recipient_First_Name__c = 'testUserFirstName';
        gfCard.Recipient_Last_Name__c = 'testUseLastName';
        gfCard.Case_Resolution__c = crObj2.Id;
        insert gfCard;
    }
    public static testMethod void successMethod(){
        Test.startTest();
        List<Case_Resolution__c> crList = GetRelatedCaseResolutionsController.retrieveCRs('500U8000004N9A6IAK');
        
        List<Case_Resolution__c> crLists = [Select Id From Case_Resolution__c where Store_Number_Text__c = 'Test Store 098761'];
        Boolean isCRCancelled = GetRelatedCaseResolutionsController.cancelCRs(crLists[0].Id);
        System.debug('Is Cancelled '+isCRCancelled);
        Test.stopTest();
    }
    
    public static testMethod void successMethodForMsgSession(){
        Test.startTest();
        Case caseObj = [Select Id From Case Limit 1];
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [Select CaseId From MessagingSession Where Id =: routableId];
        msgSession.CaseId = caseObj.Id;
        Update msgSession;
        List<Case_Resolution__c> crList = GetRelatedCaseResolutionsController.retrieveCRs(routableId);
        
        List<Case_Resolution__c> crLists = [Select Id From Case_Resolution__c where Store_Number_Text__c = 'Test Store 098761'];
        Boolean isCRCancelled = GetRelatedCaseResolutionsController.cancelCRs(crLists[0].Id);
        System.debug('Is Cancelled '+isCRCancelled);
        Test.stopTest();
    }
    
    public static testMethod void giftCardCancellation(){
        Test.startTest();
        List<Case_Resolution__c> crLists = [Select Id From Case_Resolution__c where Case_Resolution_Type__c = 'Issue Gift Card'];
        //System.debug('Is Cancelled '+isCRCancelled);
        Test.setMock(HttpCalloutMock.class, new AOOrderCancellationControllerMock());
        	AOOrderCancellationController.endPointMetaData = lbAPIIntegSettingsMapActiveTest;
        	AOOrderCancellationService.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
        	List<AOOrderCancellationController.ChatBotInput> cbInputList = new List<AOOrderCancellationController.ChatBotInput>();
        	List<AOOrderCancellationController.ChatBotOutput> result = new List<AOOrderCancellationController.ChatBotOutput>();
        	
        	AOOrderCancellationController.ChatBotInput cbInput = new AOOrderCancellationController.ChatBotInput();
        	cbInput.orderId = 'Order200';
        	cbInput.reasonId = 'Customer Request';
        	cbInput.cancelComments = 'Cancelled by Case Resolution';
        
        	cbInputList.add(cbInput);
            try{
                Boolean isCRCancelled = GetRelatedCaseResolutionsController.cancelCRs(crLists[0].Id);
            } catch(Exception e){
                System.assert(e.getMessage().contains('Error'), 'Exception' + e);
            }
        	//result = AOOrderCancellationController.cancelOrder( cbInputList );
            //System.assertEquals( true, result[0].result );
        Test.stopTest();
    }
    
    private static void testSetupData() {
        LBrandsAPI__c testLBrandsAPI = new LBrandsAPI__c(
            Order_Endpoint__c      = 'authenticationEndpoint',
            Host__c                = 'Host',
            AO_Authorization_Code__c = 'Basic abcd',
            Origin__c = 'Origin',
            AO_Access_Token_1__c = 'Invalid_Token'
        );
        insert testLBrandsAPI;
    }
    
    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapActiveTest {
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'AO_Order_Cancellation' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "Cancel_Order", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                ),
               	'AO_Authorization_Endpoint' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : true, "Endpoint__c" : "Auth_Access_Token", "Request_Method__c" : "POST", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }',
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}

    private static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMapInactiveTest {
		get {
			return new Map<String, LBrands_API_Integration_Setting__mdt>{
				'AO_Order_Cancellation' => ( LBrands_API_Integration_Setting__mdt ) JSON.deserialize(
                    '{ "Active__c" : false, "Endpoint__c" : "Cancel_Order", "Status_Code_200_Message__c" : "Request submit", "Status_Code_500_Message__c" : "server is down", "Status_Code_400_Message__c" : "server is down", "Status_Code_404_Message__c" : "server is down", "Status_Code_503_Message__c" : "server is down" }', 
                    LBrands_API_Integration_Setting__mdt.class 
                )
			};
		}
		private set;
	}
}