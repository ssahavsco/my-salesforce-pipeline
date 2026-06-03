/****************************************************************************************************************
* Program Name         : NF_CaseResolutionTriggerHelper
* Description          : Trigger Helper Class for CaseResolution.
* Version              : 1.1
* Modification Log     : 16 April,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755      1.1       Divyanshu Kumar      16 April,2021       Trigger Helper Class for CaseResolution. 
*                                                                                   CaseResolutionTriggerHandler will use this class. 
*
*   PW_01          DP-42549      1.2       Peter Waddington     3 June 2021         Certain Case Resolution Types do not close the case
*                                                                                   VOC Comments enforcement should not be here
*****************************************************************************************************************/

public with sharing class NF_CaseResolutionTriggerHelper {
    //-----------------------------DK_01--------------------------------
    static Set<String> statusonCRToNotCloseCase = new Set<String>{'Open','Pending Approval','New'};
    // ------------ PW_01 + PW_02 ------ Next line
    // Sets the type of case resolutions that do NOT automatically close a case when resolved, based off the Case Resolution Type value
    static Set<String> typeonCRToNotCloseCase = new Set<String>{'Ad-Hoc Resolution','Pre-Paid Shipping Label','Credit Refund Request - Store Transaction'};
    public static void updateCaseStatus(List<Case_Resolution__c> lstCRs){
        try{
            Set<String> setCaseId = new Set<String>();
            for(Case_Resolution__c cr : lstCRs){
                setCaseId.add(cr.Related_Case__c);
            }
            Map<String,List<Case_Resolution__c>> mapCaseIdvsLstCR = new Map<String,List<Case_Resolution__c>>();
            if(!setCaseId.isEmpty()){
                for(Case_Resolution__c cRes :[SELECT id,Related_Case__c,Related_Case__r.VOC_Comments__c,Status__c,Case_Resolution_Type__c FROM Case_Resolution__c WHERE Related_Case__c IN: setCaseId ORDER BY Completion_Date__c NULLS FIRST]){
                    // --------- PW_01 ------- code was removed here
                    if(mapCaseIdvsLstCR.containsKey(cRes.Related_Case__c)){
                        mapCaseIdvsLstCR.get(cRes.Related_Case__c).add(cRes);
                    }
                    else{
                        mapCaseIdvsLstCR.put(cRes.Related_Case__c, new List<Case_Resolution__c>{cRes});
                    }
                }
            }
            List<Case> lstCasesToUpdate = new List<Case>();
            if(!mapCaseIdvsLstCR.isEmpty()){
                for(String caseId : mapCaseIdvsLstCR.keySet()){
                    for(Case_Resolution__c cr : mapCaseIdvsLstCR.get(caseId)){
                        // ----------- PW_01 ---------- Start
                        if(typeonCRToNotCloseCase.contains(cr.Case_Resolution_Type__c)){
                            break;
                        }
                        // ----------- PW_01 ---------- End
                        if(statusonCRToNotCloseCase.contains(cr.Status__c)){
                            break;
                        }
                        else{
                            Case caseToUpdate = new Case();
                            caseToUpdate.Id = caseId;
                            caseToUpdate.Status = 'Closed';
                            if(!lstCasesToUpdate.contains(caseToUpdate)){
                                lstCasesToUpdate.add(caseToUpdate);
                            }
                        }
                    }
                }
            }
            if(!lstCasesToUpdate.isEmpty()){
                update lstCasesToUpdate;
            }
        }
        catch(Exception e){
            //TODO- Log the exception later.
            System.debug('EXCEPTION FOUND ------ '+e.getMessage());
        }
    }
    //-----------------------------DK_01--------------------------------

    //-----Update case status to Open and assign case back to orginal associate if possible or otherwise queue------------

    public static void updateCaseStatusandOwner(List<Case_Resolution__c> lstCRs){
        try{
            ServiceChannel serviceChannelRec = [SELECT id FROM ServiceChannel WHERE DeveloperName LIKE '%case%'];
            Set<String> setCaseId = new Set<String>();
            for(Case_Resolution__c cr : lstCRs){
                setCaseId.add(cr.Related_Case__c);
            }
            Set<String> userIds = new Set<String>();
            Map<Id,Case> mapCaseIdvsCase;
            if(!setCaseId.isEmpty()){
                mapCaseIdvsCase = new Map<Id,Case>([SELECT Original_Associate__c,Original_Queue_ID__c,OwnerId FROM Case WHERE ID IN: setCaseId]);
                for(Case caseObj : mapCaseIdvsCase.values()){
                    if(caseObj.Original_Associate__c != null){
                        userIds.add(caseObj.Original_Associate__c);
                    }
                }
            }
            Map<String,List<UserServicePresence>> mapUservsListUserPresence = getMapUservsListUserPresence(userIds);
        
            Map<String,List<AgentWork>> mapUserIdvsListAgentWork = getMapUserIdvsListAgentWork(userIds);

            List<AgentWork> lstAgentWorkToInsert = new List<AgentWork>();
            List<Case> lstCasesToUpdate = new List<Case>();
            for(Case caseObj : mapCaseIdvsCase.values()){
                if(caseObj.Original_Associate__c != null){
                    if(mapUservsListUserPresence.containsKey(caseObj.Original_Associate__c)){
                        UserServicePresence usP = mapUservsListUserPresence.get(caseObj.Original_Associate__c)[0];
                        if(mapUserIdvsListAgentWork.containsKey(caseObj.Original_Associate__c)){
                            Integer workCount = mapUserIdvsListAgentWork.get(caseObj.Original_Associate__c).size();
                            if(workCount >= usP.ConfiguredCapacity){
                                //-----user at full capacity. Assign case to original queue.--------
                                caseObj.OwnerId = caseObj.Original_Queue_ID__c != null ? caseObj.Original_Queue_ID__c : caseObj.OwnerId;
                                caseObj.Status = 'Open';
                                caseObj.Priority = 'High';
                                lstCasesToUpdate.add(caseObj);
                            }
                            else{
                                // user not full. create agent work record.
                                lstAgentWorkToInsert.add(createAgentWork(caseObj,serviceChannelRec));
                            }
                        }
                        else{
                            lstAgentWorkToInsert.add(createAgentWork(caseObj,serviceChannelRec));
                        }
                    }
                    else{
                        //-------- user is not on omni channel. Assign case to original queue---------------------
                        caseObj.OwnerId = caseObj.Original_Queue_ID__c != null ? caseObj.Original_Queue_ID__c : caseObj.OwnerId;
                        caseObj.Status = 'Open';
                        caseObj.Priority = 'High';
                        lstCasesToUpdate.add(caseObj);
                    }
                }
                else{
                    // ---- when there is no original associate on case-------
                    caseObj.OwnerId = caseObj.Original_Queue_ID__c != null ? caseObj.Original_Queue_ID__c : caseObj.OwnerId;
                    caseObj.Status = 'Open';
                    caseObj.Priority = 'High';
                    lstCasesToUpdate.add(caseObj);
                }
            }
            if(!lstAgentWorkToInsert.isEmpty()){
                insert lstAgentWorkToInsert;
            }
            if(!lstCasesToUpdate.isEmpty()){
                update lstCasesToUpdate;
            }
        }
        catch(Exception e){
            //TODO- Log the exception later.
            System.debug('EXCEPTION FOUND ------ '+e.getMessage());
        }
    }

    private static Map<String,List<UserServicePresence>> getMapUservsListUserPresence(Set<String> userIds){
        Map<String,List<UserServicePresence>> mapUservsListUserPresence = new Map<String,List<UserServicePresence>>();
        if(!userIds.isEmpty()){
            for(UserServicePresence uSP : [SELECT id,ConfiguredCapacity,UserId FROM UserServicePresence WHERE UserId IN: userIds AND IsCurrentState = true]){
                if(mapUservsListUserPresence.containsKey(uSP.UserId)){
                    mapUservsListUserPresence.get(uSP.UserId).add(uSP);
                }
                else{
                    mapUservsListUserPresence.put(uSP.UserId, new List<UserServicePresence>{uSP});
                }
            } 
        }
        return mapUservsListUserPresence;
    }

    private static Map<String,List<AgentWork>> getMapUserIdvsListAgentWork(Set<String> userIds){
        Map<String,List<AgentWork>> mapUserIdvsListAgentWork = new Map<String,List<AgentWork>>();
        if(!userIds.isEmpty()){
            for(AgentWork agentWOrkObj :[SELECT id,UserId FROM AgentWork WHERE UserId IN: userIds AND Status = 'Opened']){
                if(mapUserIdvsListAgentWork.containsKey(agentWOrkObj.UserId)){
                    mapUserIdvsListAgentWork.get(agentWOrkObj.UserId).add(agentWOrkObj);
                }
                else{
                    mapUserIdvsListAgentWork.put(agentWOrkObj.UserId,new List<AgentWork>{agentWOrkObj});
                }
            }
        }
        return mapUserIdvsListAgentWork;
    }

    @TestVisible
    private static AgentWork createAgentWork(Case caseObj,ServiceChannel serviceChannelRec){
        AgentWork workObj = new AgentWork();
        workObj.ServiceChannelId = serviceChannelRec.Id;
        workObj.UserId = caseObj.Original_Associate__c;
        workObj.WorkItemId = caseObj.Id;
        workObj.lb_Case__c = caseObj.Id;
        return workObj;
    }
}