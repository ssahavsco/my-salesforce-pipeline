public with sharing class VSCCS_GetSIQInfo {
    // Strongly-typed minimal response models
    public class SIQResponse {
        public String orderNumber;
        public List<Shipment> shipments;
    }
    public class Shipment {
        public String lostClaimEligibleDate;
        public String customerCommitDate;
        public List<Events> events;
    }
    public class Events {
        public Datetime eventDate;
        public String customEventDescription;
        public String eventCity;
        public String eventState;
        public String eventCountry;
        public String eventPostalCode;
    }
    public class Output {
        public String lostClaimEligibleDate;
        public String customerCommitDate;
        public String status;
    }

    /**
     * Calls SIQ for a single order and returns minimal shipment info.
     * Notes:
     * - No SOQL/DML performed here; this is a pure callout + parse.
     * - Defensively parses and returns empty values on any error.
     */
    @AuraEnabled
    public static String getSIQInfo(String orderNumber) {
        Output out = new Output();
        if (String.isBlank(orderNumber)) {
            return JSON.serialize(out);
        }

        ServiceIntegration__c siq = ServiceIntegration__c.getInstance('SIQ');
        HttpRequest req = new HttpRequest();
        req.setMethod(siq.Method_Name__c);
        String endpoint = String.valueOf(siq.Base_Url__c);
        endpoint += orderNumber;
        req.setEndpoint(endpoint);
		
        Date todays = System.now().date();
        // Execute
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception ex) {
            logError('Callout failure sending SIQ request', ex);
            return JSON.serialize(out);
        }

        if (res == null) {
            logError('Null response from SIQ', null);
            return JSON.serialize(out);
        }

        Integer code = res.getStatusCode();
        if (code < 200 || code >= 300) {
            /* Commentig for prod 
            out.lostClaimEligibleDate = todays.format();
            out.customerCommitDate = todays.format();
            out.status = 'Single Shipment';*/
            logger.error('SIQ-Output --> '+out);
            logger.saveLog();
            return JSON.serialize(out);
        }

        // Parse response
        try {
            SIQResponse sr = (SIQResponse) JSON.deserialize(res.getBody(), SIQResponse.class);
            logger.info('SIQ Response --> '+res.getBody());
            logger.saveLog();
            if (sr == null || sr.shipments == null || sr.shipments.isEmpty()) {
                return JSON.serialize(out);
            }
            
            Shipment s = sr.shipments[0];
            String shipmentStatus = '';
            if (s != null) {
                out.lostClaimEligibleDate = s.lostClaimEligibleDate;
                out.customerCommitDate = s.customerCommitDate;
                if(s.events != null){
                	Events event = s.events[0];
                    shipmentStatus += (event.customEventDescription + ' - ' + event.eventDate + ' - '+event.eventCity);
                }
            }
            out.status = (sr.shipments.size() > 1) ? 'Split Shipments' : shipmentStatus;

            return JSON.serialize(out);
        } catch (Exception ex) {
            logError('Parse error reading SIQ response: ' + ex.getMessage(), ex);
            return '';
        }
    }

    private static void logError(String message, Exception ex) {
        try {
            Logger.error(message + (ex != null ? ' :: ' + ex.getMessage() : ''))
                .addTag('SIQException');
            Logger.saveLog();
        } catch (Exception ignore) {
            // Avoid throwing from logger
        }
    }
}