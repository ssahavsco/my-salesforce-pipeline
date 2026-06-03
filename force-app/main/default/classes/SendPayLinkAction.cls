/**

 **/
public without sharing class SendPayLinkAction{
    @AuraEnabled
    public static String sendSingleEmailMethod(String caseRecordId, String toAddresses, String paymentLink){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddressesList = toAddresses?.split(';');
        if (toAddressesList != null){
            try{
                EmailTemplate emailTemp = [Select id, Subject, HtmlValue
                                           From EmailTemplate
                                           Where DeveloperName = 'Place_New_Order_Email_Template'];
                OrgWideEmailAddress emailAddress = [Select Id
                                                    From OrgWideEmailAddress
                                                    Where Address = 'noreply@victoriassecret.com'
                                                    Limit 1];
                String emailbody = emailTemp.HtmlValue;
                emailbody = emailbody.replace('{paymentlink}', paymentLink);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setHtmlBody(emailbody);
                mail.setSubject(emailTemp.Subject);
                mail.settoAddresses(toAddressesList);
                mail.setOrgWideEmailAddressId(emailAddress.Id);
                mail.setTreatBodiesAsTemplate(true);
                mail.setWhatId(Id.valueOf(caseRecordId));
                emailList.add(mail);
                System.debug(emailList);
                if (!emailList.isEmpty()){
                    Messaging.sendEmail(emailList);
                }
                string message = 'To secure your final order and selected products, I would appreciate it if you could complete the payment link that I just sent you via email.Please note, when accessing the payment link form, all discounts, including Free Shipping, will show as a combined discount amount.';
            	return message;
            } catch (Exception e){
                return e.getMessage();
            }
        }
        return 'Please Specify Customer Email';
    }
    @AuraEnabled
    public static String sendTextMessage(String firstName,String lastName, String phoneNumber, String paymentLink,String caseRecordId){
        String errorMessage = SendTextAPIHelper.runSendTextAPI(firstName,lastName,phoneNumber,paymentLink);
        if(string.isEmpty(errorMessage)){
            Case caseObj =[Select Id,PBL_SMS_Count__c from Case Where Id =:caseRecordId Limit 1];
            caseObj.PBL_SMS_Count__c=caseObj != null ? caseObj.PBL_SMS_Count__c+=1 : 1;
            update caseObj;
        }
        return errorMessage;
    }
}