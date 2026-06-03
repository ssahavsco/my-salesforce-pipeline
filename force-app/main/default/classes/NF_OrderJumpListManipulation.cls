public with sharing class NF_OrderJumpListManipulation {
    public class Input{

        @InvocableVariable(required=false)
        public String serializedOrders;
    }

    public class Output{

        @InvocableVariable
        public List<NF_OrderServiceN.ListOfOrderResponse> listOfOrders = new List<NF_OrderServiceN.ListOfOrderResponse>();
    }

    @InvocableMethod(label='Neuraflash - Get Updated Order List After Order Jump')
    public static List<Output> getManipulatedOrderList(List<Input> orderInputList) {
        List<Output> outputList = new List<Output>();
        Output out = new Output();
        try{
            List<NF_OrderServiceN.ListOfOrderResponse> outputOrderList = new List<NF_OrderServiceN.ListOfOrderResponse>();
            List<NF_OrderServiceN.ListOfOrderResponse> listOfOrders = (List<NF_OrderServiceN.ListOfOrderResponse>) JSON.deserialize(orderInputList[0].serializedOrders, List<NF_OrderServiceN.ListOfOrderResponse>.class);
            outputOrderList = listOfOrders;
            outputOrderList.remove(outputOrderList.size()-1);
            NF_OrderServiceN.ListOfOrderResponse eachOrder = new NF_OrderServiceN.ListOfOrderResponse();
            eachOrder.orderPlaceholder1 = 'Check a ';
            eachOrder.orderPlaceholder2 = 'different ';
            eachOrder.orderPlaceholder3 = 'order';
            outputOrderList.add(eachOrder);
            out.listOfOrders = outputOrderList;
            System.debug(LoggingLevel.DEBUG, 'outputOrderList Size>>>'+outputOrderList.size());
            System.debug(LoggingLevel.DEBUG, 'outputOrderList>>>'+outputOrderList);
            outputList.add(out);

        }catch(Exception e) {
            System.debug(LoggingLevel.DEBUG, 'NF_OrderJumpListManipulation: exception= Line ('+e.getLineNumber()+'): '+e.getMessage());
        }
        return outputList;
    }
}