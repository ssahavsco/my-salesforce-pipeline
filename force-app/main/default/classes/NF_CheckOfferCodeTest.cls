/**
 * Created by adamundus on 9/21/20.
 */

@IsTest
private class NF_CheckOfferCodeTest {
    static String oc = 'testoffer';
    static String disclaimer = 'The cost of your qualifying item(s) will be adjusted after code is applied.';

    @TestSetup
    static void setup(){
        KOD__c testProm = new KOD__c();
        testProm.Site_Exposure_Start__c = Datetime.now() - 1000;
        testProm.System_Expiration__c = Datetime.now() + 10000;
        testProm.Offer_Code__c = oc;
        testProm.Digital_Offer_Disclaimer__c = disclaimer;
        insert testProm;
        
        KOD__c singleUseCode = new KOD__c();
        singleUseCode.Site_Exposure_Start__c = Datetime.now() - 1000;
        singleUseCode.System_Expiration__c = Datetime.now() + 10000;
        singleUseCode.Offer_Code__c = '1234567890cg';
        singleUseCode.Single_Use_Offer_Code__c = true;
        singleUseCode.Digital_Offer_Disclaimer__c = disclaimer;
        singleUseCode.Disclaimer__c = 'Test offer Disclaimer';
        insert singleUseCode;
    }
    @IsTest
    static void testBehavior() {
        setup();
        List<NF_CheckOfferCode.Input> inputs = new List<NF_CheckOfferCode.Input>();
        NF_CheckOfferCode.Input inp = new NF_CheckOfferCode.Input();
        inp.offerCode = oc;
        inp.chatKey = 'abc';
        inputs.add(inp);

        Test.startTest();
        List<NF_CheckOfferCode.Output> out = NF_CheckOfferCode.checkCode(inputs);
        Test.stopTest();

        System.assertEquals(true, out[0].offerFound, 'Should be true value');
        System.assertEquals(true, out[0].offerStarted, 'Should have true value');
        System.assertEquals(false, out[0].isExpired, 'Should have true value');
    }
    
    @IsTest
    static void testSingleUseCode() {
        setup();
        List<NF_CheckOfferCode.Input> inputs = new List<NF_CheckOfferCode.Input>();
        NF_CheckOfferCode.Input inp = new NF_CheckOfferCode.Input();
        inp.offerCode = '1234567890';
        inp.chatKey = 'abc';
        inputs.add(inp);

        Test.startTest();
        List<NF_CheckOfferCode.Output> out = NF_CheckOfferCode.checkCode(inputs);
        Test.stopTest();

        System.assertEquals(true, out[0].offerFound, 'Should be true value');
        System.assertEquals(true, out[0].offerStarted, 'Should have true value');
        System.assertEquals(false, out[0].isExpired, 'Should have true value');
    }
}