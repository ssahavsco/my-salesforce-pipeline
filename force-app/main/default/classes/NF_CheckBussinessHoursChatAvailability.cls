/* ******************************************************************************************************************
 * Program Name : NF_CheckBussinessHoursChatAvailability
 * Description : class for Bussiness hours and Holiday hours based implementation on Agent availability
 * created By : Sunny Yadav
 * Modification log :
 * VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
	1.       mcasella               9/11/2020           Original Version            
	2.		 Sunny  				4/22/2021			Modified for enhancement	DP-39114, DP-40210 
    3.		 Himanshu Mishra		01/29/2025			Modified for international  CCS-827
    4.       Sumit Saha             04/01/2025          Modified for customertype   CCS-538
 * ******************************************************************************************************************/
public class NF_CheckBussinessHoursChatAvailability {
    
    public class Input{
        @InvocableVariable(Required=true)
        public String chatKey = '';
        
        // @InvocableVariable
        // public Boolean isDomestic;

        @InvocableVariable
        public String customerType; // ccs-538
        
    }
    
    public class Output{
        @InvocableVariable
        public Boolean isWithinBusinessHoursOn = false;
        
    }
    
    @InvocableMethod(Label='Neuraflash - Check within Business Hours')
    public static List<Output> getBussinessHoursChatToggle(List<Input> inputs){
        List<Output> result = new List<Output>();
        Output out = new Output();
        String chatKey = inputs[0].chatKey;
        out.isWithinBusinessHoursOn = false;
        /** DP-39114 starts **/
        // Get the default business hours
        // String businessHourName = inputs[0].isDomestic ? Label.NF_Business_Hour_Name : Label.International_Business_Hour_Name;
        String businessHourName = inputs[0].customerType == 'DOM' ? Label.NF_Business_Hour_Name : inputs[0].customerType == 'INTL' ? Label.International_Business_Hour_Name : null; // CCS-538
        System.debug('businessHourName: ' + businessHourName);
        List<BusinessHours> bh = [SELECT Id,Name FROM BusinessHours WHERE Name = :businessHourName];
        
        // Find whether the time is within the default business hours 
        if(!bh.isEmpty()) {
            if(BusinessHours.isWithin(bh[0].id, system.now())){
                out.isWithinBusinessHoursOn = BusinessHours.isWithin(bh[0].id, system.now());   
            }  
        } 
        /** DP-39114 ends **/
        
        result.add(out);
        return result;
    }
    
}