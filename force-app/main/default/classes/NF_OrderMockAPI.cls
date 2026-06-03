global class NF_OrderMockAPI implements HttpCalloutMock{
    
    public static Boolean enablePreChatMockData = false;
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
        else if(endPoint == '1234@gmail.com'){
            response.setStatusCode(404);
            response.setBody('No Result Found'); 
        }
        else if(endPoint == 'https://apitest.victoriassecret.com/orderhistory/v9/orders?limit=75&activeCountry=US'){
            response.setStatusCode(200);
            NF_OrderMockAPI.MockData mockDataWrap  = NF_OrderMockAPI.getMockData();
            
            List<NF_OrderServiceN.OrderResponse> orderList = NF_OrderMockAPI.getGenratedDataResponse(mockDataWrap, maxReocds);
            List<Product2> allProducts = [SELECT Id, Name FROM Product2 Limit :maxReocds];
            
            
            List<NF_OrderServiceN.ListOfOrderResponse> orderResponseList = new List<NF_OrderServiceN.ListOfOrderResponse>();
            NF_OrderServiceN.ListOfOrderResponse listData1 = new NF_OrderServiceN.ListOfOrderResponse();
            listData1.orderStatus = 'Canceled';
            listData1.orderNumber = 'C300009902';
            listData1.isCancelModifyEligible = true;
            listData1.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-10-01';
            listData1.orderDate = '2021-09-02';
            orderResponseList.add(listData1);
            
            NF_OrderServiceN.ListOfOrderResponse listData2 = new NF_OrderServiceN.ListOfOrderResponse();
            listData2.orderStatus = 'Canceled';
            listData2.orderNumber = 'C300009902';
            listData2.isCancelModifyEligible = true;
            listData2.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-10-01';
            listData2.orderDate = '2021-09-02';
            orderResponseList.add(listData2);
            
            NF_OrderServiceN.ListOfOrderResponse listData3 = new NF_OrderServiceN.ListOfOrderResponse();
            listData3.orderStatus = 'Canceled';
            listData3.orderNumber = 'C300009902';
            listData3.isCancelModifyEligible = true;
            listData3.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-10-01';
            listData3.orderDate = '2021-09-02';
            orderResponseList.add(listData3);
            
            NF_OrderServiceN.ListOfOrderResponse listData4 = new NF_OrderServiceN.ListOfOrderResponse();
            listData4.orderStatus = 'Canceled';
            listData4.orderNumber = 'C300009902';
            listData4.isCancelModifyEligible = true;
            listData4.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-10-01';
            listData4.orderDate = '2021-09-02';
            orderResponseList.add(listData4);
            
            NF_OrderServiceN.ListOfOrderResponse listData5 = new NF_OrderServiceN.ListOfOrderResponse();
            listData5.orderStatus = 'Canceled';
            listData5.orderNumber = 'C300009902';
            listData5.isCancelModifyEligible = true;
            listData5.orderDateTime = String.valueOf(System.today().adddays(-5));//'2020-10-01';
            listData5.orderDate = '2021-09-02';
            orderResponseList.add(listData5);
            if(enablePreChatMockData){
                NF_OrderServiceN.ListOfOrderResponse listData122 = new NF_OrderServiceN.ListOfOrderResponse();
                listData122.orderStatus = 'Canceled';
                listData122.orderNumber = 'C300009901';
                listData122.isCancelModifyEligible = true;
                listData122.orderDateTime = String.valueOf(System.today().adddays(-5));//'2020-10-01';
                listData122.orderDate = '2021-09-02';
                orderResponseList.add(listData122);
            }
            
            if(false){
                
                NF_OrderServiceN.ListOfOrderResponse listData6 = new NF_OrderServiceN.ListOfOrderResponse();
                listData6.orderStatus = 'pending';
                listData6.orderNumber = 'C300009902';
                listData6.isCancelModifyEligible = true;
                listData6.orderDateTime = String.valueOf(System.today().adddays(-75));
                listData6.orderDate = '2021-09-02';
                orderResponseList.add(listData6);
                
                
                NF_OrderServiceN.ListOfOrderResponse listData7 = new NF_OrderServiceN.ListOfOrderResponse();
                listData7.orderStatus = 'pending';
                listData7.orderNumber = 'C300009902';
                listData7.isCancelModifyEligible = true;
                listData7.orderDateTime = String.valueOf(System.today().adddays(-75));
                listData7.orderDate = '2021-09-02';
                orderResponseList.add(listData7);
                
                
                NF_OrderServiceN.ListOfOrderResponse listData8 = new NF_OrderServiceN.ListOfOrderResponse();
                listData8.orderStatus = 'pending';
                listData8.orderNumber = 'C300009902';
                listData8.isCancelModifyEligible = true;
                listData8.orderDateTime = String.valueOf(System.today().adddays(-5));
                listData8.orderDate = '2021-09-02';
                orderResponseList.add(listData8);
                
                NF_OrderServiceN.ListOfOrderResponse listData = new NF_OrderServiceN.ListOfOrderResponse();
                listData.orderStatus = 'pending';
                listData.orderNumber = 'C300009902';
                listData.isCancelModifyEligible = true;
                listData.orderDateTime = String.valueOf(System.today().adddays(-5));
                listData.orderDate = '2021-09-02';
                orderResponseList.add(listData);

                NF_OrderServiceN.ListOfOrderResponse listData10 = new NF_OrderServiceN.ListOfOrderResponse();
                listData10.orderStatus = 'Canceled';
                listData10.orderNumber = 'C300009902';
                listData10.isCancelModifyEligible = true;
                listData10.orderDateTime = String.valueOf(System.today().adddays(-5));//'2020-10-01';
                listData10.orderDate = '2021-09-02';
                orderResponseList.add(listData10);
                
            }
            
            String responseString = JSON.serialize(orderResponseList);
            system.debug(responseString);
            response.setBody(responseString);  
        }
        else{
            response.setStatusCode(200);
            String requestBody = req.getBody();
            NF_OrderServiceN.OrderRequest requestData = (NF_OrderServiceN.OrderRequest)JSON.deserialize(requestBody,NF_OrderServiceN.OrderRequest.class);
            
            NF_OrderMockAPI.MockData mockDataWrap  = NF_OrderMockAPI.getMockData();
            
            List<NF_OrderServiceN.OrderResponse> orderList = NF_OrderMockAPI.getGenratedDataResponse(mockDataWrap, maxReocds);
            List<Product2> allProducts = [SELECT Id, Name FROM Product2 Limit :maxReocds];
            
            // if(endPoint == 'https://apitest.victoriassecret.com/orderdetails/v4/orderByIdAndEmail'){
            if(endPoint == 'https://apitest.victoriassecret.com/orderdetails/v8/orders'){
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
                    response.setStatusCode(400);
                    response.setStatus('Failed');
                }    
            }
            else if(endPoint == 'https://apitest.victoriassecret.com/orderhistory/v9/search'){
                if(requestData.email == 'success1Record@gmail.com'){
                    response.setStatusCode(200);
                    response.setStatus('Success');
                    List<NF_OrderServiceN.ListOfOrderResponse> orderWithEmail = new List<NF_OrderServiceN.ListOfOrderResponse>();
                    
                    NF_OrderServiceN.ListOfOrderResponse listData = new NF_OrderServiceN.ListOfOrderResponse();
                    listData.orderStatus = 'Canceled';
                    listData.orderNumber = 'C300009902';
                    listData.isCancelModifyEligible = true;
                    listData.orderDateTime = String.valueOf(System.today().adddays(-12));//'2020-08-21';
                    listData.orderDate = '2021-09-02';
                    listData.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData.orderSummary.merchandiseSubTotal = '$225.00';
                    listData.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData.orderSummary.orderTotal = '$241.88';
                    listData.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData.orderSummary.salesTax = '$16.88';
                    listData.orderSummary.shippingHandling = '$0.00';
                    listData.orderSummary.isRefundTotal = false;
                    listData.orderSummary.showTax = true; 
                    orderWithEmail.add(listData);
                    String responseString = JSON.serialize(orderWithEmail);
                    
                    response.setBody(responseString); 
                }else if(requestData.email == 'success@gmail.com'){
                    response.setStatusCode(200);
                    response.setStatus('Success');
                    List<NF_OrderServiceN.ListOfOrderResponse> orderWithEmail = new List<NF_OrderServiceN.ListOfOrderResponse>();
                    
                    NF_OrderServiceN.ListOfOrderResponse listData = new NF_OrderServiceN.ListOfOrderResponse();
                    listData.orderStatus = 'pending';
                    listData.orderNumber = 'C300009902';
                    listData.isCancelModifyEligible = true;
                    listData.orderDateTime = String.valueOf(System.today().adddays(-12));//'2020-08-21';
                    listData.orderDate = '2021-09-02';
                    listData.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData.orderSummary.merchandiseSubTotal = '$225.00';
                    listData.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData.orderSummary.orderTotal = '$241.88';
                    listData.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData.orderSummary.salesTax = '$16.88';
                    listData.orderSummary.shippingHandling = '$0.00';
                    listData.orderSummary.isRefundTotal = false;
                    listData.orderSummary.showTax = true; 
                    orderWithEmail.add(listData);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData2 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData2.orderStatus = 'pending';
                    listData2.orderNumber = 'C300009902';
                    listData2.isCancelModifyEligible = true;
                    listData2.orderDateTime = String.valueOf(System.today().adddays(-12));//'2020-08-21';
                    listData2.orderDate = '2021-09-02';
                     listData2.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData2.orderSummary.merchandiseSubTotal = '$225.00';
                    listData2.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData2.orderSummary.orderTotal = '$241.88';
                    listData2.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData2.orderSummary.salesTax = '$16.88';
                    listData2.orderSummary.shippingHandling = '$0.00';
                    listData2.orderSummary.isRefundTotal = false;
                    listData2.orderSummary.showTax = true; 
                    orderWithEmail.add(listData2);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData3 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData3.orderStatus = 'pending';
                    listData3.orderNumber = 'C300009902';
                    listData3.isCancelModifyEligible = true;
                    listData3.orderDateTime = String.valueOf(System.today().adddays(-12));//'2020-08-21';
                    listData3.orderDate = '2021-09-02';
                     listData3.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData3.orderSummary.merchandiseSubTotal = '$225.00';
                    listData3.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData3.orderSummary.orderTotal = '$241.88';
                    listData3.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData3.orderSummary.salesTax = '$16.88';
                    listData3.orderSummary.shippingHandling = '$0.00';
                    listData3.orderSummary.isRefundTotal = false;
                    listData3.orderSummary.showTax = true; 
                    orderWithEmail.add(listData3);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData4 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData4.orderStatus = 'pending';
                    listData4.orderNumber = 'C300009902';
                    listData4.isCancelModifyEligible = true;
                    listData4.orderDateTime = String.valueOf(System.today().adddays(-12));//'2020-08-21';
                    listData4.orderDate = '2021-09-02';
                     listData4.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData4.orderSummary.merchandiseSubTotal = '$225.00';
                    listData4.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData4.orderSummary.orderTotal = '$241.88';
                    listData4.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData4.orderSummary.salesTax = '$16.88';
                    listData4.orderSummary.shippingHandling = '$0.00';
                    listData4.orderSummary.isRefundTotal = false;
                    listData4.orderSummary.showTax = true; 
                    orderWithEmail.add(listData4);
                    NF_OrderServiceN.ListOfOrderResponse listData5 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData5.orderStatus = 'pending';
                    listData5.orderNumber = 'C300009902';
                    listData5.isCancelModifyEligible = true;
                    listData5.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData5.orderDate = '2021-09-02';
                    listData5.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData5.orderSummary.merchandiseSubTotal = '$225.00';
                    listData5.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData5.orderSummary.orderTotal = '$241.88';
                    listData5.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData5.orderSummary.salesTax = '$16.88';
                    listData5.orderSummary.shippingHandling = '$0.00';
                    listData5.orderSummary.isRefundTotal = false;
                    listData5.orderSummary.showTax = true; 
                    orderWithEmail.add(listData5);
                    NF_OrderServiceN.ListOfOrderResponse listData6 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData6.orderStatus = 'pending';
                    listData6.orderNumber = 'C300009902';
                    listData6.isCancelModifyEligible = true;
                    listData6.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData6.orderDate = '2021-09-02';
                    listData6.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData5.orderSummary.merchandiseSubTotal = '$225.00';
                    listData6.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData5.orderSummary.orderTotal = '$241.88';
                    listData6.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData6.orderSummary.salesTax = '$16.88';
                    listData6.orderSummary.shippingHandling = '$0.00';
                    listData6.orderSummary.isRefundTotal = false;
                    listData6.orderSummary.showTax = true; 
                    orderWithEmail.add(listData6);
                    String responseString = JSON.serialize(orderWithEmail);
                    
                    response.setBody(responseString); 
                } else if(requestData.email != '' && requestData.email != 'null'  ){
                    response.setStatusCode(200);
                    response.setStatus('Success');
                    List<NF_OrderServiceN.ListOfOrderResponse> orderWithEmail = new List<NF_OrderServiceN.ListOfOrderResponse>();
                    
                    NF_OrderServiceN.ListOfOrderResponse listData = new NF_OrderServiceN.ListOfOrderResponse();
                    listData.orderStatus = 'pending';
                    listData.orderNumber = 'C300009902';
                    listData.isCancelModifyEligible = true;
                    listData.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData.orderDate = '2021-09-02';
                    listData.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData.orderSummary.merchandiseSubTotal = '$225.00';
                    listData.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData.orderSummary.orderTotal = '$241.88';
                    listData.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData.orderSummary.salesTax = '$16.88';
                    listData.orderSummary.shippingHandling = '$0.00';
                    listData.orderSummary.isRefundTotal = false;
                    listData.orderSummary.showTax = true; 
                    orderWithEmail.add(listData);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData2 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData2.orderStatus = 'pending';
                    listData2.orderNumber = 'C300009902';
                    listData2.isCancelModifyEligible = true;
                    listData2.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData2.orderDate = '2021-09-02';
                     listData2.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData2.orderSummary.merchandiseSubTotal = '$225.00';
                    listData2.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData2.orderSummary.orderTotal = '$241.88';
                    listData2.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData2.orderSummary.salesTax = '$16.88';
                    listData2.orderSummary.shippingHandling = '$0.00';
                    listData2.orderSummary.isRefundTotal = false;
                    listData2.orderSummary.showTax = true; 
                    orderWithEmail.add(listData2);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData3 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData3.orderStatus = 'pending';
                    listData3.orderNumber = 'C300009902';
                    listData3.isCancelModifyEligible = true;
                    listData3.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData3.orderDate = '2021-09-02';
                     listData3.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData3.orderSummary.merchandiseSubTotal = '$225.00';
                    listData3.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData3.orderSummary.orderTotal = '$241.88';
                    listData3.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData3.orderSummary.salesTax = '$16.88';
                    listData3.orderSummary.shippingHandling = '$0.00';
                    listData3.orderSummary.isRefundTotal = false;
                    listData3.orderSummary.showTax = true; 
                    orderWithEmail.add(listData3);
                    
                     NF_OrderServiceN.ListOfOrderResponse listData4 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData4.orderStatus = 'pending';
                    listData4.orderNumber = 'C300009902';
                    listData4.isCancelModifyEligible = true;
                    listData4.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData4.orderDate = '2021-09-02';
                     listData4.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData4.orderSummary.merchandiseSubTotal = '$225.00';
                    listData4.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData4.orderSummary.orderTotal = '$241.88';
                    listData4.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData4.orderSummary.salesTax = '$16.88';
                    listData4.orderSummary.shippingHandling = '$0.00';
                    listData4.orderSummary.isRefundTotal = false;
                    listData4.orderSummary.showTax = true; 
                    orderWithEmail.add(listData4);
                    
                    NF_OrderServiceN.ListOfOrderResponse listData5 = new NF_OrderServiceN.ListOfOrderResponse();
                    listData5.orderStatus = 'pending';
                    listData5.orderNumber = 'C300009902';
                    listData5.isCancelModifyEligible = true;
                    listData5.orderDateTime = String.valueOf(System.today().adddays(-75));//'2020-08-21';
                    listData5.orderDate = '2021-09-02';
                    listData5.orderSummary = new NF_OrderServiceN.orderSummary();
                    // listData5.orderSummary.merchandiseSubTotal = '$225.00';
                    listData5.orderSummary.autoDiscountSubTotal = '$225.00';
                    // listData5.orderSummary.orderTotal = '$241.88';
                    listData5.orderSummary.totalPaymentToBeCharged = '$241.88';
                    listData5.orderSummary.salesTax = '$16.88';
                    listData5.orderSummary.shippingHandling = '$0.00';
                    listData5.orderSummary.isRefundTotal = false;
                    listData5.orderSummary.showTax = true; 
                    orderWithEmail.add(listData5);
                    String responseString = JSON.serialize(orderWithEmail);
                    
                    response.setBody(responseString); 
                }else{
                    response.setStatusCode(400);
                    response.setStatus('Error');
                    
                    String responseString = 'Please re-enter the information passed in api.';
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
        // osObj.orderSummary.merchandiseSubTotal = '$225.00';
        osObj.orderSummary.autoDiscountSubTotal = '$225.00';
        // osObj.orderSummary.orderTotal = '$241.88';
        osObj.orderSummary.totalPaymentToBeCharged = '$241.88';
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
    
    public static NF_OrderMockAPI.MockData getMockData(){
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
        NF_OrderMockAPI.MockData dataWrp = new NF_OrderMockAPI.MockData();
        dataWrp.shipToList = shipToList;
        dataWrp.firstNameList = firstNameList;
        dataWrp.lastNameList = lastNameList;
        dataWrp.paymethodList = paymentMethod;
        return dataWrp;
    } 
    public static List<NF_OrderServiceN.OrderResponse> getGenratedDataResponse(NF_OrderMockAPI.MockData mockData, Integer maxReocds){
        
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
            osObj.orderDate.year = 2021;
            // osObj.orderSummary.orderTotal = String.valueOf((i*2545).format());  
            osObj.orderSummary.totalPaymentToBeCharged = String.valueOf((i*2545).format());  
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