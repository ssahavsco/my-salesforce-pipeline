public with sharing class NF_SelectedOrderValidation {
    public class Input{
        @InvocableVariable(required=false)
        public String chatKey;

        @InvocableVariable
        public NF_OrderServiceN.ListOfOrderResponse order;
    }

    public class Output {
        @InvocableVariable
        public String OrderNumber;

        @InvocableVariable
        public Boolean isOrderValid;
    }

    @InvocableMethod(label='Neuraflash - Selected Order Validation')
    public static List<Output> orderSelectionValidation(List<Input> input) {
        Output out = new Output();
        List<Output> outputs = new List<NF_SelectedOrderValidation.Output>();
        out.isOrderValid = false;
        try{
            if(input[0].order != null) {
                System.debug(LoggingLevel.DEBUG,'input[0].order>>>>'+input[0].order);
                System.debug(LoggingLevel.DEBUG,'input[0].order total>>>>'+input[0].order.orderPlaceholder1);
                System.debug(LoggingLevel.DEBUG,'input[0].orderplaceholder>>>>'+input[0].order.orderPlaceholder2);
                System.debug(LoggingLevel.DEBUG,'input[0].orderdate>>>>'+input[0].order.orderPlaceholder3);
                System.debug(LoggingLevel.DEBUG,'input[0].orderdateString>>>>'+String.valueOf(input[0].order.orderPlaceholder3));
                out.OrderNumber = input[0].order.orderNumber;
                if(input[0].order.orderPlaceholder1 != null && input[0].order.orderPlaceholder2 != null && input[0].order.orderPlaceholder3 != null) {
                    String orderValue = input[0].order.orderPlaceholder1 + input[0].order.orderPlaceholder2 + input[0].order.orderPlaceholder3;
                    System.debug(LoggingLevel.DEBUG,'orderValue>>>'+orderValue);
                    if (orderValue.contains('see my order') || orderValue == 'Ask something else' || orderValue == 'Check a different order') {
                        out.isOrderValid = true;
                    }
                    
                }

            }
            System.debug(LoggingLevel.DEBUG,'orderSelectionValidation >> returning '+ out);
            outputs.add(out);
            return outputs;
        }catch(Exception e) {
            System.debug(LoggingLevel.DEBUG,'Exception caught>>>'+e.getStackTraceString() + e.getMessage());
            return outputs;
        }

    }

}