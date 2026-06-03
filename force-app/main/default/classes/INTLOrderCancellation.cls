/** International Project to Integrate with GE Service
 *  Created By:  ssaha@victoria.com | Date: 19-APR-24
 *  Modified By:  
 */

public class INTLOrderCancellation {

    public String Process;
	public String OrderId;
	public List<OrderLine> OrderLine;

	public String ReasonId;
	public String Comments;
	public String AssociateId;
	public String RefundId;

	public class OrderLine {
		public String OrderLineId;
		public String Quantity;
		public String Comments;
		public String ReasonId;
		public String AssociateId;
	}

	public INTLOrderCancellation(){
		this.OrderLine = new List<OrderLine>();
	}
	
	public static INTLOrderCancellation parse(String json) {
		return (INTLOrderCancellation) System.JSON.deserialize(json, INTLOrderCancellation.class);
	}
}