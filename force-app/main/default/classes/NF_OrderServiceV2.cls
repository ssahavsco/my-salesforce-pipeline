public class NF_OrderServiceV2{
    /**
     * @description new wrapper class for responses with new api calls
     */
	public orderDate orderDate;
	public String orderDateTime;	
	public String orderNumber;	
	public orderSummary orderSummary;
	public String orderType;	
	public String orderStatus;	
	public boolean isLegacyOrder;
	public boolean isEShop;
	public payments[] payments;
	public shipments[] shipments;
	
	public boolean isCancelModifyEligible;
	class orderDate {
		public Integer month;	
		public Integer day;	
		public Integer year;	
	}
	class orderSummary {
		public String merchandiseSubTotal;	
		public String orderTotal;	
		public String salesTax;	
		public String shippingHandling;	
		public boolean isRefundTotal;
		public boolean showTax;
	}
	class payments {
		public String paymenttype;	
		public String paymentnumber;	
		public String amount;	
	}
	class shipments {
		public String alternatePickupPerson;	
		public lineItems[] lineItems;
		public String status;	
		public statusDate statusDate;
		public address address;
		public pickUpStore pickUpStore;
		public method method;
	}
	class lineItems {
		public String family;	
		public String name;	
		public String variantId;	
		public String productImage;	
		public String swatchImage;	
		public boolean isAvailable;
		public String status;	
		public statusDate statusDate;
		public attributes attributes;
		public quantity quantity;
		public price price;
		public String url;	
	}
	class statusDate {
		public Integer month;	
		public Integer day;	
		public Integer year;	
	}
	class attributes {
		public choice choice;
		public size1 size1;
		public size2 size2;
		public sendDate sendDate;
	}
	class choice {
		public String value;	
	}
	class size1 {
		public String label;	
		public String value;	
	}
	class size2 {
	}
	class sendDate {
	}
	class quantity {
		public Integer selected;	
	}
	class price {
		public unitPrice unitPrice;
		public totalPrice totalPrice;
		public String priceType;	
	}
	class unitPrice {
		public String originalPrice;	
	}
	class totalPrice {
		public String originalPrice;	
	}
	class address {
		public String countryCode;	
		public String streetAddress1;	
		public String city;	
		public String region;	
		public String postalCode;	
		public String phone;	
	}
	class pickUpStore {
		public String storeId;	
		public String name;	
		public address address;
		public hours[] hours;
	}
	class hours {
		public Integer day;	
		public boolean isOpen;
		public String open;	
		public String close;	
	}
	class method {
    }
}