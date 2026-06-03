/****************************************************************************************************************
* Program Name         : LoyaltyTransactionSearch
* Description          : This class is used to get the Order transaction details to phist.
* Version              : 1.1
* Modification Log     : 17 Aug, 2022 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   SK_01          DP-37893       1.1       Sumit Saha      08/17/2022     This class is used to get the Order transaction details to phist.
*   SK_02          DP-61770       1.2       Sumit Saha      10/26/2022     Fixing the Paymethod  
*                                                                                                                                 
*****************************************************************************************************************/


public with sharing class LoyaltyTransactionSearch {

    public static String orderType;
    public static String paymentMethod;

    @AuraEnabled
    public static string getOrderTransactionSearch(string transactionNumber){
    
    PHISTStoreTransactionSearch.SearchData obj = new PHISTStoreTransactionSearch.SearchData();    
    Input input =  (Input)  JSON.deserializeStrict(String.valueof(transactionNumber), Input.class) ;

    obj.storeTransactionId = input.transactionNumber;
    obj.searchType = 'searchByStoreTransactionId';

    String response =  PHISTStoreTransactionSearch.getOrderHistory(JSON.serialize(obj));
    PhistResponse phistResponse = (PhistResponse) JSON.deserialize(response, PhistResponse.class) ;

    Order order = new Order();
    Response apiResponse = new Response();

    orderType = orderType(input.transactionNumber);
      
     if (phistResponse.success) {
      paymentMethod = orderPaymentDetails(phistResponse);  

      order.orderNumber = phistResponse.successData.transactions[0].OrderId;
      order.loyaltyId = orderType == 'STORE' ? phistResponse.successData.transactions[0].Extended.LoyaltyID : phistResponse.successData.transactions[0].LoyaltyNumber ;
      order.purchaseDetails.dateOfPurchase = phistResponse.successData.transactions[0].CapturedDate;
      order.purchaseDetails.paymentMethod = paymentMethod;
      order.purchaseDetails.totalAmount =  phistResponse.successData.transactions[0].OrderTotal ;

      LoyaltyAccountIntegration.GetCustomerWrapper customer = new  LoyaltyAccountIntegration.GetCustomerWrapper();

        if ( !String.isEmpty(order.loyaltyId) ) {
            customer.loyaltyId.id = order.loyaltyId ; // phistResponse.successData.transactions[0].Extended.LoyaltyID; 
            customer.direct = false;
            customer.brand = 'VSS';
            
            String customerLoyaltyInfo =  LoyaltyAccountIntegration.loyaltyDetailsLookup(JSON.serialize(customer));
            LoyaltyAccountIntegration.GetCustomerLoyalty res = (LoyaltyAccountIntegration.GetCustomerLoyalty ) JSON.deserialize(customerLoyaltyInfo, LoyaltyAccountIntegration.GetCustomerLoyalty.Class);

            if (res.response.statusCode == 200 && !res.customer.isEmpty() ) {
                order.firstName = res.customer[0].firstName;
                order.lastName = res.customer[0].lastName;
                order.email = res.customer[0].email;
                order.phone = res.customer[0].phone;
                apiResponse.statusCode = res.response.statusCode;
                apiResponse.statusMessage = res.response.statusMessage;
            } 
             else {
                apiResponse.statusMessage = 'No Customer records found for Loyalty Id: ' + phistResponse.successData.transactions[0].Extended.LoyaltyID;
                apiResponse.statusCode = res.response.statusCode;  
                }
        }
        else {
            apiResponse.statusMessage = 'No Loyalty Id is associated with this order ' + phistResponse.successData.transactions[0].OrderId;
            apiResponse.statusCode = 200;
        }    
    }
    else {
        apiResponse.inputOrderNumber = input.transactionNumber;
        apiResponse.statusCode = 404;
        apiResponse.statusMessage = phistResponse.errorMessage;
        apiResponse.statusResponseCode = 'PUR-NOT-FOUND';
    }

    SearchResult src = new SearchResult();
    src.searchResult = order;
    src.response = apiResponse;

    System.debug('=====> ' + JSON.serialize(src));   

    return JSON.serialize(src);
    }

    public static String orderType(String transactionNumber){
        Pattern digitalOrderPattern = Pattern.compile('[C|W|S|M|B|R|E]*[0-9]{9}');
        Pattern storeOrderPattern = Pattern.compile('5[0-9]{19}');
        Matcher digitalMatch = digitalOrderPattern.matcher(transactionNumber);
        Matcher storeMatch = storeOrderPattern.matcher(transactionNumber);

        Boolean isDigitalOrder = digitalMatch.matches();
        Boolean isStoreOrder = storeMatch.matches();

        String orderType = isDigitalOrder ? 'DIGITAL' : isStoreOrder ? 'STORE' : null;
        return orderType;
    }

    public static String orderPaymentDetails(PhistResponse phistResponse){
        
        String paymentMethod;
        Set<String> setPaymentMethod = new Set<String>();

        if ((phistResponse.successData.transactions[0].Payment.size() > 0 && phistResponse.successData.transactions[0].Payment[0].PaymentMethod != null) && orderType == 'STORE') {
            for (Integer i = 0; i < phistResponse.successData.transactions[0].Payment.size(); i++) {
                for (Integer j = 0; j < phistResponse.successData.transactions[0].Payment[i].PaymentMethod.size(); j++) {
                    if (String.isEmpty(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].CardTypeId)) {
                        setPaymentMethod.add(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].PaymentType.PaymentTypeId);
                        setPaymentMethod.add(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].CardType.CardTypeId );
                    }
                    else {
                        setPaymentMethod.add(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].CardTypeId);
                    }
                    setPaymentMethod.remove(null);
                }
            }
        }
        else if ((phistResponse.successData.transactions[0].Payment.size() > 0 && phistResponse.successData.transactions[0].Payment[0].PaymentMethod != null) && orderType == 'DIGITAL') {
            for (Integer i = 0; i < phistResponse.successData.transactions[0].Payment.size(); i++) {
                for (Integer j = 0; j < phistResponse.successData.transactions[0].Payment[i].PaymentMethod.size(); j++) {
                    if (String.isEmpty(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].CardType.CardTypeId)) {
                        setPaymentMethod.add(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].PaymentType.PaymentTypeId);
                    }
                    else {
                        setPaymentMethod.add(phistResponse.successData.transactions[0].Payment[i].PaymentMethod[j].CardType.CardTypeId);
                    }
                    
                    setPaymentMethod.remove(null);
                }
            }
        }
        paymentMethod = !String.isEmpty( (((String) setPaymentMethod.toString()).remove('{')).remove('}') ) ?  (((String) setPaymentMethod.toString()).remove('{')).remove('}') : null;
        return paymentMethod;
    }

	public class Input{
        public String transactionNumber;
        public String orderType;
    }

    public class PhistResponse{
        public Boolean success;
        public String errorMessage;
        public PHISTorderTransactionWrapper.ResponseTransactions successData;
    }

    public class SearchResult{
        public Order searchResult;
        public Response response;

        SearchResult(){
            this.searchResult = new Order();
            this.response = new Response();
        }
    }

    public class Order{
        public string firstName;
        public string lastName;
        public string email;
        public string phone;
        public string loyaltyId;
        public string orderNumber;
        public PurchaseDetails purchaseDetails;

            Order(){
                this.purchaseDetails = new PurchaseDetails();
            }
    }
    
    public class PurchaseDetails{
        public String dateOfPurchase;
        public String paymentMethod;
        public Decimal totalAmount;
        }

    public class Response{
        public String inputOrderNumber;
        public Integer statusCode;
        public String statusMessage;
        public String statusResponseCode;
    }    
}