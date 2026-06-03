global class NF_PreChatMockUp implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        system.debug(req);
        String endPoint = req.getEndpoint();
        Integer maxReocds =  Integer.valueof((Math.random() * 100));
        System.debug(LoggingLevel.DEBUG,'endpoint'+endPoint);
        if(maxReocds > 50 ){
            maxReocds = maxReocds - 50;
        }
        if(endPoint == 'https://apitest.victoriassecret.com/apiauthentication/v1/token?grant_type=client_credentials&client_secret=eJv4s59Hd7Y7lzIjJboqJwhTIVS4&client_id=sfccs'){
            system.debug(endPoint);
            Map<String,Object> resposeData = new Map<String,Object>();
            resposeData.put('access_token', '0X2CZVCJNT6ID--T-KDOLQ');
            resposeData.put('expires_in', 7200);
            resposeData.put('token_type', 'Bearer');
            response.setBody(JSON.serialize(resposeData));
            response.setStatusCode(200);
            response.setStatus('OK');
        }
        else if(endPoint == 'https://apitest.victoriassecret.com/orderhistory/v7/orders?limit=75&activeCountry=US'){
            response.setStatusCode(200);
            NF_PreChatMockUp.MockData mockDataWrap  = NF_PreChatMockUp.getMockData();
            
            List<NF_OrderServiceN.OrderResponse> orderList = NF_PreChatMockUp.getGenratedDataResponse(mockDataWrap, maxReocds);
            List<Product2> allProducts = [SELECT Id, Name FROM Product2 Limit :maxReocds];
            
            
            List<NF_OrderServiceN.ListOfOrderResponse> orderResponseList = new List<NF_OrderServiceN.ListOfOrderResponse>();
            NF_OrderServiceN.ListOfOrderResponse listData1 = new NF_OrderServiceN.ListOfOrderResponse();
            listData1.orderStatus = 'Canceled';
            listData1.orderNumber = 'C300009902';
            listData1.isCancelModifyEligible = true;
            listData1.orderDateTime = String.valueOf(System.today().adddays(-5));//'2020-10-01';
            listData1.orderDate = '2020-10-02';
            
           	NF_OrderServiceN.ListOfOrderResponse listData122 = new NF_OrderServiceN.ListOfOrderResponse();
            listData122.orderStatus = 'Canceled';
            listData122.orderNumber = 'C300009901';
            listData122.isCancelModifyEligible = true;
            listData122.orderDateTime = String.valueOf(System.today().adddays(-5));//'2020-10-01';
            listData122.orderDate = '2020-10-01';

            orderResponseList.add(listData1);
            orderResponseList.add(listData122);

            if(false){
                
                NF_OrderServiceN.ListOfOrderResponse listData2 = new NF_OrderServiceN.ListOfOrderResponse();
                listData2.orderStatus = 'pending';
                listData2.orderNumber = 'C300009902';
                listData2.isCancelModifyEligible = true;
                listData2.orderDateTime = '2020-08-21';
                listData2.orderDate = '2020-08-21';
                orderResponseList.add(listData2);
                
                
                NF_OrderServiceN.ListOfOrderResponse listData3 = new NF_OrderServiceN.ListOfOrderResponse();
                listData3.orderStatus = 'pending';
                listData3.orderNumber = 'C300009902';
                listData3.isCancelModifyEligible = true;
                listData3.orderDateTime = '2020-08-21';
                listData3.orderDate = '2020-08-21';
                orderResponseList.add(listData3);
                
                
                NF_OrderServiceN.ListOfOrderResponse listData4 = new NF_OrderServiceN.ListOfOrderResponse();
                listData4.orderStatus = 'pending';
                listData4.orderNumber = 'C300009902';
                listData4.isCancelModifyEligible = true;
                listData4.orderDateTime = '2020-08-21';
                listData4.orderDate = '2020-08-21';
                orderResponseList.add(listData4);
                
                NF_OrderServiceN.ListOfOrderResponse listData = new NF_OrderServiceN.ListOfOrderResponse();
                listData.orderStatus = 'pending';
                listData.orderNumber = 'C300009902';
                listData.isCancelModifyEligible = true;
                listData.orderDateTime = '2020-08-21';
                listData.orderDate = '2020-08-21';
                orderResponseList.add(listData);

                NF_OrderServiceN.ListOfOrderResponse listData5 = new NF_OrderServiceN.ListOfOrderResponse();
                listData5.orderStatus = 'Canceled';
                listData5.orderNumber = 'C300009902';
                listData5.isCancelModifyEligible = true;
                listData5.orderDateTime = String.valueOf(System.today().adddays(-5));//'2020-10-01';
                listData5.orderDate = '2020-10-02';
                orderResponseList.add(listData5);
                
            }
            
            String responseString = JSON.serialize(orderResponseList);
            system.debug(responseString);
            response.setBody(responseString);  
        }
        else{
            response.setStatusCode(200);
            String requestBody = req.getBody();
            NF_OrderServiceN.OrderRequest requestData = (NF_OrderServiceN.OrderRequest)JSON.deserialize(requestBody,NF_OrderServiceN.OrderRequest.class);
            
            NF_PreChatMockUp.MockData mockDataWrap  = NF_PreChatMockUp.getMockData();
            
            List<NF_OrderServiceN.OrderResponse> orderList = NF_PreChatMockUp.getGenratedDataResponse(mockDataWrap, maxReocds);
            List<Product2> allProducts = [SELECT Id, Name FROM Product2 Limit :maxReocds];
            
            if(endPoint == 'https://apitest.victoriassecret.com/orderhistory/v7/orderByIdAndEmail'){
                if(requestData.email != '' && requestData.email != 'null' && requestData.orderId != '' && requestData.orderId !=  'null' ){
                    NF_OrderServiceN.OrderResponse orderWithEmailAndOrder = new NF_OrderServiceN.OrderResponse();
                    for(Integer i = 0; i< orderList.size(); i++){
                        if(orderList[i].shipments[0].lineItems[0].attributes.email == requestData.email && orderList[i].orderNumber == requestData.orderId){
                            orderWithEmailAndOrder = orderList[i];
                            orderWithEmailAndOrder.orderStatus = 'Pending';
                            break;
                        }else{
                            response.setBody('');
                        }
                        
                    } 
                    String responseString = JSON.serialize(orderWithEmailAndOrder);
                    response.setBody(responseString); 
                }else{
                    response.setBody('');
                }    
            }
            else if(endPoint == 'https://apitest.victoriassecret.com/orderhistory/v7/search'){
                if(requestData.email != '' && requestData.email != 'null'  ){
                    response.setStatusCode(200);
                    response.setStatus('Success');
                    List<NF_OrderServiceN.ListOfOrderResponse> orderWithEmail = new List<NF_OrderServiceN.ListOfOrderResponse>();
                    
                    NF_OrderServiceN.ListOfOrderResponse listData = new NF_OrderServiceN.ListOfOrderResponse();
                    listData.orderStatus = 'pending';
                    listData.orderNumber = 'C300009902';
                    listData.isCancelModifyEligible = true;
                    listData.orderDateTime = String.valueOf(System.today().adddays(+90));//'2020-08-21';
                    listData.orderDate = '2020-08-21';
                     listData.orderSummary = new NF_OrderServiceN.orderSummary();
                    listData.orderSummary.merchandiseSubTotal = '$225.00';
                    listData.orderSummary.orderTotal = '$241.88';
                    listData.orderSummary.salesTax = '$16.88';
                    listData.orderSummary.shippingHandling = '$0.00';
                    listData.orderSummary.isRefundTotal = false;
                    listData.orderSummary.showTax = true; 
                    orderWithEmail.add(listData);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData2 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData2.orderStatus = 'pending';
                    listData2.orderNumber = 'C300009902';
                    listData2.isCancelModifyEligible = true;
                    listData2.orderDateTime = String.valueOf(System.today().adddays(+90));//'2020-08-21';
                    listData2.orderDate = '2020-08-21';
                     listData2.orderSummary = new NF_OrderServiceN.orderSummary();
                    listData2.orderSummary.merchandiseSubTotal = '$225.00';
                    listData2.orderSummary.orderTotal = '$241.88';
                    listData2.orderSummary.salesTax = '$16.88';
                    listData2.orderSummary.shippingHandling = '$0.00';
                    listData2.orderSummary.isRefundTotal = false;
                    listData2.orderSummary.showTax = true; 
                    orderWithEmail.add(listData2);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData3 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData3.orderStatus = 'pending';
                    listData3.orderNumber = 'C300009902';
                    listData3.isCancelModifyEligible = true;
                    listData3.orderDateTime = String.valueOf(System.today().adddays(+90));//'2020-08-21';
                    listData3.orderDate = '2020-08-21';
                     listData3.orderSummary = new NF_OrderServiceN.orderSummary();
                    listData3.orderSummary.merchandiseSubTotal = '$225.00';
                    listData3.orderSummary.orderTotal = '$241.88';
                    listData3.orderSummary.salesTax = '$16.88';
                    listData3.orderSummary.shippingHandling = '$0.00';
                    listData3.orderSummary.isRefundTotal = false;
                    listData3.orderSummary.showTax = true; 
                    orderWithEmail.add(listData3);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData4 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData4.orderStatus = 'pending';
                    listData4.orderNumber = 'C300009902';
                    listData4.isCancelModifyEligible = true;
                    listData4.orderDateTime = '2020-08-21';
                    listData4.orderDate = '2020-08-21';
                     listData4.orderSummary = new NF_OrderServiceN.orderSummary();
                    listData4.orderSummary.merchandiseSubTotal = '$225.00';
                    listData4.orderSummary.orderTotal = '$241.88';
                    listData4.orderSummary.salesTax = '$16.88';
                    listData4.orderSummary.shippingHandling = '$0.00';
                    listData4.orderSummary.isRefundTotal = false;
                    listData4.orderSummary.showTax = true; 
                    orderWithEmail.add(listData4);

                    /* for(Integer i = 0; i< orderList.size(); i++){
if(orderList[i].shipments[0].lineItems[0].attributes.email == requestData.email){
orderWithEmail.add(orderList[i]);

}else{
response.setBody('');
}

} */
                    String responseString = JSON.serialize(orderWithEmail);
                    /* NF_OrderServiceN.APIResponse apiResp = new NF_OrderServiceN.APIResponse();
apiResp.status = 'Success';
apiResp.statusCode = 200;
apiResp.orders = (List<NF_OrderServiceN.ListOfOrderResponse>) JSON.deserialize(responseString,List<NF_OrderServiceN.ListOfOrderResponse>.class);
apiResp.rawBody = responseString;
system.debug(apiResp); */
                    response.setBody(responseString); 
                }
            }
            
        }
        return response;
    }
    public static NF_OrderServiceN.OrderResponse getOrderDetailInstance(String orderdate, String orderStatus){
        NF_OrderServiceN.OrderResponse osObj = new NF_OrderServiceN.OrderResponse();
        
        osObj.orderDate = new NF_OrderServiceN.OrderDate();
        osObj.orderDate.month = 04;
        osObj.orderDate.day = 05;
        osObj.orderDate.year = 2020;
        osObj.orderDateTime = orderdate;
        osObj.orderNumber = 'S000123333';
        
        osObj.orderSummary = new NF_OrderServiceN.orderSummary();
        osObj.orderSummary.merchandiseSubTotal = '$225.00';
        osObj.orderSummary.orderTotal = '$241.88';
        osObj.orderSummary.salesTax = '$16.88';
        osObj.orderSummary.shippingHandling = '$0.00';
        osObj.orderSummary.isRefundTotal = false;
        osObj.orderSummary.showTax = true; 
        
        osObj.orderType = 'Store Order';
        osObj.orderStatus= orderStatus;
        osObj.isLegacyOrder= false;
        osObj.isEShop= false;
        
        List<NF_OrderServiceN.Payments> payments = new List<NF_OrderServiceN.Payments>();
        NF_OrderServiceN.Payments paymnt = new NF_OrderServiceN.Payments();
        paymnt.paymentType = 'visa';
        paymnt.itemNumber = '0119';
        paymnt.amount = '$91.88';
        payments.add(paymnt);    
        osObj.payments = payments;
        
        List<NF_OrderServiceN.Shipments> shipmentList = new  List<NF_OrderServiceN.Shipments>();
        NF_OrderServiceN.Shipments shipmnt = new NF_OrderServiceN.Shipments();
        shipmnt.status = 'Pending';
        shipmnt.StatusDate = new NF_OrderServiceN.StatusDate();
        shipmnt.StatusDate.month = 05;
        shipmnt.StatusDate.day = 05;
        shipmnt.StatusDate.year = 2020;
        
        List<NF_OrderServiceN.Payments> paymentList2 = new List<NF_OrderServiceN.Payments>();
        paymnt.amount = '5465';
        paymnt.itemNumber = '4659';
        paymnt.paymentType = 'COD';
        paymentList2.add(paymnt);    
        
        List<NF_OrderServiceN.LineItems> lineItemList = new List<NF_OrderServiceN.LineItems>();
        NF_OrderServiceN.LineItems lineitm = new NF_OrderServiceN.LineItems();
        lineitm.family = 'Very Sexy';
        lineitm.isAvailable = false;
        lineitm.status = 'Pending';
        lineitm.variantId = '1BS54';
        
        
        lineitm.quantity = new NF_OrderServiceN.Quantity();
        lineitm.quantity.selected = 05; 
        lineitm.price = new NF_OrderServiceN.Price();
        lineitm.price.unitPrice =  new NF_OrderServiceN.UnitPrice();
        lineitm.price.unitPrice.originalPrice = '02524';
        lineitm.price.totalPrice = new NF_OrderServiceN.TotalPrice();
        lineitm.price.totalPrice.originalPrice = '2545';
        lineitm.price.priceType = 'realPrice';
        
        NF_OrderServiceN.StatusDate statusDateForLin   = new NF_OrderServiceN.StatusDate();
        statusDateForLin.month = 05;
        statusDateForLin.day = 05;
        statusDateForLin.year = 2020;
        lineitm.statusDate = statusDateForLin;
        
        NF_OrderServiceN.Attributes attribute = new NF_OrderServiceN.Attributes();
        attribute.choice =  new NF_OrderServiceN.Choice();
        attribute.choice.value = 'armani';
        attribute.size1 = new NF_OrderServiceN.Size1();
        attribute.size1.label = 'length';
        attribute.size1.value = '50cm';
        lineitm.attributes = attribute;
        lineItemList.add(lineitm);
        
        shipmnt.lineItems = lineItemList;
        shipmnt.address = new NF_OrderServiceN.Address();
        shipmnt.address.streetAddress1 = 'mansarovar';
        shipmentList.add(shipmnt);
        osObj.shipments = shipmentList;
        return osObj;
    }
    
    public static NF_PreChatMockUp.MockData getMockData(){
        List<String> shipToList = new List<String>();
        shipToList.add('Circuit House Rd, Cantt Area, Jodhpur, Rajasthan 342006');
        shipToList.add('Jhalamand House, Airport Rd, Air Force Area, Jodhpur, Rajasthan 342011');
        shipToList.add('Village- Indroka, MDR104, Jodhpur, Rajasthan 342305');
        shipToList.add('NH62, Netra, Rajasthan 342037');
        shipToList.add('FORT, Khejarla, Rajasthan 342601');
        shipToList.add('Ajmer, NH-14, Ajmer Road, Beawar, Beawar, Rajasthan 305901');
        shipToList.add('Kaiser Ganj Rd, Diggi Bazaar, Ajmer, Rajasthan 305001');
        shipToList.add('Tehsil, Tordi Garh, Malpura, Rajasthan 304502');
        shipToList.add('Banar Rd, Prem Nagar, Jodhpur, Rajasthan 342027');
        shipToList.add('Village Post Rohet, Rohet Garh, Rajasthan 306421');
        shipToList.add('Circuit House Rd, Cantt Area, Jodhpur, Rajasthan 342006');
        shipToList.add('Jhalamand House, Airport Rd, Air Force Area, Jodhpur, Rajasthan 342011');
        shipToList.add('Village- Indroka, MDR104, Jodhpur, Rajasthan 342305');
        shipToList.add('NH62, Netra, Rajasthan 342037');
        shipToList.add('FORT, Khejarla, Rajasthan 342601');
        shipToList.add('Ajmer, NH-14, Ajmer Road, Beawar, Beawar, Rajasthan 305901');
        shipToList.add('Kaiser Ganj Rd, Diggi Bazaar, Ajmer, Rajasthan 305001');
        shipToList.add('Tehsil, Tordi Garh, Malpura, Rajasthan 304502');
        shipToList.add('Banar Rd, Prem Nagar, Jodhpur, Rajasthan 342027');
        shipToList.add('Village Post Rohet, Rohet Garh, Rajasthan 306421');
        shipToList.add('Circuit House Rd, Cantt Area, Jodhpur, Rajasthan 342006');
        shipToList.add('Jhalamand House, Airport Rd, Air Force Area, Jodhpur, Rajasthan 342011');
        shipToList.add('Village- Indroka, MDR104, Jodhpur, Rajasthan 342305');
        shipToList.add('NH62, Netra, Rajasthan 342037');
        shipToList.add('FORT, Khejarla, Rajasthan 342601');
        shipToList.add('Ajmer, NH-14, Ajmer Road, Beawar, Beawar, Rajasthan 305901');
        shipToList.add('Kaiser Ganj Rd, Diggi Bazaar, Ajmer, Rajasthan 305001');
        shipToList.add('Tehsil, Tordi Garh, Malpura, Rajasthan 304502');
        shipToList.add('Banar Rd, Prem Nagar, Jodhpur, Rajasthan 342027');
        shipToList.add('Village Post Rohet, Rohet Garh, Rajasthan 306421');
        shipToList.add('Circuit House Rd, Cantt Area, Jodhpur, Rajasthan 342006');
        shipToList.add('Jhalamand House, Airport Rd, Air Force Area, Jodhpur, Rajasthan 342011');
        shipToList.add('Village- Indroka, MDR104, Jodhpur, Rajasthan 342305');
        shipToList.add('NH62, Netra, Rajasthan 342037');
        shipToList.add('FORT, Khejarla, Rajasthan 342601');
        shipToList.add('Ajmer, NH-14, Ajmer Road, Beawar, Beawar, Rajasthan 305901');
        shipToList.add('Kaiser Ganj Rd, Diggi Bazaar, Ajmer, Rajasthan 305001');
        shipToList.add('Tehsil, Tordi Garh, Malpura, Rajasthan 304502');
        shipToList.add('Banar Rd, Prem Nagar, Jodhpur, Rajasthan 342027');
        shipToList.add('Village Post Rohet, Rohet Garh, Rajasthan 306421');
        shipToList.add('Circuit House Rd, Cantt Area, Jodhpur, Rajasthan 342006');
        shipToList.add('Jhalamand House, Airport Rd, Air Force Area, Jodhpur, Rajasthan 342011');
        shipToList.add('Village- Indroka, MDR104, Jodhpur, Rajasthan 342305');
        shipToList.add('NH62, Netra, Rajasthan 342037');
        shipToList.add('FORT, Khejarla, Rajasthan 342601');
        shipToList.add('Ajmer, NH-14, Ajmer Road, Beawar, Beawar, Rajasthan 305901');
        shipToList.add('Kaiser Ganj Rd, Diggi Bazaar, Ajmer, Rajasthan 305001');
        shipToList.add('Tehsil, Tordi Garh, Malpura, Rajasthan 304502');
        shipToList.add('Banar Rd, Prem Nagar, Jodhpur, Rajasthan 342027');
        shipToList.add('Village Post Rohet, Rohet Garh, Rajasthan 306421');
        
        
        List<String> firstNameList = new List<String>();
        firstNameList.add('Tome');
        firstNameList.add('Dome');
        firstNameList.add('LIIYO');
        firstNameList.add('BROWTO');
        firstNameList.add('NIYANANO');
        firstNameList.add('FERIDO');
        firstNameList.add('MEGNITO');
        firstNameList.add('SHIPVA');
        firstNameList.add('MOHIT');
        firstNameList.add('SHEENGWA');
        firstNameList.add('Tome');
        firstNameList.add('Dome');
        firstNameList.add('LIIYO');
        firstNameList.add('BROWTO');
        firstNameList.add('NIYANANO');
        firstNameList.add('FERIDO');
        firstNameList.add('MEGNITO');
        firstNameList.add('SHIPVA');
        firstNameList.add('MOHIT');
        firstNameList.add('SHEENGWA');
        firstNameList.add('Tome');
        firstNameList.add('Dome');
        firstNameList.add('LIIYO');
        firstNameList.add('BROWTO');
        firstNameList.add('NIYANANO');
        firstNameList.add('FERIDO');
        firstNameList.add('MEGNITO');
        firstNameList.add('SHIPVA');
        firstNameList.add('MOHIT');
        firstNameList.add('SHEENGWA');
        firstNameList.add('Tome');
        firstNameList.add('Dome');
        firstNameList.add('LIIYO');
        firstNameList.add('BROWTO');
        firstNameList.add('NIYANANO');
        firstNameList.add('FERIDO');
        firstNameList.add('MEGNITO');
        firstNameList.add('SHIPVA');
        firstNameList.add('MOHIT');
        firstNameList.add('SHEENGWA');
        firstNameList.add('Tome');
        firstNameList.add('Dome');
        firstNameList.add('LIIYO');
        firstNameList.add('BROWTO');
        firstNameList.add('NIYANANO');
        firstNameList.add('FERIDO');
        firstNameList.add('MEGNITO');
        firstNameList.add('SHIPVA');
        firstNameList.add('MOHIT');
        firstNameList.add('SHEENGWA');
        
        
        List<String>  lastNameList = new List<String>();
        lastNameList.add('HLRI');
        lastNameList.add('DENO');
        lastNameList.add('MERATO');
        lastNameList.add('JEENGWA');
        lastNameList.add('SHARMA');
        lastNameList.add('MITTAL');
        lastNameList.add('MEEENA');
        lastNameList.add('HEENRI');
        lastNameList.add('JAANTATO');
        lastNameList.add('JIYAZO');
        lastNameList.add('HLRI');
        lastNameList.add('DENO');
        lastNameList.add('MERATO');
        lastNameList.add('JEENGWA');
        lastNameList.add('SHARMA');
        lastNameList.add('MITTAL');
        lastNameList.add('MEEENA');
        lastNameList.add('HEENRI');
        lastNameList.add('JAANTATO');
        lastNameList.add('JIYAZO');
        lastNameList.add('HLRI');
        lastNameList.add('DENO');
        lastNameList.add('MERATO');
        lastNameList.add('JEENGWA');
        lastNameList.add('SHARMA');
        lastNameList.add('MITTAL');
        lastNameList.add('MEEENA');
        lastNameList.add('HEENRI');
        lastNameList.add('JAANTATO');
        lastNameList.add('JIYAZO');
        lastNameList.add('HLRI');
        lastNameList.add('DENO');
        lastNameList.add('MERATO');
        lastNameList.add('JEENGWA');
        lastNameList.add('SHARMA');
        lastNameList.add('MITTAL');
        lastNameList.add('MEEENA');
        lastNameList.add('HEENRI');
        lastNameList.add('JAANTATO');
        lastNameList.add('JIYAZO');
        lastNameList.add('HLRI');
        lastNameList.add('DENO');
        lastNameList.add('MERATO');
        lastNameList.add('JEENGWA');
        lastNameList.add('SHARMA');
        lastNameList.add('MITTAL');
        lastNameList.add('MEEENA');
        lastNameList.add('HEENRI');
        lastNameList.add('JAANTATO');
        lastNameList.add('JIYAZO');
        
        List<String>  paymentMethod = new List<String>();
        paymentMethod.add('COD');
        paymentMethod.add('Visa');
        NF_PreChatMockUp.MockData dataWrp = new NF_PreChatMockUp.MockData();
        dataWrp.shipToList = shipToList;
        dataWrp.firstNameList = firstNameList;
        dataWrp.lastNameList = lastNameList;
        dataWrp.paymethodList = paymentMethod;
        return dataWrp;
    } 
    public static List<NF_OrderServiceN.OrderResponse> getGenratedDataResponse(NF_PreChatMockUp.MockData mockData, Integer maxReocds){
        
        List<NF_OrderServiceN.OrderResponse> orderList = new List<NF_OrderServiceN.OrderResponse>();
        for(Integer i = 1; i<= maxReocds; i++){
            NF_OrderServiceN.OrderResponse osObj = getOrderDetailInstance('2020-03-16T15:09:45', 'orderPlaced');
            osObj.orderNumber = 'W03392660'+i;
            if(i < 12){
                osObj.orderDate.month = i;
            }else{
                osObj.orderDate.month = Math.abs(i / 12);
            }
            osObj.orderDate.day = 05;
            osObj.orderDate.year = 2020;
            osObj.orderSummary.orderTotal = String.valueOf((i*2545).format());  
            //osObj.shipments[0].trackingNumber = String.valueOf((i*546).format()); 
            osObj.shipments[0].address.streetAddress1 = mockData.shipToList[i - 1];
            //osObj.shipments[0].address.addressId = i + mockData.shipToList[i - 1];
            //osObj.shipments[0].address.firstName = mockData.firstNameList[i - 1];
            //osObj.shipments[0].address.lastName = mockData.lastNameList[i - 1];
            if(i==2){
                osObj.shipments[0].lineItems[0].attributes.email = 'test@gmail.com';
                osObj.orderNumber = 'W033926602';
            }else{
                osObj.shipments[0].lineItems[0].attributes.email = mockData.firstNameList[i - 1] + '' + mockData.lastNameList[i - 1] + '@gmail.com';
            }
            if(i / 2 == 0){
                osObj.payments[0].paymentType =   mockData.paymethodList[1];
            }else{
                osObj.payments[0].paymentType =   mockData.paymethodList[0];
            }
            //allProducts[i-1];
            orderList.add(osObj);
            
        }
        return orderList;
    }
    
    public class MockData{
        public  List<String>  shipToList;
        public List<String> firstNameList;
        public List<String> lastNameList;
        public List<String> paymethodList;
    }
}