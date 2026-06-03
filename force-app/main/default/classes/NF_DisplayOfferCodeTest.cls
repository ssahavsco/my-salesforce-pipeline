/**
 * Created by adamundus on 9/25/20.
 */

@IsTest
private class NF_DisplayOfferCodeTest {
  static String chatKey = 'abc';

  //   @TestSetup
  //   static void setup() {
  //     NF_UtilTest.insertBotSession(chatKey);
  //   }

  @IsTest
  static void testBehavior() {
    List<NF_DisplayOfferCode.Input> inputs = new List<NF_DisplayOfferCode.Input>();
    NF_DisplayOfferCode.Input inp = new NF_DisplayOfferCode.Input();
    inp.offerCode = 'abc';
    inp.chatKey = chatKey;
    inp.digitalDisclaimer = 'be careful';

    inputs.add(inp);

    Test.startTest();
    NF_DisplayOfferCode.display(inputs);
    Test.stopTest();

    // Object cardJson = JSON.deserializeUntyped(NF_Util.getBotSession(chatKey).CarouselContent__c);

    // System.assertNotEquals(null, cardJson);
  }
}