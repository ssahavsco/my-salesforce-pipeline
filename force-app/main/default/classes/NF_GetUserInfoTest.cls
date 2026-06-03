/**
 * Created by adamundus on 9/16/20.
 */

@IsTest
private class NF_GetUserInfoTest {
    
    Public Static String getRoutableId() {
        String routableId = NF_UtilTest.createMessagingSession();
        MessagingSession msgSession = [SELECT Id, Email__c FROM MessagingSession WHERE Id =: routableId LIMIT 1];
        msgSession.Email__c = 'hmishra@victoria.com';
        msgSession.Language_Code__c = 'fr_CA';
        update msgSession;
        return routableId;
    }
    
    @IsTest
    static void testBehavior() {
        
        List<NF_GetUserInfo.Input> inputs = new List<NF_GetUserInfo.Input>();
        NF_GetUserInfo.Input inp = new NF_GetUserInfo.Input();
        inp.routableId = getRoutableId();
        inputs.add(inp);

        Test.startTest();
        List<NF_GetUserInfo.Output> out = NF_GetUserInfo.getUserInfo(inputs);
        Test.stopTest();

        System.assertEquals('hmishra@victoria.com',out[0].userEmail, 'should have correct email');
    }
}