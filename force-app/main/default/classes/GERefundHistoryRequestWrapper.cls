/**
 *  Created by : Sumit Saha
 */

public class GERefundHistoryRequestWrapper {
    public String orderId;
    public String orderTypeId;
    public Boolean historyNotReqd;

    public static GERefundHistoryRequestWrapper jsonParse(String json) {
		return (GERefundHistoryRequestWrapper) System.JSON.deserialize(json, GERefundHistoryRequestWrapper.class);
	}
}