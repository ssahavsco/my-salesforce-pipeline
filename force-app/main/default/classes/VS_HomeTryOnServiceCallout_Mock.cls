@isTest
global class VS_HomeTryOnServiceCallout_Mock implements HttpCalloutMock {
    
    public String type;
    public String variation;
    public String variatonType;
    global VS_HomeTryOnServiceCallout_Mock(final String type, final String variation) {
        this.type = type;
        this.variation = variation;
    }
    global VS_HomeTryOnServiceCallout_Mock(final String type, final String variation,String variatonType) {
        this.type = type;
        this.variation = variation;
        this.variatonType = variatonType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(401);
        
        if (type.equals('getHTODashBoardDetails')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validGetHTODashBoardDetails'));
                res.setStatusCode(204);
            }else if (variation.equals('validStatusWithVaritation')) {
                res.setBody(getBodyResponse('validGetHTODashBoardDetails',variatonType));
                res.setStatusCode(200);
            }else if (variation.equals('invalidStatus')) {
                res.setBody(getBodyResponse('invalidgetHTODashBoardDetails'));
                res.setStatusCode(400);
            }else {
                res.setBody(getBodyResponse('invalidgetHTODashBoardDetails'));
            }
        } else if (type.equals('extendKeepReturnBox')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validextendKeepReturnBox'));
                res.setStatusCode(200);
            } else {
                res.setBody(getBodyResponse('invalidextendKeepReturnBox'));
            }
        } else if (type.equals('markBoxAsDelivered')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validmarkBoxAsDelivered'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidmarkBoxAsDelivered'));
            }
        } else if (type.equals('udpateBoxFrequency')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validudpateBoxFrequency'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidudpateBoxFrequency'));
            }
        } else if (type.equals('skipBox')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validskipBox'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidskipBox'));
            }
        } else if (type.equals('pauseSubscription')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validpauseSubscription'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidpauseSubscription'));
            }
        } else if (type.equals('unSubscription')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validunSubscription'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidunSubscription'));
            }
        } else if (type.equals('resumeSubscrition')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validresumeSubscrition'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidresumeSubscrition'));
            }
        } else if (type.equals('getNewAccessToken')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validAccessToken'));
                res.setStatusCode(204);
            } else {
                res.setBody(getBodyResponse('invalidAccessToken'));
            }
        }  else if (type.equals('getOrderhistoryByCustomerId')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validOrderhistoryByCustomerId'));
                res.setStatusCode(200);
            } else {
                res.setBody(getBodyResponse('invalidOrderhistoryByCustomerId'));
                res.setStatusCode(200);
            }
        } else if (type.equals('boxHistoryByEmail')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('validboxHistoryByEmail'));
                res.setStatusCode(200);
            } else {
                res.setBody(getBodyResponse('invalidboxHistoryByEmail'));
            }
        }else if (type.equals('invokeDashboardService')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('invokeDashboardServiceValid'));
                res.setStatusCode(200);
            } else {
            res.setBody(getBodyResponse('invokeDashboardServiceboxstanceInValid'));
            
            }
        }else if (type.equals('invokeGetHtoOrderValid')) {
            if (variation.equals('valid')) {
                res.setBody(getBodyResponse('invokeGetHtoOrderValid'));
                res.setStatusCode(200);
            } else {
            res.setBody(getBodyResponse('invokeGetHtoOrderInValid'));
            
            }
        }  
        return res;
    }
    
    public static String getBodyResponse(String type) {
        String result = '';
        
        if (type.equals('validGetHTODashBoardDetails')) {
            result = '{ "stance": "generic_error","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": false, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": true, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        } else if (type.equals('invalidgetHTODashBoardDetails')) {
            result = '{ "error": "Unauthorized-access", "message": "Resource Not Found" }';
        } else if (type.equals('validextendKeepReturnBox')) {
            result = '{ "Success": "", "Message": "Sucess Response" }';
        } else if (type.equals('invalidextendKeepReturnBox')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
        } else if (type.equals('validmarkBoxAsDelivered')) {
            result = '{ "Success": "", "Message": "Sucess Response" }';
            
        } else if (type.equals('invalidmarkBoxAsDelivered')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
            
        } else if (type.equals('validudpateBoxFrequency')) {
            result = '{ "Success": "", "Message": "Sucess Response" }';
            
        } else if (type.equals('invalidudpateBoxFrequency')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
            
        } else if (type.equals('validskipBox')) {
            
            result = '{ "Success": "", "Message": "Sucess Response" }';
        } else if (type.equals('invalidskipBox')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
            
        } else if (type.equals('validpauseSubscription')) {
            result = '{ "Success": "", "Message": "Sucess Response" }';
            
        } else if (type.equals('invalidpauseSubscription')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
            
        } else if (type.equals('validunSubscription')) {
            result = '{ "Success": "", "Message": "Sucess Response" }';
            
        } else if (type.equals('invalidunSubscription')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
            
        }else if (type.equals('validresumeSubscrition')) {
            result = '{ "Success": "", "Message": "Sucess Response" }';
            
        } else if (type.equals('invalidresumeSubscrition')) {
            result = '{"error": "application-error","message": "Server encountered an error processing the request. Please try again later."}';
        } else if (type.equals('validAccessToken')) {
            result = '{ "access_token": "MZAG_EILP1MKFVMZQ0SZCQ", "expires_in": 7200, "token_type": "Bearer" }';
        } else if (type.equals('invalidAccessToken')) {
            result = '{ "error": "invalid_client", "error_description": "Client authentication failed" }';
        } else if(type.equals('validOrderhistoryByCustomerId')){
            result =  '{ "Success": "","StatusCode":"200", "Message": "Sucess Response" }';
        }else if(type.equals('invalidOrderhistoryByCustomerId')){
            result = '{ "error": "invalid_customerId","StatusCode":"201", "error_description": "Invalid Customer Id" }';
        }else if(type.equals('boxHistoryByEmail')){
            result =  '{ "Success": "","StatusCode":"200", "Message": "Sucess Response" }';
        }else if(type.equals('invalidboxHistoryByEmail')){
            result = '{ "error": "invalid_customerId", "error_description": "Invalid Customer Id" }';
        }else if(type.equals('invokeDashboardServiceValid')){
           result = '{ "stance": "generic_error","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": false, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": true, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        }else if(type.equals('invokeDashboardServiceboxstanceInValid')){
           result = '{ "stance": "","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": false, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": true, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        }else if (type.equals('invokeGetHtoOrderValid')) {
            result = '{ "stance": "generic_error","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": false, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": true, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        }
        
        
        
        return result;
    }
    public static String getBodyResponse(String type,String variationType) {
        String result = '';
        if (type.equals('validGetHTODashBoardDetails') && variationType.equalsIgnoreCase('pauseInfo')) {
            result = '{ "stance": "generic_error","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": true, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": true, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        } else if (type.equals('validGetHTODashBoardDetails') && variationType.equalsIgnoreCase('isHtoSubscribed')) {
            result = '{ "stance": "generic_error","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": false, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": true, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        } else if (type.equals('validGetHTODashBoardDetails') && variationType.equalsIgnoreCase('isHtoNotSubscribed')) {
            result = '{ "stance": "generic_error","StatusCode":"200", "show": { "skipInfo": false, "pauseInfo": false, "unsubscribeInfo": false }, "estimatedDelivery": {}, "memberDetails": { "firstName": "SHARATH", "lastName": "KUMAR", "phone": "8201382903" }, "membership": { "isHtoSubscribed": false, "subscriptionDate": 1690833496, "boxFrequency": "monthly", "blockList": false, "canPauseLimited": false, "placementAfterPause": { "option2months": { "month": 10, "year": 2023 }, "option3months": { "month": 11, "year": 2023 } }, "shippingAddress": { "streetAddress1": "Street1", "streetAddress2": "Street2", "streetAddress3": "Street3", "pobox": "43219", "city": "CMH", "state": "OH", "postalCode": "43219", "region": "OH", "province": "US", "countryCode": "US" }, "cardDetails": { "displayPaymentType": "Visa", "number": "1111", "type": "Visa", "expirationMonth": "2", "expirationYear": "26" }, "subscriberId": "2061" }, "skipDetails": { "skipped": {}, "canSkip": { "fromDashboard": false, "fromBoxManagement": false, "skipMonth": 8, "skipYear": 2023 } }, "nextBox": {}, "boxDetails": { "boxId": "647", "boxMonth": 7, "boxYear": 2023, "boxNumber": 1, "deliveredAt": 1688601600, "keepReturnUntil": 1689552000, "eligibleForKeepReturn": true, "productsInBox": [ { "variantId": "26359431", "genericId": "11194978", "colorCode": "52NI", "image": { "src": "tif/e6/76/e676e73aeeae4867ba3c58613aa15a8e/1119497852NI_OM_F" } }, { "variantId": "26359435", "genericId": "11194978", "colorCode": "54A2", "image": { "src": "tif/9d/71/9d71537d507c4b848ae6c8afb6195274/1119497854A2_OM_F" } }, { "variantId": "26359496", "genericId": "11194977", "colorCode": "54A2", "image": { "src": "tif/4c/4c/4c4c0b2d8c574e958387e2cd3fdc3137/1119497754A2_OM_F" } } ] } }';
        }
        return result;
    }
}