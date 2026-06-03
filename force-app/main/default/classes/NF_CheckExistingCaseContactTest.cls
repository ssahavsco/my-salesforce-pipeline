/**
 * Created by adamundus on 9/14/20.  
 */

@IsTest
private class NF_CheckExistingCaseContactTest {

    static String chatkey = 'abc';
    static String email = 'adam@nf.com';
    static String caseNum = '12345';

    @TestSetup
    static void setup(){
        Account acct = new Account();
        acct.PersonEmail = email;
        acct.Type = 'Personal';
        acct.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account'].Id;

        String lastName = 'User';
        acct.LastName = lastName;
        insert acct;
        Id accoutPersonContactId = [SELECT Id, PersonContactId FROM Account WHERE LastName = :lastName LIMIT 1].PersonContactId;
        Case c = new Case();
        c.ContactId = accoutPersonContactId;
        c.Status = 'Open';
        insert c;
    }

    @IsTest
    static void testBehavior() {
        List<NF_CheckExistingCaseContact.Input> inputs = new List<NF_CheckExistingCaseContact.Input>();
        NF_CheckExistingCaseContact.Input inp = new NF_CheckExistingCaseContact.Input();
        inp.routableId = NF_UtilTest.createMessagingSession();
        inp.userEmail = email;
        inputs.add(inp);
        Test.startTest();
        List<NF_CheckExistingCaseContact.Output> out = NF_CheckExistingCaseContact.getExistingInfo(inputs);
        Test.stopTest();

        System.assertEquals(true, out[0].isContactExists, 'Should be true');
    }
}