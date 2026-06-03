/* ******************************************************************************************************************
 * Program Name : NF_CustomerCareNumberInfoTest
 * Description : Test class for Controller class --NF_CustomerCareNumberInfo.
 * created By : Sunny Yadav
 * Modification log : 
 * ******************************************************************************************************************/ 
@IsTest
public class NF_CustomerCareNumberInfoTest {

    testMethod static void testGetLabelMethod(){
        List<NF_CustomerCareNumberInfo.Input> custCareInputList = new List<NF_CustomerCareNumberInfo.Input>();
        NF_CustomerCareNumberInfo.Input custCareInput = new NF_CustomerCareNumberInfo.Input();
        custCareInput.chatKey = '';
        custCareInputList.add(custCareInput);
        Test.startTest();
        List<NF_CustomerCareNumberInfo.Output> custCareOutputList = NF_CustomerCareNumberInfo.getCustomerCareNumberInformation(custCareInputList);
        system.assertNotEquals(custCareOutputList, Null);
        Test.stopTest();
        
    }
}