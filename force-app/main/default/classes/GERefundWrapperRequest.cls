/** International Project to Integrate with GE Service
 *  Created By:  ssaha@victoria.com | Date: 19-APR-24
 *  Modified By:  
 */

public class GERefundWrapperRequest {

	public String orderId;
	public String orderType;
	public String reasonCode;
	public String refundCondition;
	public String comments;
	public String currencyCode;
	public String actionByUser;
	public shipping shipping;
	public DutiesTaxesRefund dutiesTaxesRefund;
	public List<LineItems> lineItems;

	public class DutiesTaxesRefund {
		public String type;
		public Double amount;
	}	

	public  GERefundWrapperRequest(){
		this.lineItems = new List<LineItems> ();
		this.shipping = new shipping();
		this.dutiesTaxesRefund = new DutiesTaxesRefund();
	}

	public class LineItems {
		public String id;
		public String refundBasisType; // Amount, Percent, Quantity.
		public Double refundBasisValue;
		public String reasonCode;
		public String comments;
		public String refundCondition;
		public String sku;
	}

	public class Shipping {
		public String type; 
		public Double amount; 
	}

	public static GERefundWrapperRequest jsonParse(String json) {
		return (GERefundWrapperRequest) System.JSON.deserialize(json, GERefundWrapperRequest.class);
	}
}