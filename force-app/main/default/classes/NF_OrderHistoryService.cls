/**
 * Created by apoorvrajput on 9/3/20.
 */

public class NF_OrderHistoryService {
    public class OrderHistoryResponse{
        public String orderDate {get; set;}
        public String orderNumber {get; set;}
        public String orderStatus {get; set;}
        public Boolean isCancelModifyEligible {get; set;}
        public List<Shipment> shipments {get; set;}

    }
    public class Shipment {
        public String status {get; set;}
        public List<Product> products {get;set;}
        public String trackingURL {get;set;}
        public String statusDate {get;set;}
    }
    public class Product {
        public String image {get;set;}
        public String shortDescription {get;set;}
    }
}