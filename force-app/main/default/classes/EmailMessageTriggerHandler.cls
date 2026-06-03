/***************************************************************************************************************************************************************************
Interface Name : EmailMessageTriggerHandler
CreatedDate : 23-NOV-21
Description :  Adding trigger on EmailMessage Object
Created By : Sumit Saha

Revision History

Date Name Story Number Description
* TODO: 11/23/2021 - DP-45314  - Email: Implement alert message when sending a RED or 72 Hour Email to help prevent sending the response to the customer
* TODO: 01/27/2022 - DP-51938  - SF - Emails created from webforms (SSP Form) are being routed to VS Admin User instead of individual associates

***************************************************************************************************************************************************************************/


public with sharing class EmailMessageTriggerHandler extends NF_TriggerHandler {
    
    public static Boolean triggerDisabled = false;
    public Boolean hasCustomerEmail = false;
    public Set<String> emailToBeRemoved = new Set<String>() ;

	public Boolean getHasCustomerEmail() {
		return this.hasCustomerEmail;
	}

	public void setHasCustomerEmail(Boolean hasCustomerEmail) {
		this.hasCustomerEmail = hasCustomerEmail;
	}

	public Set<String> getEmailToBeRemoved() {
		return this.emailToBeRemoved;
	}

	public void setEmailToBeRemoved(Set<String> emailToBeRemoved) {
		this.emailToBeRemoved = emailToBeRemoved;
	}

    public override Boolean isDisabled(){
        TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance('EmailMessageHandler');
        if(triggerSettings != null){
            if(triggerSettings.IsDisabled__c){
                triggerDisabled = true;
            }
        }
        return triggerDisabled;
    }

    public override void beforeInsert(List<sObject> newList) {
        
        List<EmailMessage> emailMessage = (List<EmailMessage>) newList;
        List<String> emailSubject = new List<String>((System.Label.Restricted_Email_Subject).Split(','));
        List<String> listEmailTemplateId = new List<String>((System.Label.Restricted_Email_Template_Id).Split(','));

        for (EmailMessage email : emailMessage) {
            
            /*** DP-51938 ***/
            try { 
                Set<String> setToAdress = new Set<String>(( ((String) email.get('ToAddress')).split(',')));   
                    for (Integer i = 0; i < emailSubject.size(); i++) {
                        if ( ((String) email.get('Subject')).contains(emailSubject[i].trim()) || listEmailTemplateId.contains( (String) email.get('EmailTemplateId')) ) {
                            Boolean hasCustomerEmail = checkCustomerEmail( (String) email.get('ParentId') , setToAdress );
                        }
                    }
            } catch (Exception e) {
                System.debug( 'EmailMessageTriggerHandler::setToAdress : ' + e.getMessage());
            } 
            /*** DP-51938 ***/
              
            if (hasCustomerEmail) {
                email.ToAddress.addError('Email ID needs to be removed ' + emailToBeRemoved );
            }               
        }
    }

    public Boolean checkCustomerEmail(String caseID , Set<String> setToAddress){
        
        List<Case> listCase = new List<Case>([SELECT RecordTypeId , Account.AccountEmail__c, Account.Name, CaseNumber, RecordType.Name, Sensitive_Situation_Status__c FROM Case where Id = :caseID]);
        List<String> listRecordTypeIDs = new List<String>((System.Label.Restricted_RecordType_Id.Split(',')));
        Set<String> emails = new Set<String>();
        
        emails.add(listCase[0].Account.AccountEmail__c);

        if ( listRecordTypeIDs.contains( (String) listCase[0].get('RecordTypeId'))  ) {
            If( listCase[0].get('Sensitive_Situation_Status__c') == '72 Hours' || listCase[0].get('Sensitive_Situation_Status__c') == 'RED'){ 
                    if (setToAddress.contains( (String)  listCase[0].Account.AccountEmail__c) ) {
                            setEmailToBeRemoved( emails);
                            hasCustomerEmail = true;
                    }
              }
         }
        return hasCustomerEmail;    
    }
}