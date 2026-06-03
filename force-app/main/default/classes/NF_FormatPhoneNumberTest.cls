/**
 * Created by adamundus on 10/1/20.
 */

@IsTest
private class NF_FormatPhoneNumberTest {
    @IsTest
    static void testvalid() {
        List<NF_FormatPhoneNumber.Input> inputs = new List<NF_FormatPhoneNumber.Input>();
        NF_FormatPhoneNumber.Input inp = new NF_FormatPhoneNumber.Input();
        inp.phoneNumber = '+1 201-123-4567';
        inputs.add(inp);

        Test.startTest();
        List<NF_FormatPhoneNumber.Output> out = NF_FormatPhoneNumber.formatPhoneNumber(inputs);
        Test.stopTest();

        System.assertEquals('2011234567', out[0].formattedNumber, 'should have correct number');
    }

    @IsTest
    static void testInalid() {
        List<NF_FormatPhoneNumber.Input> inputs = new List<NF_FormatPhoneNumber.Input>();
        NF_FormatPhoneNumber.Input inp = new NF_FormatPhoneNumber.Input();
        inp.phoneNumber = 'I DON\'T KNOW IT';
        inputs.add(inp);

        Test.startTest();
        List<NF_FormatPhoneNumber.Output> out = NF_FormatPhoneNumber.formatPhoneNumber(inputs);
        Test.stopTest();

        System.assertEquals('', out[0].formattedNumber, 'should have blank');
    }
}