public class AutoRespond {

  public class flowInputs{
  @invocableVariable public String postMessage;
  @invocableVariable public Social_Auto_Response__c theResponse;
  @invocableVariable public List<socialPost> posts;
  }
  

  @InvocableMethod(label='Send Auto Response' description='Sends an auto response, creates a social post, and parents to case')
    public static void sendOutboundPost(List<flowinputs> request) {
        
        for (SocialPost post : request[0].posts) {
        SocialPost testOutbound = new SocialPost();
        testOutbound.content = request[0].postMessage; //Auto response message goes here
        
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        
        // Populating default quick action and sending
        req.quickActionName = Schema.SocialPost.QuickAction.SocialPublisher;
        req.record = testOutbound;
        req.contextId = post.id;
        QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
           
        
        }
    }
    
}