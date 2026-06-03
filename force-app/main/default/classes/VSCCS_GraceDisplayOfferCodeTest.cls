@isTest
public class VSCCS_GraceDisplayOfferCodeTest {

    @isTest
    public static void testDisplayOfferCode(){
        List<VSCCS_GraceDisplayOfferCode.Input> inputList = new List<VSCCS_GraceDisplayOfferCode.Input>();
        VSCCS_GraceDisplayOfferCode.Input inp = new VSCCS_GraceDisplayOfferCode.Input();
        inp.digitalDisclaimer = 'test disclaimer';
        inp.gwpItemNumber = 'ABCD';
        inp.liveOpsInfo = 'test liveOps Info';
        inp.offerCode = 'testOffer';
        inp.productExcludedText = 'test';
        inp.routableId = 'abc';
        inp.offerStartDate = '04-11-2025';
        inputList.add(inp);
        
        Test.startTest();
        List<String> resonse = VSCCS_GraceDisplayOfferCode.display(inputList);
        Test.stopTest();
    }
    
    @isTest
    public static void testDisplayOfferCode2(){
        List<VSCCS_GraceDisplayOfferCode.Input> inputList = new List<VSCCS_GraceDisplayOfferCode.Input>();
        VSCCS_GraceDisplayOfferCode.Input inp = new VSCCS_GraceDisplayOfferCode.Input();
        inp.digitalDisclaimer = 'test disclaimer';
        inp.gwpItemNumber = 'ABCD';
        inp.liveOpsInfo = 'test liveOps Info';
        inp.offerCode = 'testOffer';
        inp.productExcludedText = 'test';
        inp.routableId = 'abc';
        inp.offerStartDate = '04-11-2025';
        inp.offerExpiryDate = '05-11-2025';
        inputList.add(inp);
        
        Test.startTest();
        List<String> resonse = VSCCS_GraceDisplayOfferCode.display(inputList);
        Test.stopTest();
    }
}