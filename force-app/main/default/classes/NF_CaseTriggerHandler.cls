/*****************************************************************************************************
Class Name     :  NF_CaseTriggerHandler
Purpose        :  Trigger Helper to update the Case Subject with what is on the Chat Transcript.

History:
-------
VERSION  AUTHOR               DATE                DETAIL                          TICKET REFERENCE/ NO.
1.       manishi              4/29/2021           Original Version                DP-40541
2.       bijohnson            5/7/2021            Chat case updates only          DP-41234                                 
*********************************************************************************************************/
public class NF_CaseTriggerHandler {
    
    //method to be called when case is getting inserted.
    //insert the Chat case with subject which is on transcript's subject.
    public static void updateChatCaseSubject(List<case> casesList) {
        List<LiveChatTranscript> chatTranscriptList;
        try{
            Set<Id> caseIdSet = new Set<Id>();
            Map<Id, String> chatIdToSubjectMap = new Map<Id, String>();
            Map<Id,Schema.RecordTypeInfo> rtMap = Case.sobjectType.getDescribe().getRecordTypeInfosById();

            for(Case eachCase: casesList) {
                if(rtMap.get(eachCase.RecordTypeId).getDeveloperName() == 'Chat_Case') {
                    caseIdSet.add(eachCase.Id);
                }
            }
            //soql on chat transcript.
            if (caseIdSet.size() > 0) {
                chatTranscriptList = [SELECT ID, Email__c, Subject__c, CaseId, LiveChatButtonId, Case_Lookup__c
                                        FROM LiveChatTranscript WHERE Case_Lookup__c IN: caseIdSet 
                                        and CreatedDate = Today
                                        Order By Createddate DESC];
                
                if(!chatTranscriptList.isEmpty()) {
                    for(LiveChatTranscript eachChat : chatTranscriptList) {
                        if(!chatIdToSubjectMap.containskey(eachChat.CaseId)) {
                            chatIdToSubjectMap.put(eachChat.CaseId, eachChat.Subject__c);
                        }
                    } 
                }
                for(Case eachCase: casesList) {
                    if(chatIdToSubjectMap.containsKey(eachCase.Id)) {
                        eachCase.Subject = chatIdToSubjectMap.get(eachCase.Id);
                    }
                }
            }         
        } catch(Exception e) {
            System.debug('Exception occured at>>>'+e.getStackTraceString() + 'message>>>'+e.getMessage());
        }
        
        
    }
    
    
    //Process Case resolution records and Order Transaction records
    public static void updateCaseForMissingResolution(List<case> casesList, Map<Id, sObject> oldMap) {
        List<Case> caseListToProcess = new List<Case>();
        List<Case_Resolution__c> caseResolutionListToProcess = new List<Case_Resolution__c>();
        
    For(case cas:casesList){
        Case_Resolution__c casRes = new Case_Resolution__c();
        case updateCase = new case();

        case oldCase = (Case)oldMap.get(cas.id);
        If(cas.Status == 'Closed' && oldCase.status != 'Closed' && cas.Temp_Case_Resolution_Type__c != Null && cas.Temp_Order_Number__c != Null && ( cas.Temp_Case_Resolution_Type__c == 'Place a new order'  || cas.Temp_Case_Resolution_Type__c == 'Modify order (Credit Card Required)') ){
                 ProcessCaseResolution(cas.id);
         }
        }
    } 



    //Process Case resolution records and Order Transaction records in Future Method
    @Future(callout=true)
    public static void ProcessCaseResolution(string caseId) {
      Case caseRec = new  Case();
      List<Case_Resolution__c> caseResolutionListToProcess = new List<Case_Resolution__c>();
      case updateCase = new case();
      caseRec = [Select id,Temp_Order_Number__c,Temp_Case_Resolution_Type__c from case where id =: caseId];

        Case_Resolution__c casRes = new Case_Resolution__c();
        casRes.Case_Resolution_Type__c = caseRec.Temp_Case_Resolution_Type__c;
        casRes.Related_Case__c = caseRec.id;
        casRes.Completion_Date__c = system.today();
        casRes.AO_Order_Number__c = caseRec.Temp_Order_Number__c;

        updateCase.id= caseRec.id;
        updateCase.Order_Number__c = caseRec.Temp_Order_Number__c;
        updateCase.Temp_Case_Resolution_Type__c = null;
        updateCase.Temp_Order_Number__c = null;
        
        NF_CreateOrderTransaction.FlowRequestWrapper wrap = new NF_CreateOrderTransaction.FlowRequestWrapper();
        List<NF_CreateOrderTransaction.FlowRequestWrapper> wrapLst = new List<NF_CreateOrderTransaction.FlowRequestWrapper>();
            
        wrap.orderNumber =	 caseRec.Temp_Order_Number__c;
        wrap.caseResolutionRecord = casRes;
        wrapLst.add(wrap);
       
       If(!wrapLst.isEmpty()){
        NF_CreateOrderTransaction.createRecord(wrapLst);
        insert casRes;
        update updateCase;    
       }       
    } 
}