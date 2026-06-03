/***************************************************************
Interface Name : Vs_AgentAssistController
CreatedDate : 06-Nov-22
Description :  DP-59331 - Controller Class to check permission for Five9 Agent Assist
Created By : Pooja

Revision History

Date Name Story Number Description

***************************************************************/

public class Vs_AgentAssistController {
    @AuraEnabled
    public static boolean checkAccess(){

        List<PermissionSetAssignment> permissionSet = new List<PermissionSetAssignment>();
        permissionSet =  [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id =: userinfo.getUserId() and PermissionSet.Name = 'Grant_Access_to_Five9_Agent_Assist'];

        If(!permissionSet.isEmpty()){
            return true;
        }

        return false;
    }
}