/*****************************************************************************************************@@
Class Name     :  NF_SocialPostSyncBatchTest
Purpose        :  Test class for NF_SocialPostSyncBatch
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version            
                                      
*********************************************************************************************************/
@isTest
public with sharing class NF_SocialPostSyncBatchTest{
    
    @TestSetup
    static void makeData(){
        Test.startTest();

        SocialPostConfig__c spApi = new SocialPostConfig__c();
        spApi.Access_Token__c = 'accesstoken';
        spApi.Access_Token_Endpoint__c = 'https://api.socialstudio.radian6.com/oauth/token';
        spApi.Access_Token_Expire_Time__c = System.now().addSeconds(3600);
        spApi.Client_Id__c = 'clientid';
        spApi.Client_Secret__c = 'clientsecret';
        spApi.Post_Endpoint__c = 'https://api.socialstudio.radian6.com/v3/posts';
        spApi.Refresh_Token__c = 'refreshtoken';
        spApi.Social_Studio_Password__c = 'username';
        spApi.Social_Studio_Username__c = 'password';
        insert spApi;

        SocialPost sp = new SocialPost();
        sp.Name = 'TestPost';
        sp.R6TopicId = '12345';
        sp.R6PostId = '1234567890';
        sp.HarvestDate = System.today();
        insert sp;

        Test.stopTest();
    }

    //Case:1 Custom setting has a valid access token 
    @isTest
    static void validate_1(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Database.executeBatch(new NF_SocialPostSyncBatch());
        Test.stopTest();
        List<SocialPost> spList = [SELECT Id, EngagementLevel, PostTags, Assigned_Associate__c, Last_Updated_By_API__c FROM SocialPost];
        System.assertEquals(1, spList.size());
        System.assert(spList[0].Last_Updated_By_API__c != null);
        System.assert(spList[0].PostTags == 'Brand Love');
    }

    //Case:2 Custom setting has a expired access token 
    @isTest
    static void validate_2(){
        SocialPostConfig__c spApi = [SELECT Id, Access_Token_Expire_Time__c FROM SocialPostConfig__c];
        spApi.Access_Token_Expire_Time__c = System.now().addSeconds(-3600);
        update spApi;
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Database.executeBatch(new NF_SocialPostSyncBatch());
        Test.stopTest();
        List<SocialPost> spList = [SELECT Id, EngagementLevel, PostTags, Assigned_Associate__c, Last_Updated_By_API__c FROM SocialPost];
        System.assertEquals(1, spList.size());
        System.assert(spList[0].Last_Updated_By_API__c != null);
        System.assert(spList[0].PostTags == 'Brand Love');
    }

    //Case:3 Custom setting has a no refresh token 
    @isTest
    static void validate_3(){
        SocialPostConfig__c spApi = [SELECT Id, Refresh_Token__c,Access_Token__c FROM SocialPostConfig__c];
        spApi.Refresh_Token__c = null;
        spApi.Access_Token__c = null;
        update spApi;
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Database.executeBatch(new NF_SocialPostSyncBatch());
        Test.stopTest();
        List<SocialPost> spList = [SELECT Id, EngagementLevel, PostTags, Assigned_Associate__c, Last_Updated_By_API__c FROM SocialPost];
        System.assertEquals(1, spList.size());
        System.assert(spList[0].Last_Updated_By_API__c != null);
        System.assert(spList[0].PostTags == 'Brand Love');
    }

    //Mock Response Class
    public class Mock implements HttpCalloutMock{
        Integer statusCode;

        public Mock(){
            this.statusCode = 200;
        }

        public Mock(Integer statusCode){
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();

            if(req.getEndpoint().contains('/oauth/token')){
                
                NF_SocialPostSyncBatch.AuthResponse resp = new NF_SocialPostSyncBatch.AuthResponse();
                resp.access_token = 'new_access_token';
                resp.refresh_token = 'new_refresh_token';
                resp.expires_in = 3600;
                res.setBody(JSON.serialize(resp));    

            } else if(req.getEndpoint().contains('/v3/posts')){

                NF_SocialPostSyncBatch.PostsResponse pr = new NF_SocialPostSyncBatch.PostsResponse();
                NF_SocialPostSyncBatch.Tag tag = new NF_SocialPostSyncBatch.Tag();
                tag.Id = '1234';
                tag.value = 'Brand Love';
                NF_SocialPostSyncBatch.Post post = new NF_SocialPostSyncBatch.Post();
                post.id = '1234567890';
                post.tags = new List<NF_SocialPostSyncBatch.Tag>{tag};
                pr.data = new List<NF_SocialPostSyncBatch.Post>{post};

                res.setBody(JSON.serialize(pr));    
            }
            
            res.setStatusCode(statusCode);
            return res;
        }
    }
}