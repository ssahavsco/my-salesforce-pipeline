/**
 * Created by mcasella on 9/25/20.
 */

@IsTest
public with sharing class NF_ValidateEmailTest {

    @IsTest
    static void testValidEmails(){
        List<String> validInputs = new List<String>{ 'test@neuraflash.com' };

        NF_ValidateEmail.Input input = new NF_ValidateEmail.Input();
        for(String valid : validInputs){
            input.inputEmailAddress = valid;
            List<NF_ValidateEmail.Output> outputs = NF_ValidateEmail.validateEmailAddress(new List<NF_ValidateEmail.Input>{input});
            System.assertEquals(true, outputs[0].isEmailValid, 'should be true');
        }
    }

    @IsTest
    static void testInvalidEmails(){
        List<String> invalidInputs = new List<String>{'blah blah blah', '', 'null', 'i dont have an email'};

        NF_ValidateEmail.Input input = new NF_ValidateEmail.Input();
        for(String invalid : invalidInputs){
            input.inputEmailAddress = invalid;
            List<NF_ValidateEmail.Output> outputs = NF_ValidateEmail.validateEmailAddress(new List<NF_ValidateEmail.Input>{input});
            System.assertEquals(false, outputs[0].isEmailValid, 'should have false value');
        }
    }
    
    @IsTest
    static void testValidEmailSentence(){
        List<String> validInputs = new List<String>{ ' my email is test@neuraflash.com' }; //LBRAN-44 'my email is test@nf.com'

        NF_ValidateEmail.Input input = new NF_ValidateEmail.Input();
        for(String valid : validInputs){
            input.inputEmailAddress = valid;
            List<NF_ValidateEmail.Output> outputs = NF_ValidateEmail.validateEmailAddress(new List<NF_ValidateEmail.Input>{input});
            System.assertEquals(true, outputs[0].isEmailValid, 'should have true value');
        }
    }
}