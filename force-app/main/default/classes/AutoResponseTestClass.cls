@IsTest(SeeAllData=true)
private class AutoResponseTestClass {
    @IsTest
    static void testBehavior() {
    ExternalSocialAccount esa = [SELECT id, masterlabel from externalsocialaccount where MasterLabel =: 'Victoria\'s Secret (Default)'];
    AutoRespond.flowInputs input = new AutoRespond.flowInputs();
    input.postMessage = 'Hello World';
    input.theResponse = new Social_Auto_Response__c();
    input.theResponse.name = 'Awesome';
    input.theResponse.Message__c = 'Test Message';  
    SocialPost post = [SELECT id, Handle FROM SocialPost where Handle =: 'Nathan Scott Hembree' limit 1];
        
    
        
    input.posts = new List<SocialPost>{post};
    Test.startTest();
    AutoRespond.sendOutboundPost(new List<AutoRespond.flowInputs>{input}); 
    Test.stopTest();
    }

}