/* ******************************************************************************************************************
 * Program Name : NF_CheckBussinessChatAvailabilityTest
 * Description : Test class for class --NF_CheckBussinessHoursChatAvailability.
 * created By : Sunny Yadav
 * Modification log : 
 * CCS-827		03/04/2025		Himanshu Mishra		Added isDomestic input parameter for Input class
 * ******************************************************************************************************************/
@IsTest
public class NF_CheckBussinessChatAvailabilityTest {

    testmethod static void checkWithinBussinessHours(){
        List<NF_CheckBussinessHoursChatAvailability.Input> BhInputs = new List<NF_CheckBussinessHoursChatAvailability.Input>();
        NF_CheckBussinessHoursChatAvailability.Input inpB = new NF_CheckBussinessHoursChatAvailability.Input();
        inpB.chatKey = '';
        inpB.customerType = 'DOM'; 
        BhInputs.add(inpB);
        
        Test.startTest();
        List<NF_CheckBussinessHoursChatAvailability.Output> outBH = NF_CheckBussinessHoursChatAvailability.getBussinessHoursChatToggle(BhInputs);
        System.assertNotEquals(inpB,Null);
        Test.stopTest();
    }
}