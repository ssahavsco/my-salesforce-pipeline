/**
 * Created by adamundus on 9/15/20.
 * Modified By - Himanshu Mishra - 02/28/2025
 * Accomodate MIAW changes
 */

@IsTest
private class NF_CreateCustomerForBotTest {
  static String routableId;

  @IsTest
  static void testBehavior() {
    routableId = NF_UtilTest.createMessagingSession();
    List<NF_CreateCustomerForBot.Input> inputs = new List<NF_CreateCustomerForBot.Input>();
    NF_CreateCustomerForBot.Input inp = new NF_CreateCustomerForBot.Input();
    inp.routableId = routableId;
    inp.fullName = 'Test';
    inp.emailId = 'test@ab.com';
    inputs.add(inp);

    Test.startTest();
    List<NF_CreateCustomerForBot.Output> out = NF_CreateCustomerForBot.createCustomer(
      inputs
    );
    Test.stopTest();

    MessagingSession msgSession = NF_Util.getMessagingSession(routableId);
    ID transcContactId = [
      SELECT ID, EndUserContactId
      FROM MessagingSession
      WHERE Id = :msgSession.Id
    ]
    .EndUserContactId;
    System.assertEquals(
      out[0].insertedContactId,
      transcContactId,
      'should have correct id'
    );

    Contact c = [
      SELECT Id, FirstName, LastName, Name
      FROM Contact
      WHERE Id = :out[0].insertedContactId
    ];
    System.debug(LoggingLevel.DEBUG, 'inserted contact=' + c);
  }
}