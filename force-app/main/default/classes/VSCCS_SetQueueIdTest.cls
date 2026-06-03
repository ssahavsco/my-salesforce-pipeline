@IsTest
public class VSCCS_SetQueueIdTest {
    @IsTest
    public static void setQueueTestMethod(){
        String routableId = NF_UtilTest.createMessagingSession();
        VSCCS_SetQueueId.Input input = new VSCCS_SetQueueId.Input();
        input.isInternational = true;
        input.routableId = routableId;
        input.isUHVCustomer = false;
        input.orderEmail = '';
        Test.startTest();
        VSCCS_SetQueueId.setQueueId(new List<VSCCS_SetQueueId.Input>{input});
        Test.stopTest();
    }
    @IsTest
    public static void setQueueForUHVTestMethod(){
        String routableId = NF_UtilTest.createMessagingSession();
        VSCCS_SetQueueId.Input input = new VSCCS_SetQueueId.Input();
        input.isInternational = false;
        input.routableId = routableId;
        input.isUHVCustomer = true;
        input.orderEmail = '';
        Test.startTest();
        VSCCS_SetQueueId.setQueueId(new List<VSCCS_SetQueueId.Input>{input});
        Test.stopTest();
    }
}