@isTest
public class GERefundHistoryRequestWrapperTest {
    @isTest
    static void requestPayloadTest(){
        String json = '{"orderId":"12345","orderTypeId":"typeA","historyNotReqd":false}';
        GERefundHistoryRequestWrapper result = GERefundHistoryRequestWrapper.jsonParse(json);
    }
}