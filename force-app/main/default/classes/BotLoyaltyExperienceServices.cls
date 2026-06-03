public with sharing class BotLoyaltyExperienceServices {
    public BotLoyaltyExperienceServices() {

    }

    @InvocableMethod(label='Loyalty Experience')
    public static void  get_PointBalance(List<Input> input){
      System.debug('BotLoyaltyExperienceServices :: ' + input);

      if(!String.isEmpty(input[0].loyaltyId)){
        VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper res  = VS_LoyaltyExperienceServicesCallouts.getPointsBalance(input[0].loyaltyId);
        VS_LoyaltyExperienceServicesCallouts.LoyaltyExperienceServiceResponseWrapper resCustomerReward = VS_LoyaltyExperienceServicesCallouts.getCustomerRewards(input[0].loyaltyId);

        if (res.statusCode == 200) {
          Map<String,Object> points = (Map<String,Object>) res.response.get('points');
          Map<String,Object> tiers = (Map<String,Object>) res.response.get('tiers');

          VS_CollectiveCarouselContent.Input i = new VS_CollectiveCarouselContent.Input();
          i.loyaltyId = input[0].loyaltyId;
          i.currentBalance =(Integer) points.get('currentBalance');
          i.requiredForNextReward = (Integer)  points.get('requiredForNextReward');
          Long sd = ((Integer) tiers.get('spendByDate')) * 1000L;
          i.spendByDate = DateTime.newInstance(sd).format('MMM dd');
          i.customerFullName = input[0].customerFullName;

     
          List<Object> listRewards = (List<Object>) resCustomerReward.response.get('rewards');
       

          if (listRewards.size() > 0) {
            Integer index;
             if (listRewards.size() == 1) {
                index = 0;
             }else if (listRewards.size() > 1) {
                index = listRewards.size() -1 ;
             }
            Map<String, Object> latestReward = (Map<String, Object>) listRewards[index];
            // i.latestRewardDate = (String) latestReward.get('startDate');
            Long rd = ((Integer) latestReward.get('startDate')) * 1000L;
            i.latestRewardDate = DateTime.newInstance(rd).format('MMM dd');

          }
 
          

          List<VS_CollectiveCarouselContent.Input> listInput = new List<VS_CollectiveCarouselContent.Input>();
          listInput.add(i);

          String carousel = VS_CollectiveCarouselContent.CarouselContent_Available(listInput);

          ebotdata__Bot_Session__c[] ebotSession = [SELECT Id FROM ebotdata__Bot_Session__c WHERE ebotdata__Live_Agent_Session_Id__c = :input[0].chatkey limit 1];

                try {
                    ebotdata__Bot_Session__c eb = new ebotdata__Bot_Session__c();
                    eb.Id = ebotSession[0].Id;
                    eb.CarouselContent__c = carousel;
                    update eb;
                } catch (Exception e) {
                    System.debug( 'Line ==> ' + e.getLineNumber() +  ' BotLoyaltyExperienceServices:: Unable to update : ' + e.getMessage());
                }

        }else {
          System.debug('BotLoyaltyExperienceServices :: ' + input[0].loyaltyId);
          System.debug('BotLoyaltyExperienceServices :: ' + res.statusCode);
          String carousel = VS_CollectiveCarouselContent.CarouselContent_NotAvailable();
          ebotdata__Bot_Session__c[] ebotSession = [SELECT Id FROM ebotdata__Bot_Session__c WHERE ebotdata__Live_Agent_Session_Id__c = :input[0].chatkey limit 1];
          try {
            ebotdata__Bot_Session__c eb = new ebotdata__Bot_Session__c();
            eb.Id = ebotSession[0].Id;
            eb.CarouselContent__c = carousel;
            update eb;
        } catch (Exception e) {
            System.debug( 'Line ==> ' + e.getLineNumber() +  ' BotLoyaltyExperienceServices:: Unable to update : ' + e.getMessage());
        }

        }

      }  
    }



    public class Input{
        @InvocableVariable(required=true)
        public String loyaltyId;

        @InvocableVariable(required=true)
        public String customerFullName;

        @InvocableVariable(required=true)
        public String chatkey;
    }

    public class Output{
        @InvocableVariable
        public String pointBalance;

        @InvocableVariable
        public String pointToNextReward;

        @InvocableVariable
        public String pointExpiryDate;
    }

}