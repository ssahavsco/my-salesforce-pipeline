@isTest
private class NF_SelectedOrderValidationTest {
    @isTest
    static void createTestData(){
        NF_OrderServiceN.ListOfOrderResponse order = new NF_OrderServiceN.ListOfOrderResponse();
        order.orderPlaceholder1 = 'Ask ';
        order.orderPlaceholder2 = 'something ';
        order.orderPlaceholder3 = 'else';
        String chatKey = 'abc';
        List<NF_SelectedOrderValidation.Input> inputList = new List<NF_SelectedOrderValidation.Input>();
        NF_SelectedOrderValidation.Input input = new NF_SelectedOrderValidation.Input();
        input.chatKey = chatKey;
        input.order = order;
        inputList.add(input);
        List<NF_SelectedOrderValidation.Output> isValidSelection = NF_SelectedOrderValidation.orderSelectionValidation(inputList);
        System.assertEquals(true, isValidSelection[0].isOrderValid, 'should have value');
    }
    @IsTest
    static void test2(){
        NF_OrderServiceN.ListOfOrderResponse order = new NF_OrderServiceN.ListOfOrderResponse();
        order.orderPlaceholder1 = null;
        order.orderPlaceholder2 = null;
        order.orderPlaceholder3 = null;
        String chatKey = 'abc';
        List<NF_SelectedOrderValidation.Input> inputList = new List<NF_SelectedOrderValidation.Input>();
        NF_SelectedOrderValidation.Input input = new NF_SelectedOrderValidation.Input();
        input.chatKey = chatKey;
        input.order = order;
        inputList.add(input);
        List<NF_SelectedOrderValidation.Output> isValidSelection = NF_SelectedOrderValidation.orderSelectionValidation(inputList);
        System.assertEquals(false, isValidSelection[0].isOrderValid, 'should have value');
    }

}