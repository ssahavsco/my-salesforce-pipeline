/*
***********************************************************************************************************
* Program Name      : NF_GetHoldPaymentResponse_Test
* Description       : test class for NF_GetHoldPaymentResponse
* Version           : 1.1
* Modification Log  : 26-08-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-39921    1.1         Ravikant Kedia      26-08-2021      test class for NF_GetHoldPaymentResponse
***********************************************************************************************************
*/
@isTest
public class NF_GetHoldPaymentResponse_Test {

    @isTest
    public static void returnPaymentStatusResponseTest(){
        Test.startTest();
            NF_GetHoldPaymentResponse.hpsrMDTList = hpsrMDTListTest;
            // Found
            NF_GetHoldPaymentResponse.ChatBotInput cbi = new NF_GetHoldPaymentResponse.ChatBotInput();
            cbi.holdType = 'Test Hold Type';
        	cbi.languageCode = 'en_US';
            List<NF_GetHoldPaymentResponse.ChatBotOutput> cboList = NF_GetHoldPaymentResponse.returnPaymentStatusResponse( new List<NF_GetHoldPaymentResponse.ChatBotInput>{ cbi } );
            System.assertEquals( 1, cboList[0].holdTypeId );
            System.assertEquals( 'Test Associate', cboList[0].messageForAssociate );

            // Not found
            cbi.holdType = 'Empty';
            cboList = NF_GetHoldPaymentResponse.returnPaymentStatusResponse( new List<NF_GetHoldPaymentResponse.ChatBotInput>{ cbi } );
            System.assert( cboList.isEmpty() );
        Test.stopTest();
    }

    @isTest
    public static void mdtCoverageTest(){
        Test.startTest();
            System.assert( NF_GetHoldPaymentResponse.hpsrMDTList != null );
        Test.stopTest();
    }
    
        
    // Test record for Hold_Payment_Status_Responses__mdt, such that the code is not dependent on MDT records in org
    private static List<Hold_Payment_Status_Responses__mdt> hpsrMDTListTest {
        get{
            return ( new List<Hold_Payment_Status_Responses__mdt>{
                ( Hold_Payment_Status_Responses__mdt ) JSON.deserialize(
                    '{"Hold_Payment_ChatBot_Responses__c":"12345678i","ChatBot_Response_To_Customer__c": "Test Response", "Hold_Type__c": "Test Hold Type_en_US", "Hold_Type_Id__c": 1, "Message_for_Associate__c": "Test Associate"}',
                    Hold_Payment_Status_Responses__mdt.class
                )
            } );
        }
        private set;
    }
}