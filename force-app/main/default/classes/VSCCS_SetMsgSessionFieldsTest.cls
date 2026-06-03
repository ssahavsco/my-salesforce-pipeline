@IsTest
public class VSCCS_SetMsgSessionFieldsTest {
	
    @IsTest
    public static void testSetMsgSessionMethod(){
        String routableId = VS_UtilTest.createMessagingSession();
        VSCCS_SetMsgSessionFields.Input input = new VSCCS_SetMsgSessionFields.Input();
        input.routableId = routableId;
        input.associateHoldMessage = 'test';
        input.isAuthUser = true;
        input.isAwaitingPayment = false;
        input.orderNumber = 'W123456789';
        input.userComments = 'test comment';
        input.userOfferCode = '';
        Test.startTest();
        VSCCS_SetMsgSessionFields.setMessagingSessionFields(new List<VSCCS_SetMsgSessionFields.Input>{input});
        Test.stopTest();
    }
    
    @IsTest
    public static void testFailedMethod(){
        String routableId = 'test';
        VSCCS_SetMsgSessionFields.Input input = new VSCCS_SetMsgSessionFields.Input();
        input.routableId = routableId;
        input.associateHoldMessage = 'test';
        input.isAuthUser = true;
        input.isAwaitingPayment = false;
        input.orderNumber = 'W123456789';
        input.userComments = 'test comment';
        input.userOfferCode = '';
        Test.startTest();
        VSCCS_SetMsgSessionFields.setMessagingSessionFields(new List<VSCCS_SetMsgSessionFields.Input>{input});
        Test.stopTest();
    }
}