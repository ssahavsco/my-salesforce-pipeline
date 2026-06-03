/* ******************************************************************************************************************
 * Program Name : NF_CustomerCareNumberInfo
 * Description :  class.gets the number for Customer care etc for the Bot for reference.
 * created By : Sunny Yadav
 * Modification log : 
 * v.1.0 -> Last updated by - Himanshu, 
 * CCS-436 Changes - Added code to get translated custom labels based on language code
 * ******************************************************************************************************************/ 
public class NF_CustomerCareNumberInfo {

     public class Input{
        @InvocableVariable(Required=true)
        public String chatKey = '';
        
        @InvocableVariable(Required=false)
        public String languageCode = 'en_US';
    }
    
    public class Output{
        @InvocableVariable
        public String sCustomerCareMessage = '';
        @InvocableVariable
        public String sRelayMessage = '';
        @InvocableVariable
        public String sCreditCardCareMessage = '';
        
    }
    
     @InvocableMethod(Label='Neuraflash - Customer Care Number Information')
    public static List<Output> getCustomerCareNumberInformation(List<Input> inputs){
         Einstein_Bot_Dialog_Configuration__mdt[] configs = [SELECT Label, Live_Chat_Available__c,Display_Custom_Messsage__c FROM Einstein_Bot_Dialog_Configuration__mdt WHERE Label = 'Customer Care' LIMIT 1];
		
        List<Output> result = new List<Output>();
        Output out = new Output();
        //only disable chat if we find a valid config, otherwise check availablity
        if(configs.size() > 0 && configs[0].Display_Custom_Messsage__c == true){
            out.sCustomerCareMessage = Label.get('', 'NF_Customer_Care_Call_Number_Bot', inputs[0].languageCode);
            out.sRelayMessage = Label.get('', 'NF_Relay_Number', inputs[0].languageCode);
            out.sCreditCardCareMessage = Label.get('', 'NF_Credit_Card_Care_Number_Bot', inputs[0].languageCode);
        }else{
            out.sCustomerCareMessage = Label.get('', 'NF_Customer_Care_Call_Number_Bot_Default', inputs[0].languageCode);
            out.sRelayMessage = Label.get('', 'NF_Relay_Number_Default', inputs[0].languageCode); 
            out.sCreditCardCareMessage = Label.get('', 'NF_Credit_Card_Care_Number_Bot_Default', inputs[0].languageCode);  
        }
        String chatKey = inputs[0].chatKey;
        result.add(out);
        return result;
    }
}