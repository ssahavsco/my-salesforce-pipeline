@IsTest
public with sharing class NF_ValidateOrderNumberTest {

    @IsTest
    static void testValidOrderNumbers(){
        List<String> validInputs = new List<String>{ 'C123456789' };

        NF_ValidateOrderNumber.Input input = new NF_ValidateOrderNumber.Input();
        for(String valid : validInputs){
            input.inputOrderNumber = valid;
            List<NF_ValidateOrderNumber.Output> outputs = NF_ValidateOrderNumber.validateOrderNumber(new List<NF_ValidateOrderNumber.Input>{input});
            System.assertEquals(true, outputs[0].isOrderNumberValid, 'should have true value');
        }
    }

    @IsTest
    static void testInvalidOrders(){
        List<String> invalidInputs = new List<String>{'W12345', '', 'null', 'i dont have an email'};

        NF_ValidateOrderNumber.Input input = new NF_ValidateOrderNumber.Input();
        for(String invalid : invalidInputs){
            input.inputOrderNumber = invalid;
            List<NF_ValidateOrderNumber.Output> outputs = NF_ValidateOrderNumber.validateOrderNumber(new List<NF_ValidateOrderNumber.Input>{input});
            System.assertEquals(false, outputs[0].isOrderNumberValid, 'should have false value');
        }
    }
    
    @IsTest
    static void testValidOrderSentence(){
        List<String> validInputs = new List<String>{ ' my order number is W123456789'}; //LBRAN-44 'my email is test@nf.com'

        NF_ValidateOrderNumber.Input input = new NF_ValidateOrderNumber.Input();
        for(String valid : validInputs){
            input.inputOrderNumber = valid;
            List<NF_ValidateOrderNumber.Output> outputs = NF_ValidateOrderNumber.validateOrderNumber(new List<NF_ValidateOrderNumber.Input>{input});
            System.assertEquals(false, outputs[0].isOrderNumberValid, 'should have true value');
        }
    }
}