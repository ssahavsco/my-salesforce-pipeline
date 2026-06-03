/**
* Created by adamundus on 9/16/20.
*/

@IsTest
private class NF_ReassignCaseOwnerTest {
    static String chatkey = '';

    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        User tuser = new User(
            LastName = 'Platform Integration User TestClass1001',
            Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert tuser;
        
        System.runAs(tuser) {
            LiveChatTranscript t1 = new LiveChatTranscript();
            LiveChatVisitor lcv = new LiveChatVisitor();
            
            insert lcv;
            t1.LiveChatVisitorId = lcv.Id;
            t1.ChatKey = 'somechatkey';
            
            insert t1;
            //system.debug(t1);
            chatkey =t1.ChatKey; 
             
            Case c = new Case();
            c.OwnerId = tuser.Id;
            insert c;
            t1.CaseId = c.Id;
            update t1;
            
            System.debug(tuser.Id+'--AM--'+[SELECT Id, CreatedById FROM LiveChatTranscript][0].CreatedById);
        }
    }

    @IsTest
    static void reassignCase() {
        User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();

        Map<Id, LiveChatTranscript> input = new Map<Id, LiveChatTranscript>();
        LiveChatTranscript lct;

        Id ownerId = '00501000000SKVuAAO';

        System.runAs(platformIntegrationUser){
            lct = [SELECT Id, OwnerId, CaseId, CreatedById FROM LiveChatTranscript  LIMIT 1];
            System.debug(lct.CreatedById);
            lct.OwnerId = ownerId;
        }

        input.put(ownerId, lct);
        
        Test.startTest();
        System.assertEquals(false, NF_ReassignCaseOwner.reassignCaseOwner(input), 'should have value');
        Test.stopTest();
    }

    @IsTest
    static void addCase(){
        List<Case> cases = new List<Case>();
        LiveChatTranscript transcript = NF_UtilTest.insertLiveChatTranscript('abc', '', '');

        NF_ReassignCaseOwner.addCase(cases, transcript);
    }


    @IsTest
    static void negativeTest1(){
        System.assertEquals(false, NF_ReassignCaseOwner.reassignCaseOwner(null));
    }

    @IsTest
    static void negativeTest2(){
        NF_ReassignCaseOwner.addCase(null, null);
    }
}