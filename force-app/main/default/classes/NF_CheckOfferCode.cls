/*****************************************************************************************************@@
Class Name     :  NF_CheckOfferCode
Description    :  Check KOD offer codes to be used in einstein bot
Modification log : 
-------
VERSION  AUTHOR                 DATE                DETAIL                                  TICKET REFERENCE/ NO.
1.      adamundus              9/21/20          Original Version                
2.      Sunny Yadav            4/22/21          KOD based on site exposure start date          DP-36281, DP-40255
3.      Manishi                8/24/21          Retrieving single use offer code for chatbot   DP-40040 
4.      Sumit Saha             8/9/23           Adding the offer expiry date                   CCS-77 
5.      Himanshu Mishra        5/28/24          Added new field mapping(App Redemptive Disclaimer)  CCS-458
  
*********************************************************************************************************/
public with sharing class NF_CheckOfferCode {
    public class Input {
        @InvocableVariable(Required=false)
        public String chatKey;
        @InvocableVariable(Required=false)
        public String offerCode;
    }

    public class Output {
        @InvocableVariable(Required=true)
        public Boolean offerFound;

        @InvocableVariable(Required=false)
        public Boolean isExpired;

        @InvocableVariable(Required=false)
        public Boolean offerStarted;

        @InvocableVariable(Required=false)
        public String digitalOfferDisclaimer;

        @InvocableVariable(Required=false)
        public Boolean isApproved;

        @InvocableVariable(Required=false)
        public Boolean isGiftOffer;

        @InvocableVariable(Required=false)
        public String offerCode;

        @InvocableVariable(Required=false)
        public Boolean isBlocked;

        @InvocableVariable(Required=false)
        public String offerExpiryDate;
        
    }

    @InvocableMethod(Label='Neuraflash - Check Offer Code')
    public static List<Output> checkCode(List<Input> input) {
        List<Output> outputs = new List<NF_CheckOfferCode.Output>();

        String offerCode = input[0].offerCode;
        System.debug(LoggingLevel.DEBUG,'NF_CheckOfferCode: searching for offerCode=' + offerCode);

        Output out = new Output();
        out.offerFound = false;

        if(String.isEmpty(offerCode)){
            outputs.add(out);
            return outputs;
        }
        
        try {
            List<KOD__c> offersFound = new List<KOD__c>();
            /** DP-36281 starts **/
            /** soql modified to get KOD based on site exposure start date **/
            offersFound = [
                    SELECT Block_from_Bots__c, Digital_Offer_Disclaimer__c ,Name, Offer_Code__c, Offer_Status__c, Promotional_Level__c, Disclaimer_Expiration__c, Site_Exposure_Start__c, System_Expiration__c, Disclaimer__c
                    FROM KOD__c
                    WHERE Offer_Code__c = :offerCode OR Offer_Code_2__c = :offerCode order by Site_Exposure_Start__c  desc
            ];
            
            /** DP-36281 ends **/
            if (offersFound.size() > 0) {
                out.offerFound = true;

                KOD__c offer = offersFound[0];
                System.debug(LoggingLevel.DEBUG,'NF_CheckOfferCode: found offer=' + offer);
            }
            else {
                /** DP-40040 starts **/
                /** soql to get single use offer code **/
                if(offerCode.length() >=10) {
                    offerCode = offerCode.left(10)+'%';
                }
                offersFound = [
                    SELECT Single_Use_Offer_Code__c, Block_from_Bots__c, Digital_Offer_Disclaimer__c ,Name, Offer_Code__c, Offer_Status__c, Promotional_Level__c, Disclaimer_Expiration__c, Site_Exposure_Start__c, System_Expiration__c, Disclaimer__c
                    FROM KOD__c
                    WHERE Single_Use_Offer_Code__c = true AND (Offer_Code__c LIKE : offerCode OR Offer_Code_2__c LIKE : offerCode OR Additional_Offer_Codes__c LIKE : offerCode) order by Site_Exposure_Start__c  desc
                ];
            }
            /** DP-40040 ends **/
            
            if (offersFound.size() > 0) {
                out.offerFound = true;

                KOD__c offer = offersFound[0];
                System.debug(LoggingLevel.DEBUG,'NF_CheckOfferCode: found offer=' + offer);

                Datetime now = Datetime.now();

                if (String.isNotBlank(offer.Digital_Offer_Disclaimer__c)) {
                    out.digitalOfferDisclaimer = offer.Digital_Offer_Disclaimer__c;
                }
                out.isApproved = 'APPROVED'.equalsIgnoreCase(offer.Offer_Status__c);

                out.isGiftOffer = '3.5 Item Stack GWP/PWP'.equalsIgnoreCase(offer.Promotional_Level__c);

                out.isExpired = now > offer.Disclaimer_Expiration__c;

                out.offerStarted = now > offer.Site_Exposure_Start__c;

                out.offerCode = offerCode;

                out.isBlocked = offer.Block_from_Bots__c;
                out.offerExpiryDate = offer.Disclaimer_Expiration__c.format('MMM dd, yyyy','America/New_York');
                
                if(String.isNotBlank(offer.Disclaimer__c)){
                    out.digitalOfferDisclaimer += '\n'+offer.Disclaimer__c;
                }
            }
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG,'NF_CheckOfferCode:  exception = ' + e);
        }
        outputs.add(out);
        System.debug(LoggingLevel.DEBUG,'NF_CheckOfferCode: returning outputs='+outputs);

        return outputs;
    }
}