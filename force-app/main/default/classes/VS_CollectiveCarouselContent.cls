public with sharing class VS_CollectiveCarouselContent {

    public static String CarouselContent_Available(List<Input> inputs){
        
        String rewardDate = !String.isEmpty(inputs[0].latestRewardDate) ? ('Reward Issued on ' + inputs[0].latestRewardDate) : '';


        // String content = '{"home":1,"cards":["<div class=\'carousel\'><div class=\'Rectangle\'><div class=\'-Oak-Street text-style-1\'><b>'+ inputs[0].customerFullName +  '</b><br> Loyalty# ' + inputs[0].loyaltyId + '<br></div><br><div class=\'Lorem-ipsum-dolor-si\'><div class=\'text-style-1\'><div style=\'text-align:center\'>Points Balance</div><div style=\'text-align:center;font-size:18px\'>'+ inputs[0].currentBalance   +'</div><div style=\'text-align:center;padding-top:2%\'>Points to Next Reward</div><div style=\'text-align:center;font-size:18px\'> ' + inputs[0].requiredForNextReward + '</div><div style=\'text-align:center;padding-top:2%\'>Points Expiration</div><div style=\'text-align:center;font-size:18px\'>'+ inputs[0].spendByDate +'</div></div></div><div class=\'Lorem-ipsum-dolor-si\' style=\'text-align:center\'><div class=\'text-style-1\' style=\'font-size:12px\'> ' + rewardDate + '</div></div><div style=\'font-size:9.5px; padding-left: 5%; padding-right: 5%; padding-bottom: 5%;color:gray\'>*If you\'ve recently placed an order, it can take up to 72 hours to reflect in your points balance.</div></div></div>"]}';
        String content = '{"home":1,"cards":["<div class=\'carousel\'><div class=\'Rectangle\'><div class=\'-Oak-Street text-style-1\'><b>'+ inputs[0].customerFullName +  '</b></div><br /><div class=\'Lorem-ipsum-dolor-si\'><div class=\'text-style-1\'><div style=\'text-align:center\'>Points Balance</div><div style=\'text-align:center;font-size:18px\'>'+ inputs[0].currentBalance   +'</div><div style=\'text-align:center;padding-top:2%\'>Points to Next Reward</div><div style=\'text-align:center;font-size:18px\'> ' + inputs[0].requiredForNextReward + '</div><div style=\'text-align:center;padding-top:2%\'>Points Expiration</div><div style=\'text-align:center;font-size:18px\'>'+ inputs[0].spendByDate +'</div></div></div><div class=\'Lorem-ipsum-dolor-si\' style=\'text-align:center\'><div class=\'text-style-1\' style=\'font-size:12px\'> ' + rewardDate + '</div></div><div style=\'font-size:9.5px; padding-left: 5%; padding-right: 5%; padding-bottom: 5%;color:gray\'>*If you\'ve recently placed an order, it can take up to 72 hours to reflect in your points balance.</div></div></div>"]}';
        return content;
    }

    public static String CarouselContent_NotAvailable(){
        String content = '{"home":1,"cards":["  <div class=\'carousel\'> <div class=\'Rectangle\'> <div class=\'-Oak-Street text-style-1\' style=\'padding: 10%;\'> I am having trouble finding your account information. Please call Customer Care at 1-800-411-5116 for further assistance. <br /> </div> </div> "]}';
        return content;
    }

    public class Input{
        public String loyaltyId;
        public String customerFullName;
        public String loyaltyStatus;
        public Integer currentBalance;
        public Integer requiredForNextReward;
        public String spendByDate;
        public String latestRewardDate;
  
    }
}