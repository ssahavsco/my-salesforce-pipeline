public class OrderTransactionDetails{
      
    public class Response{
        //public Boolean success;
        public PHISTorderTransactionWrapper.ResponseTransactions successData;
        public PHISTorderTransactionWrapper.ResponseOrder orderData;
        //public String errorMessage;
    }
    @InvocableMethod(label='Get Order Details' description='Returns the order details')
    public static List<Output> getOrderDetails(List<Input> input){
        List<Output> outputs = new List<Output>();
        Output out = new Output();
        String orderNumber = input[0].orderNumber;
        try{
            if(!orderNumber.startsWith('5')){
                Map<String, String> inputSearchMap = new Map<String, String>(); 
                inputSearchMap.put('orderNumber', orderNumber);
                inputSearchMap.put('searchType','searchByOrderNumber');
                String inputSearchData = JSON.serialize(inputSearchMap);
                String phistResponse = PHISTDigitalOrderTransactionSearch.getOrderHistory(inputSearchData);
                
                System.debug('phistResponse '+phistResponse);
                JSONParser parser = JSON.createParser(phistResponse);
                Integer orderDateCount = 0,promisedCount=0,carrierCount=0,shipCount=0,stateCount=0,countryCount=0;
                String stateCountry = '';
                while(parser.nextToken() != null){
                    if(parser.getCurrentToken() == JSONTOKEN.FIELD_NAME){
                        String fieldName = parser.getText();
                        parser.nextToken();
                        if(fieldName == 'errorMessage'){
                            out.errorMessage = String.valueOf(parser.getText());
                        }
                        if(fieldName == 'CreatedTimestamp' && orderDateCount < 1 && parser.getText() != null && parser.getText() != 'null'){
                            System.debug(fieldName+' - '+parser.getText());
                            out.orderDate = DateTime.valueOf(parser.getText().replace('T',' '));
                            orderDateCount++;
                        }
                        if(fieldName == 'PromisedDeliveryDate' && promisedCount < 1 && parser.getText() != null && parser.getText() != 'null'){
                            System.debug(fieldName+' - '+parser.getText());
                            out.expectedDeliveryDate = DateTime.valueOf(parser.getText().replace('T',' '));
                            promisedCount++;
                        }
                        if(fieldName == 'CarrierCode' && carrierCount < 1 && parser.getText() != null && parser.getText() != 'null'){
                            System.debug(fieldName+' - '+parser.getText());
                            out.carrier = parser.getText();
                            carrierCount++;
                        }
                        if(fieldName == 'Country' && countryCount < 1 && parser.getText() != null && parser.getText() != 'null'){
                            System.debug(fieldName+' - '+parser.getText());
                            stateCountry = parser.getText();
                            countryCount++;
                        }
                        if(fieldName == 'State' && stateCount < 1 && parser.getText() != null && parser.getText() != 'null'){
                            System.debug(fieldName+' - '+parser.getText());
                            stateCountry += '_'+parser.getText();
                            stateCount++;
                        }
                        if(fieldName == 'ShippingMethodId' && shipCount < 1 && parser.getText() != null && parser.getText() != 'null'){
                            System.debug(fieldName+' - '+parser.getText());
                            if(parser.getText() == 'S')
                                out.shipType = 'Standard';
                            else if(parser.getText() == 'P')
                                out.shipType = 'Standard Delivery';
                            else if(parser.getText() == 'N')
                                out.shipType = 'Alaska, Hawaii and US Territories';
                            else if(parser.getText() == 'G')
                                out.shipType = 'Next Business Day Express';
                            else if(parser.getText() == 'E')
                                out.shipType = 'No Rush Delivery';
                            else if(parser.getText() == 'F')
                                out.shipType = '2 Business Day Express';
                            else if(parser.getText() == 'V')
                                out.shipType = 'Virgin Islands Express';
                            else if(parser.getText() == 'A')
                                out.shipType = '3 Business Day Express';
                            else if(parser.getText() == 'T')
                                out.shipType = 'Saturday Express';
                            else if(parser.getText() == 'O')
                                out.shipType = 'International Standard';
                            else if(parser.getText() == 'X')
                                out.shipType = 'International Express';
                            else if(parser.getText() == 'C')
                                out.shipType = 'Canadian Standard';
                            else if(parser.getText() == 'D')
                                out.shipType = 'Canadian Express';
                            shipCount++;
                        }
                    }
                }
                out.stateCountry = stateCountry;
            }
        } catch(Exception e){
            out.carrier = null;
            out.shipType = null;
            out.orderDate = null;
            out.expectedDeliveryDate = null;
            out.stateCountry = null;
            System.debug('Exception -> '+e);
            Logger.error('Exception Occured in Get Order Transaction from Case'+e.getMessage());
            Logger.saveLog();
        }
        outputs.add(out);
        return outputs; 
    }
    public class Input{
        @InvocableVariable(required=false)
        public String orderNumber;
    }
    public class Output{
        @InvocableVariable
        public String carrier;
        @InvocableVariable
        public String shipType;
        @InvocableVariable
        public DateTime orderDate;
        @InvocableVariable
        public String stateCountry;
        @InvocableVariable
        public DateTime expectedDeliveryDate;
        @InvocableVariable
        public String errorMessage;
    }
    public class InputSearchData{
        public String orderNumber;
        public String searchType;
    }
}