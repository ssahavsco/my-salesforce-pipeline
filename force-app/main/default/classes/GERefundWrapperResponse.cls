/** International Project to Integrate with GE Service
 *  Created By:  ssaha@victoria.com | Date: 19-APR-24
 *  Modified By:  
 */

public class GERefundWrapperResponse {

	public class Components {
		public String type;
		public String amountInShopperCurrency;
		public String amountInMerchantCurrency;
	}

	public Boolean success;
	public String refundId;
	public String totalAmountInShopperCurrency;
	public String totalAmountInMerchantCurrency;
	public List<Components> components;

	public GERefundWrapperResponse(){
		this.components = new List<Components> ();
	}

	public String error;
	public String message;
	public String code;

	public String customMessage;
	public String httpStatusCode;

	public String messageID;
	
	public static GERefundWrapperResponse jsonParse(String json) {
		return (GERefundWrapperResponse) System.JSON.deserialize(json, GERefundWrapperResponse.class);
	}
}