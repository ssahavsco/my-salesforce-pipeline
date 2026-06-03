/****************************************************************************************************************
* Program Name         : NF_GenericTriggerHandler
* Description          : Class to provide test coverage on a generic
* Version              : 1.0
* Modification Log     : 16 April,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId       Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   DK_01          DP-38755      1.0       Peter Waddington     16 April,2021       Generic Trigger Handler for Test Coverage                                                                                                                                                                                 
*****************************************************************************************************************/

public with sharing class NF_GenericTriggerHandler extends NF_TriggerHandler {
    public Boolean checkIsDisabled() {
        return this.isDisabled();
    }
}