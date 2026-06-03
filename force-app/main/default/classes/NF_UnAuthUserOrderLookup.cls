/*****************************************************************************************************@@
Class Name     :  NF_UnAuthUserOrderLookup
Purpose        :  Class to serialize order api response for unauth customer.(used by chatbot)
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      	TICKET REFERENCE/ NO.
1.       apoorv                08/28/2020             Original Version             			-
2.       apoorv                10/1/2020             LBRAN-64             					LBRAN-64
3.       Manishi               09/03/2021            Adding new api paramters               DP-39915

@Testsuite:  {NF_UnAuthUserOrderLookupTest}        
*********************************************************************************************************/
public with sharing class NF_UnAuthUserOrderLookup {

    public class Input{
        @InvocableVariable(required=true)
        public String chatKey;

        @InvocableVariable(required=true)
        public String email;

        @InvocableVariable(required=true)
        public String orderId;

        @InvocableVariable(required=false)
        public String zipCode;

        @InvocableVariable(required=false)
        public String phoneNumber;

        @InvocableVariable
        public Boolean isOrderNumberPresent;
    }

    public class Output{
        @invocableVariable
        public Integer returnCode;

        @InvocableVariable
        public String failReason;

        @InvocableVariable
        public NF_OrderServiceN.OrderResponse order = new NF_OrderServiceN.OrderResponse();

        @InvocableVariable
        public Integer orderResponseSize = 0;

        @InvocableVariable
        public String serializedString;

        @InvocableVariable
        public List<NF_OrderServiceN.ListOfOrderResponse> listOfOrders = new List<NF_OrderServiceN.ListOfOrderResponse>();

        @InvocableVariable
        public Boolean isOrderInRemorse;
        
         /* DP-39915 adding new api parameters starts */
        @InvocableVariable
        public Boolean isOnHold;
        
        @InvocableVariable
        public Boolean isCancelEligible;
        
        @InvocableVariable
        public Boolean isModifyEligible;
        
        @InvocableVariable
        public String holdType;
        
        @InvocableVariable
        public Boolean isAwaitingPaymentProcess;
         /* DP-39915 adding new api parameters ends */
    }

    @InvocableMethod(label='Neuraflash - Get Order details for Un Authenticated User')
    public static List<Output> getOrderDetailsForUnAuthenticatedUser(List<Input> input){

        // 1. get  the order id from input.
        String chatkey = input[0].chatKey;
        String email   = input[0].email;
        String orderId = input[0].orderId;
        String zipCode = input[0].zipCode;
        String phoneNumber = input[0].phoneNumber;
        List<Output> outputs = new List<Output>();
        Output output = new Output();
        String noOrdersFoundString = 'Please re-enter the information';

        if(input[0].isOrderNumberPresent == true) {
            System.debug(LoggingLevel.DEBUG,'NF_UnAuthUserOrderLookup: order number is present');
            if (String.isBlank(orderId) || String.isBlank(email)) {
                String err = 'EMail or orderId was null. Lookup cannot be performed';
                System.debug(LoggingLevel.ERROR, err);
                return null;
            }
            NF_OrderHistoryAPI.chatKey = chatkey;
            NF_OrderServiceN.APIResponse apiResponse = NF_OrderHistoryAPI.orderByIdAndEmail(orderId,email,false);
            System.debug('apiResponse>>>>'+JSON.serialize(apiResponse));
            NF_OrderHistoryAPI.chatKey = null;
            if(String.isNotBlank(apiResponse.responseError)) {
                if(apiResponse.responseError.contains(noOrdersFoundString)) {
                    output.failReason = 'NO_ORDERS_FOUND';
                }
                System.debug(LoggingLevel.INFO,'Lookup did not return any orders.');
                output.returnCode = -1;
            }
            else if (apiResponse.order != null){
                output.serializedString = JSON.serialize(apiResponse.order, false);
                output.order = apiResponse.order;
                output.orderResponseSize = 1;
                output.isOrderInRemorse = apiResponse.order.IsInRemorse();
                
                /* DP-39915 mapping new api parameters starts */
                output.isOnHold = apiResponse.order.isOnHold;
                output.isCancelEligible = apiResponse.order.isCancelEligible;
                output.isModifyEligible = apiResponse.order.isModifyEligible;
                output.holdType = apiResponse.order.holdTypeId;
                output.isAwaitingPaymentProcess = apiResponse.order.isAwaitingPaymentProcess;
                /* DP-39915 mapping new api parameters ends */
                
                System.debug(LoggingLevel.DEBUG, 'NF_UnAuthOrderLookup: output.order='+output.order);
            }
            outputs.add(output);
        }
        else {
            if (String.isBlank(phoneNumber) || String.isBlank(email) || String.isBlank(zipCode) ) {
                System.debug(LoggingLevel.ERROR,'EMail or phoneNumber or zipCode was null. Lookup cannot be performed');
                return null;
            }
            NF_OrderHistoryAPI.chatKey = chatkey;
            NF_OrderServiceN.APIResponse newApiResponse = NF_OrderHistoryAPI.searchOrder(email,phoneNumber,zipCode,false,5);
            NF_OrderHistoryAPI.chatKey = null;
            system.debug(newApiResponse);
            List<NF_OrderServiceN.ListOfOrderResponse> apiResponse = newApiResponse.orders;
            if(String.isNotBlank(newApiResponse.responseError)) {
                if(newApiResponse.responseError.contains(noOrdersFoundString)) {
                    output.failReason = 'NO_ORDERS_FOUND';
                }
                System.debug(LoggingLevel.INFO,'Lookup did not return any orders.');
                output.returnCode = -1;
            }else {
                Integer orderCount = 0;
                system.debug('NF_OrderServiceN.ListOfOrderResponse>>>'+apiResponse.size());
                for (NF_OrderServiceN.ListOfOrderResponse eachOrder : apiResponse) {
                    if (orderCount == 4) {
                        eachOrder.orderPlaceholder1 = 'I don\'t see ';
                        eachOrder.orderPlaceholder2 = 'my ';
                        eachOrder.orderPlaceholder3 = 'order';
                        output.listOfOrders.add(eachOrder);
                        break;
                    } else {
                        /* start of LBRAN-64 */
                        String[] orderDateArray = eachOrder.orderDate.split(',');
                        eachOrder.orderDate = orderDateArray[0].remove('.');
                        eachOrder.orderDate = eachOrder.orderDate.toUpperCase();
                        /* end of LBRAN-64 */
                        String[] orderDateTimeArray = eachOrder.orderDateTime.split('T');
                        Date convertedDate = Date.valueOf(orderDateTimeArray[0]);
                        Date todayDate = System.today();
                        if (convertedDate.daysBetween(todayDate) >= 0 && convertedDate.daysBetween(todayDate) < 90) {
                            orderCount = orderCount + 1;
                            output.listOfOrders.add(NF_OrderUtil.formatOrderForMenu(eachOrder));
                        }
                    }

                }
                System.debug(LoggingLevel.DEBUG, 'output.listOfOrders>>'+output.listOfOrders.size());
                if(output.listOfOrders.size() == 1) {
                    String orderStatus = output.listOfOrders.get(0).orderStatus;
                    System.debug(LoggingLevel.DEBUG,'NF_UnAuthUserOrderLookup: get single order details, orderStatus=[' + orderStatus + ']');

                    NF_OrderServiceN.APIResponse apiResponseSingle;
                    System.debug(LoggingLevel.DEBUG,'NF_UnAuthUserOrderLookup: get single order details, orderNumber=[' + output.listOfOrders.get(0).orderNumber + '], email=[' + input[0].email + ']');
                    NF_OrderHistoryAPI.chatKey = chatkey;
                    apiResponseSingle = NF_OrderHistoryAPI.orderByIdAndEmail(output.listOfOrders.get(0).orderNumber, input[0].email, false);
                    NF_OrderHistoryAPI.chatKey = null;
                    System.debug(LoggingLevel.DEBUG,'apiResponseSingle>>>' + apiResponseSingle);
                    System.debug(LoggingLevel.DEBUG,'apiResponseSingle.order>>>' + apiResponseSingle.order);
                    output.order = apiResponseSingle.order;
                    output.serializedString = JSON.serialize(output.order, false);
                    output.orderResponseSize = output.listOfOrders.size();
                    
                    /* DP-39915 mapping new api parameters starts */
                    output.isOnHold = apiResponseSingle.order.isOnHold;
                    output.isCancelEligible = apiResponseSingle.order.isCancelEligible;
                    output.isModifyEligible = apiResponseSingle.order.isModifyEligible;
                    output.holdType = apiResponseSingle.order.holdTypeId;
                    output.isAwaitingPaymentProcess = apiResponseSingle.order.isAwaitingPaymentProcess;
                    /* DP-39915 mapping new api parameters ends */
                    
                    System.debug(LoggingLevel.DEBUG,'output.serializedOrder>>>' + output.serializedString);
                }
                else {
                    output.serializedString = JSON.serialize(output.listOfOrders, false);
                    output.orderResponseSize = output.listOfOrders.size();
                }
                System.debug(LoggingLevel.DEBUG,'NF_UnAuthUserOrderLookup: output.listOfOrders size>>>' + output.listOfOrders.size());
                System.debug(output.listOfOrders.toString());
            }
            outputs.add(output);
        }

        System.debug(LoggingLevel.DEBUG,'NF_UnAuthUserOrderLookup: output=' + output);
        return outputs;
    }
}