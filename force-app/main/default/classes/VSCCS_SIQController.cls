public with sharing class VSCCS_SIQController {
    /**
     * Exposes SIQ Lost Claim Eligible Dates to LWC.
     * Returns List<String>
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getLostClaimEligibleDates(String orderNumber) {
        if (String.isBlank(orderNumber)) {
            return new List<String>();
        }
        List<Datetime> dts = VSCCS_GetSIQInfo.getSIQInf(orderNumber);
        List<String> out = new List<String>();
        for (Datetime dt : dts) {
            if (dt != null) {
                out.add(dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
            }
        }
        return out;
    }
}