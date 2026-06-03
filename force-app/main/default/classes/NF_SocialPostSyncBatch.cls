/*****************************************************************************************************@@
Class Name     :  NF_SocialPostSyncBatch
Purpose        :  Batch to sync social post records from social studio server
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       Tara                                       Original Version            

@Testsuite:  {NF_SocialPostSyncBatchTest}                                       
*********************************************************************************************************/
public with sharing class NF_SocialPostSyncBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts{

    private Set<String> processedTopicIds = new Set<String>();
    private String accessToken;
    private SocialPostConfig__c spApi = SocialPostConfig__c.getOrgDefaults();
    private Integer chunkcount = 0;
    private String log = '';

    /**
     * @description: This method makes call for the access token and queries last 24Hr created socialPost reocrds.
     */
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(spApi != null){
            accessToken = getAccessToken();
        }
        //batch over a set of SocialPost records created in the past 24 hours
        String query = 'SELECT Id, EngagementLevel, PostTags, Assigned_Associate__c, R6TopicId, R6PostId, HarvestDate FROM SocialPost';
        query += ' WHERE R6TopicId <> null AND createdDate >= LAST_N_DAYS:1 AND (Last_Updated_By_API__c = null OR Last_Updated_By_API__c <= LAST_N_DAYS:1) ORDER BY R6TopicId';
        return Database.getQueryLocator(query);
    }
    
    /**
     * @description: This method executes a single chunk with limited scope of records and get them updated with server.
     */
    public void execute(Database.BatchableContext BC, List<SocialPost> scope){
        chunkcount++;
        log += chunkcount;

        if(accessToken != null){
            List<SocialPost> postToUpdate = new List<SocialPost>();
            try{
                for(SocialPost sp : scope){
                    if(Limits.getCallouts() < Limits.getLimitCallouts()){
                        postToUpdate.add(updateSocialPostFromServer(sp, accessToken));
                    } else {
                        log += 'Callout Limit Exceeded,';
                        break;
                    }
                }
            } catch (Exception e){
                log+= e.getMessage() + ':' + e.getLineNumber() +',';
            }

            log += 'Size: ' + postToUpdate.size();
            if(!postToUpdate.isEmpty()){
                update postToUpdate;
            }
        }
    }

    /**
     * @discription: This method will be executed once after the batch will be finished.
     */
    public void finish(Database.BatchableContext BC){
        System.debug('Log: '+ log);
        Logger.error(log);
        Logger.saveLog();
    }

    /**
     * @description: This method run the batch on scheduled basis.
     */
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new NF_SocialPostSyncBatch(), 40);
    }
    
    /**
     * @description: This method makes hit to fetch accessToken if it is not-present/expired. 
     */
    private string getAccessToken(){        
        SocialPostConfig__c spApi = SocialPostConfig__c.getOrgDefaults();
        String accessToken = spApi.Access_Token__c;
        String refreshToken = spApi.Refresh_Token__c;
        String authURL = spApi.Access_Token_Endpoint__c;
        String clientId = spApi.Client_Id__c;
        String clientSecret = spApi.Client_Secret__c;
        String postURL = spApi.Post_Endpoint__c;
        String usrname = spApi.Social_Studio_Username__c;
        String password = spApi.Social_Studio_Password__c;
        Boolean isValidToken = spApi.Access_Token_Expire_Time__c != null && spApi.Access_Token_Expire_Time__c > System.now();
        
        if(accessToken != null && isValidToken){
            return spApi.Access_Token__c;
        } else if (refreshToken != null && clientId != null && clientSecret != null){
            //Get access Token from refresh token
            return generateAccessToken(authURL + '?grant_type=refresh_token&refresh_token='+refreshToken+'&client_id='+clientId+'&client_secret='+clientsecret);
        } else if(clientId != null && clientSecret != null && usrname != null && password != null){
            //Get accesstoken with credentials
            return generateAccessToken(authURL + '?grant_type=password&client_id='+clientId+'&client_secret='+clientsecret+'&username='+usrname+'&password='+password);
        } else {
            return null;
        }
    }

    /**
     * @description: This method makes actual callout to fetch access token
     */
    private string generateAccessToken(String endpoint){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    
        HttpResponse res = new Http().send(req);

        if(res.getStatusCode() == 200){
            AuthResponse atr = (AuthResponse)JSON.deserialize(res.getBody(), AuthResponse.class);

            //update custom setting
            spApi.Access_Token__c = atr.access_token;
            spApi.Refresh_Token__c = atr.refresh_token;
            spApi.Access_Token_Expire_Time__c = System.now().addSeconds(atr.expires_in);
            update spApi;

            return atr.access_token;
        } else {
            return null;
        }
    }

    /**
     * @description: This method makes hit to get socialpost record.
     */
    public SocialPost updateSocialPostFromServer(SocialPost sp, String accessToken){

        String params = '';
        params += 'topics=' + sp.R6TopicId + '&';
        params += 'includeWorkflow=' + true + '&';
        Long postId = Long.valueof(sp.R6PostId);
        postId = postId -1;
        params += 'sinceId=' + postId + '&';
        params += 'sortBy=' + 'blogPostId-ascending' + '&';
        params += 'limit=' + 1 + '&';
        sp.HarvestDate = sp.HarvestDate - Double.valueOf(30) / 1440;
        Long harvestDate = sp.HarvestDate.getTime();
        params += 'startDate=' + harvestDate;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(spApi.Post_Endpoint__c + '?' + params);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Type', 'application/json');
        
        HttpResponse res;
        res = new Http().send(req);

        if(res.getStatusCode() == 401){
            accessToken = getAccessToken();
            if(accessToken != null){
                return updateSocialPostFromServer(sp, accessToken);
            }
        }

        if(res.getStatusCode() == 200){
            PostsResponse pr = (PostsResponse)JSON.deserialize(res.getBody(), PostsResponse.class);
            if(pr != null && pr.data != null && pr.data.size() > 0){
                Post p = pr.data.get(0);

                if(p.assignedUser != null){
                    sp.Assigned_Associate__c = p.assignedUser;
                }
                if(p.tags != null){
                    String postTags = '';
                    for(Tag t : p.tags){
                        postTags += t.value + ',';
                    }
                    postTags = postTags.removeEnd(',');
                    sp.PostTags = postTags;
                }
                if(p.engagement != null){
                    //sp.EngagementLevel = p.engagement;
                }
            }
        }
        sp.Last_Updated_By_API__c = System.now();
        return sp;
    }

    public class AuthResponse{
        public string access_token;
        public string token_type;
        public Integer expires_in;
        public string refresh_token;
        public string scope;
    }

    public class PostsResponse{
        public Post[] data;
    }

    public class Post{
        public string id;
        public string assignedUser;
        public tag[] tags;
        public string engagement;
    }

    public class Tag{
        public string Id;
        public string value;
    } 
}

//System.schedule('Social Post Sync Job', '0 0 */2 ? * *', new NF_SocialPostSyncBatch());