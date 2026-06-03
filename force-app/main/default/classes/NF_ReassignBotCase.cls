/**
 * Created by mcasella on 9/8/20.
 */
public with sharing class NF_ReassignBotCase{
    //static variable to control dml/soql execution after first update.
    public static Boolean updateTranscript = false;
    public static Boolean updateAccountCheck = false;
    public static String testStatusVariable = 'Waiting';
    public static Boolean allowTranscriptUpdate = true;
    public static Boolean reassignCases(Map<Id, LiveChatTranscript> liveChatTranscripts){
        System.debug('inside reassignCases');
        if (liveChatTranscripts == null || liveChatTranscripts.size() == 0){
            return false;
        }

        RecordType caseRecordType = NF_CreateCase.getRecordType();
        System.debug('caseRecordType' + caseRecordType);
        User platformIntegrationUser = NF_Util.getPlatformIntegrationUser();
        if (caseRecordType == null || platformIntegrationUser == null){
            System.debug(LoggingLevel.DEBUG, 'Unable to Reassign Bot Case: caseRecordType=' + caseRecordType + ', platformIntegrationUser=[' + platformIntegrationUser + ']');
            return false;
        }

        try{
            List<Case> cases = new List<Case>();
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> directToChatCaseIdSet = new Set<Id>();
            Map<Id, Id> caseTranscriptOwnerMap = new Map<Id, Id>();
            Map<Id, Case> caseMap = new Map<Id, Case>();
            for (Id chatTranscriptId : liveChatTranscripts.keySet()){
                System.debug(LoggingLevel.DEBUG, '>>NF_LiveChatTranscriptReassignBotCase trigger update: chatTranscriptId=' + chatTranscriptId);

                //if the transcript is not owned by the creator (Platform Integration User),
                //then we can assume it's been reassigned to an agent
                if (liveChatTranscripts.get(chatTranscriptId).CreatedById != liveChatTranscripts.get(chatTranscriptId).OwnerId){
                    LiveChatTranscript transcript = liveChatTranscripts.get(chatTranscriptId);
                    System.debug(LoggingLevel.DEBUG, '>>NF_LiveChatTranscriptReassignBotCase transcript=' + transcript);

                    //only reassign to Users (not Queues)
                    if (transcript != null && transcript.OwnerId != null && ((String) transcript.OwnerId).startsWith('005')){
                        System.debug('liveChatTranscripts.get(chatTranscriptId).CaseId ' + liveChatTranscripts.get(chatTranscriptId).CaseId);
                        if (liveChatTranscripts.get(chatTranscriptId).CaseId != null){
                            caseIdSet.add(liveChatTranscripts.get(chatTranscriptId).CaseId);
                            caseTranscriptOwnerMap.put(liveChatTranscripts.get(chatTranscriptId).CaseId, transcript.OwnerId);
                        }

                    }
                    System.debug('liveChatTranscripts.get(chatTranscriptId).LiveChatButtonId' + liveChatTranscripts.get(chatTranscriptId).LiveChatButtonId);
                    if (liveChatTranscripts.get(chatTranscriptId).LiveChatButtonId == NF_Util.getChatButtonId('Customer_Care_Associates')){
                        //List<Case> caseToUpdate = checkExistingCase(liveChatTranscripts.values());
                        List<Case> caseToUpdate = updateTranscriptToPersonAccount(liveChatTranscripts.values());
                        System.debug('caseToUpdate' + caseToUpdate);
                        if (!caseToUpdate.isEmpty()){
                            cases.add(caseToUpdate[0]);
                        }
                    }

                }

            }
            System.debug('caseIdSet' + caseIdSet);
            if (!caseIdSet.isEmpty()){
                List<Case> caseList = [SELECT Id, Status, OwnerId
                                       FROM Case
                                       WHERE Id = :caseIdSet];
                System.debug('caseList' + caseList);
                if (!caseList.isEmpty()){
                    caseList[0].OwnerId = caseTranscriptOwnerMap.get(caseList[0].Id);
                    System.debug(LoggingLevel.DEBUG, '>> NF_LiveChatTranscriptReassignBotCase: Reassigning Case.Id=[' + caseList[0].Id + '] to [' + caseList[0].OwnerId + ']');
                    if (caseList[0].Status == 'New'){
                        caseList[0].Status = 'Open';
                    }
                }
                cases.add(caseList[0]);
            }
            caseMap.putAll(cases);
            System.debug('caseMap' + caseMap);
            if (caseMap.size() > 0){
                update caseMap.values();
                return true;
            }
        } catch (Exception e){
            //NF_EinsteinBotLogger.error(e);
        }

        return false;
    }

    /* update transcript with Person Account */
    public static void updateAccountOnTranscript(List<LiveChatTranscript> transcriptList){
        System.debug('inside updateAccountOnTranscript');
        Set<String> setOftranscriptsChatKey = new Set<String>();
        Map<String, Account> mapOfAccountChatkey = new Map<String, Account>();
        List<LiveChatTranscript> listToUpdate = new List<LiveChatTranscript>();
        try{
            //update the account on transcript if It has not been updated before.
            System.debug('updateAccountCheck' + updateAccountCheck);
            if (updateAccountCheck == false){
                for (LiveChatTranscript eachTranscript : (List<LiveChatTranscript>)Trigger.new ){
                    if (Test.isRunningTest()){
                        if (NF_ReassignBotCase.testStatusVariable == 'InProgress'){
                            setOftranscriptsChatKey.add(eachTranscript.ChatKey);
                        }
                    }
                    System.debug('eachTranscript.Status' + eachTranscript.Status);
                    if (eachTranscript.Status == 'Completed' || eachTranscript.Status == 'InProgress'){
                        //means chat has been accepted.
                        setOftranscriptsChatKey.add(eachTranscript.ChatKey);
                    }
                }
                System.debug('setOftranscriptsChatKey' + setOftranscriptsChatKey);
                if (setOftranscriptsChatKey.size() > 0){
                    List<LiveChatTranscript> listOfTranscript = [SELECT Id, ContactId, Email__c, Contact.Name, Contact.Email, LiveChatButtonId, Contact.FirstName, Contact.LastName
                                                                 FROM LiveChatTranscript
                                                                 WHERE ChatKey IN:setOftranscriptsChatKey];
					string email = String.isNotBlank(listOfTranscript[0].Contact.Email) ? listOfTranscript[0].Contact.Email : listOfTranscript[0].Email__c;
                    
                    System.debug('listOfTranscript' + listOfTranscript);
                    if (!listOfTranscript.isEmpty() && String.isNotBlank(email)){
                        //query to get the account based on person email matched from transcript email.
                        List<Account> accountList = [SELECT Id, PersonContactId, LastModifiedDate, CID__c
                                                     FROM Account
                                                     WHERE PersonEmail = :email 
                                                     ORDER BY LastModifiedDate DESC];
                        System.debug('accountList' + accountList);
                        if (!accountList.isEmpty()){
                            Boolean isCIDPresent = false;
                            for (Account eachCon : accountList){
                                if (eachCon.CID__c != null){
                                    isCIDPresent = true;
                                    mapOfAccountChatkey.put(listOfTranscript[0].Id, eachCon);
                                    break;
                                }
                            }
                            if (!isCIDPresent){
                                mapOfAccountChatkey.put(listOfTranscript[0].Id, accountList[0]);
                            }
                        }
                        //update variable to true in order to avaoid further uodation of account.
                        NF_ReassignBotCase.updateAccountCheck = true;
                    }
                    System.debug('mapOfAccountChatkey' + mapOfAccountChatkey);
                    if (mapOfAccountChatkey.size() > 0){
                        for (LiveChatTranscript eachTranscript : (List<LiveChatTranscript>)Trigger.new ){
                            Account account = mapOfAccountChatkey.get(eachTranscript.Id);
                            System.debug('account' + account);
                            LiveChatTranscript newLiveChatTranscript = new LiveChatTranscript(AccountId = account.Id, Id = eachTranscript.Id, ContactId = account.personContactId);
                            listToUpdate.add(newLiveChatTranscript);
                        }
                        System.debug('listToUpdate' + listToUpdate);
                        //update transcript is list is not empty.
                        if (!listToUpdate.isEmpty()){
                            if (NF_ReassignBotCase.updateTranscript == false){
                                NF_ReassignBotCase.updateTranscript = true;
                                update listToUpdate;
                            }
                        }
                    }
                }
            }
        } catch (Exception e){
            System.debug(LoggingLevel.DEBUG, 'Exception caught>>>' + e.getStackTraceString());
        }
    }

    /* for person account direct to chat logic */
    public static List<Case> updateTranscriptToPersonAccount(List<LiveChatTranscript> chatTranscripts){
		Boolean isAuthenticated = false;//DP-55544
        /* variable declarations */
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> contactEmailSet = new Set<String>();
        Map<String, Id> accountEmailMap = new Map<String, Id>();
        List<Account> accountList = new List<Account>();
        List<Account> accountToInsertList = new List<Account>();
        List<Case> casesToInsert = new List<Case>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        List<Contact> deletedContactList = new List<Contact>(); //contacts to be deleted.
        List<Id> deletedContactIdList = new List<Id>();
        Map<Id, Id> contactToCaseMap = new Map<Id, Id>();
        Map<Id, Id> contactToNewCaseMap = new Map<Id, Id>();
        Map<Id, Case> contactToCaseDetailMap = new Map<Id, Case>();
        List<Case> updatedCasesList = new List<Case>();
        Map<String, Id> emailToNewPersonAccount = new Map<String, Id>();
        Map<Id, Id> transcriptToContact = new Map<Id, Id>();
        Map<Id, Id> transcriptToNewContact = new Map<Id, Id>();
        Map<Id, Contact> personContactToIncomingContact = new Map<Id, Contact>();
        Map<String, LiveChatTranscript> contactToTranscriptMap = new Map<String, LiveChatTranscript>();
        Map<String, String> contactEmailToSubject = new Map<String, String>();
        Map<Id, String> personAccountSubjectMap = new Map<Id, String>();
        /* DP-33229 */
        Map<String, String> transcriptEmailToPageUrl = new Map<String, String>();
        List<Account> accountListByEmail = new List<Account>();
        Map<String, List<Account>> emailAccountMap = new Map<String, List<Account>>();
        try{
            system.debug('NF_ReassignBotCase.allowTranscriptUpdate>>>>' + NF_ReassignBotCase.allowTranscriptUpdate);
            for (LiveChatTranscript eachTrans : chatTranscripts){
                System.debug('eachTrans>>>' + eachTrans);
                if (String.isNotBlank(eachTrans.ContactId) && String.isBlank(eachTrans.CaseId)){
                    contactIdSet.add(eachTrans.ContactId);
                    transcriptToContact.put(eachTrans.Id, eachTrans.ContactId);

                    /* map to be used to extract the incoming page url */
                    /* DP-33229 to get the url from the chat transcript, since we are not adding the snippet to take the page url at website and community */
                    transcriptEmailToPageUrl.put(eachTrans.Email__c, eachTrans.Page_Url__c);
                    System.debug(LoggingLevel.DEBUG, 'transcriptEmailToPageUrl>>>' + transcriptEmailToPageUrl);
                }
                
                //DP-55544
                If(eachTrans.JWT_Token__c != null ){    
                    isAuthenticated = true;    
                }
            }
            if (!contactIdSet.isEmpty()){
                /* soql to get incoming contact and related transcript details to be updated on Case for VOC coding */
                List<Contact> contactList = [SELECT Id, Name, FirstName, LastName, Case_Subject__c, Email, Page_Url__c, (SELECT Id, Page_Name__c, Page_URL__c, FirstName__c, LastName__c, Email__c, UserAgent, Browser, CreatedDate, ChatKey, Subject__c
                                                                                                                         FROM LiveChatTranscripts
                                                                                                                         ORDER BY CreatedDate DESC
                                                                                                                         LIMIT 1)
                                             FROM Contact 
                                             WHERE Id IN:contactIdSet];

                if (!contactList.isEmpty()){
                    for (Contact eachContact : contactList){
                        contactEmailSet.add(eachContact.Email);
                        contactMap.put(eachContact.Id, eachContact);
                        deletedContactList.add(eachContact);
                        deletedContactIdList.add(eachContact.Id);
                        /* map to be used to extract the incoming contact's subject */
                        contactEmailToSubject.put(eachContact.Email, eachContact.LiveChatTranscripts[0].Subject__c);
                        /* map to be used to extract the incoming contact's transcript */
                        contactToTranscriptMap.put(eachContact.Email, eachContact.LiveChatTranscripts[0]);
                    }

                    //check for person account with that incoming email
                    if (!contactEmailSet.isEmpty()){
                        accountListByEmail = NF_Util.getRelatedPersonAccount(contactEmailSet);
                    }

                    for (Account eachAccount : accountListByEmail){
                        if (!emailAccountMap.containsKey(eachAccount.PersonEmail)){
                            emailAccountMap.put(eachAccount.PersonEmail, new List<Account>{ eachAccount });
                        } else{
                            emailAccountMap.get(eachAccount.PersonEmail).add(eachAccount);
                        }
                    }

                    for (String email : emailAccountMap.keySet()){
                        Boolean cidPresent = false;
                        if (emailAccountMap.get(email).size() > 1){
                            for (Account acc : emailAccountMap.get(email)){
                                if (Account.CID__c != null){
                                    cidPresent = true;
                                    accountList.add(acc);
                                    break;
                                }
                            }
                            if (!cidPresent){
                                accountList.add(emailAccountMap.get(email)[0]);
                            }
                        }
                    }

                    for (Account eachAccount : accountList){
                        /* map to be used to extract the person account id with person contact id */
                        accountEmailMap.put(eachAccount.PersonEmail, eachAccount.PersonContactId);
                        /* map to be used to extract the person account id with case subject, saved from the incoming chat */
                        personAccountSubjectMap.put(eachAccount.PersonContactId, eachAccount.Case_Subject__pc);
                        List<Case> casesList = eachAccount.Cases;
                        if (casesList.size() > 0){
                            //case map to exisiting case (id,id)
                            contactToCaseMap.put(eachAccount.PersonContactId, casesList[0].Id);
                            contactToCaseDetailMap.put(eachAccount.PersonContactId, casesList[0]);
                        } else{
                            /* create new case with the required fields, add VOC coding fields to the case */
                            Case newCase = NF_CreateCase.initializeCase(null, isAuthenticated, null, NF_CreateCase.CHAT_ORIGIN, false);
                            newCase.ContactId = eachAccount.PersonContactId;
                            newCase.Status = 'Open';
                            newCase.invocationURL__c = transcriptEmailToPageUrl.containsKey(eachAccount.PersonEmail) ? transcriptEmailToPageUrl.get(eachAccount.PersonEmail) : '';
                            newCase.Subject = contactEmailToSubject.containsKey(eachAccount.PersonEmail) ? contactEmailToSubject.get(eachAccount.PersonEmail) : '';
                            if (contactToTranscriptMap.containsKey(eachAccount.PersonEmail)){
                                NF_CreateCase.populateFieldsFromTranscript(newCase, contactToTranscriptMap.get(eachAccount.PersonEmail), null, false);
                            }
                            casesToInsert.add(newCase);
                        }
                    }


                }
                for (Contact eachContact : contactList){
                    if (!accountEmailMap.containsKey(eachContact.Email)){
                        //create person Account
                        //if doesnot exists- create person account
                        Account newPersonAccount = NF_Util.createCustomer('', eachContact.Email, false, eachContact.FirstName, eachContact.LastName);
                        newPersonAccount.Case_Subject__pc = eachContact.Case_Subject__c;
                        /* added for DP-40669 starts*/
                        accountToInsertList.add(newPersonAccount);
                        /* added for DP-40669 end*/
                    }
                }

                if (!accountToInsertList.isEmpty()){
                    insert accountToInsertList;
                }

                Set<Id> insertedPersonAccountSet = new Set<Id>();
                for (Account eachAccount : accountToInsertList){
                    insertedPersonAccountSet.add(eachAccount.Id);
                }
                List<Account> insertedPersonAccount = [SELECT Id, PersonContactId, PersonEmail
                                                       FROM Account
                                                       WHERE Id IN:insertedPersonAccountSet];
                if (!insertedPersonAccount.isEmpty()){
                    for (Account eachAccount : insertedPersonAccount){
                        emailToNewPersonAccount.put(eachAccount.PersonEmail, eachAccount.PersonContactId);
                        accountEmailMap.put(eachAccount.PersonEmail, eachAccount.PersonContactId);
                        /* DP-35266 19th feb */
                        /* create new case with the required fields, add VOC coding fields to the case */
                        Case newCase = NF_CreateCase.initializeCase(null, false, null, NF_CreateCase.CHAT_ORIGIN, false);
                        newCase.ContactId = eachAccount.PersonContactId;
                        newCase.Status = 'Open';
                        newCase.invocationURL__c = transcriptEmailToPageUrl.containsKey(eachAccount.PersonEmail) ? transcriptEmailToPageUrl.get(eachAccount.PersonEmail) : '';
                        newCase.Subject = contactEmailToSubject.containsKey(eachAccount.PersonEmail) ? contactEmailToSubject.get(eachAccount.PersonEmail) : '';
                        if (contactToTranscriptMap.containsKey(eachAccount.PersonEmail)){
                            NF_CreateCase.populateFieldsFromTranscript(newCase, contactToTranscriptMap.get(eachAccount.PersonEmail), null, false);
                        }
                        casesToInsert.add(newCase);
                        /* DP-35266 19th feb */
                    }
                }

                if (!casesToInsert.isEmpty()){
                    /* insert new case */
                    insert casesToInsert;
                    for (Case eachCase : casesToInsert){
                        contactToNewCaseMap.put(eachCase.ContactId, eachCase.Id);
                    }
                }

                List<LiveChatTranscript> chatTranscriptList = new List<LiveChatTranscript>();

                /* below for loop is to update the incoming transcript with Contact, Case, Case_reused__c if applicable */
                for (LiveChatTranscript chatTranscript : chatTranscripts){
                    LiveChatTranscript newTrans = new LiveChatTranscript();
                    if (transcriptToContact.containsKey(chatTranscript.Id)){
                        //get the contact.
                        Id contactId = transcriptToContact.get(chatTranscript.Id);
                        if (contactMap.containsKey(contactId)){
                            Contact existingContact = contactMap.get(contactId);
                            newTrans.Email__c = existingContact.Email;
                            newTrans.FirstName__c = existingContact.FirstName;
                            newTrans.LastName__c = existingContact.LastName;
                            if (emailToNewPersonAccount.containsKey(existingContact.Email)){
                                newTrans.ContactId = accountEmailMap.get(existingContact.Email);
                            } else{
                                newTrans.ContactId = accountEmailMap.get(existingContact.Email);
                            }
                        }
                        /* map to be used to extract contact's id from the incoming transcript */
                        transcriptToNewContact.put(chatTranscript.Id, newTrans.ContactId);
                    }
                    if (transcriptToNewContact.containsKey(chatTranscript.Id)){
                        Id eachContactId = transcriptToNewContact.get(chatTranscript.Id);
                        //newTrans.Id = chatTranscript.Id;
                        if (contactToCaseMap.containsKey(eachContactId)){
                            /* update transcript with the old existing case */
                            newTrans.CaseId = contactToCaseMap.get(eachContactId);
                            newTrans.Is_Case_Reused__c = true;
                            newTrans.Id = chatTranscript.Id;
                            /* update case fields with the updated subject, Is_Case_Reused__c checkbox */
                            if (contactToCaseDetailMap.containsKey(eachContactId)){
                                Case exisitingCase = contactToCaseDetailMap.get(eachContactId);
                                exisitingCase.Is_Case_Reused__c = true;
                                exisitingCase.invocationURL__c = chatTranscript.Page_URL__c;
                                /* removed subject mapping for DP-40669*/
                                /* will be handled by trigger */
                                //exisitingCase.Subject = (String.isNotBlank(personAccountSubjectMap.get(eachContactId))) ? personAccountSubjectMap.get(eachContactId) : exisitingCase.Subject;
                                updatedCasesList.add(exisitingCase);
                            }

                        }
                        /* update transcript with the new created case */
                        else if (contactToNewCaseMap.containsKey(eachContactId)){
                            newTrans.CaseId = contactToNewCaseMap.get(eachContactId);
                            newTrans.Id = chatTranscript.Id;
                        }
                    }

                    chatTranscriptList.add(newTrans);
                }
                if (!chatTranscriptList.isEmpty() && NF_ReassignBotCase.allowTranscriptUpdate){
                    NF_ReassignBotCase.allowTranscriptUpdate = false;
                    update chatTranscriptList;

                }
            }


        } catch (Exception e){
            System.debug('Exception occured at>>>' + e.getStackTraceString() + 'message>>>' + e.getMessage());
        }
        return updatedCasesList;
    }

    /*public static void updateContactId(List<LiveChatTranscript> liveChatTranscripts){
     Map<Id, String> lvVsDetailsMap = new Map<Id, String>();
     Map<Id, String> conVsDetailsMap = new Map<Id, String>();
     Set<String> nameSet = new Set<String>();
     Set<String> emailSet = new Set<String>();
     for (LiveChatTranscript lv : liveChatTranscripts){
     if (lv.FirstName__c != null && lv.LastName__c != null && lv.Email__c != null){
     lvVsDetailsMap.put(lv.Id, lv.FirstName__c + ' ' + lv.LastName__c + ';' + lv.Email__c);
     emailSet.add(lv.Email__c);
     nameSet.add(lv.FirstName__c + ' ' + lv.LastName__c);
     }
     }
     List<Contact> conList = [SELECT Id
     FROM Contact
     WHERE Name IN:nameSet AND Email IN:emailSet];
     for (Contact con : conList){
     conVsDetailsMap.put(con.Id, con.Name + con.Email);
     }
     } */
}