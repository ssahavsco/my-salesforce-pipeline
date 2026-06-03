/******************************************************************************************************************************
* Program Name         : LB_ParentObjPersonAccountEdit_Test
* Version              : 1.0
* Modification Log      : 06 April, 2023 
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId        Version    Developer               Date           Description 
*------------------------------------------------------------------------------------------------------------------------------
*   SK_01          DP-64109      1.1       Sumit Saha      04/06/2023      Chat: Add Customer Details for Authenticated Customer                                                                                                                   
********************************************************************************************************************************/


@IsTest
public with sharing class LB_ParentObjPersonAccountEdit_Test {

    @IsTest
    public static void getAccountDetails_Test(){
        List<LB_ParentObjPersonAccountEdit.Input> input = new List<LB_ParentObjPersonAccountEdit.Input>();
        LB_ParentObjPersonAccountEdit.Input i = new LB_ParentObjPersonAccountEdit.Input();

        i.brand = 'VSS';
        i.caseID = createCase();
        i.email = 'MSTESTER1AAA1111@VSS-US.COM';
        input.add(i);

        LoyaltyAccountIntegrationTest.loyaltyDetailsLookupTest(); // Creation of test customer
        LB_ParentObjPersonAccountEdit.getAccountDetails(input);
    }

    public static String createCase(){
        List<RecordType> caseRecordType = new List<RecordType>([SELECT Id from RecordType where Name = 'Chat Case' LIMIT 1]);
        Case cs = new Case();
        cs.Description = 'Test Case';
        cs.RecordTypeId = (Id) caseRecordType[0].get('Id');
        cs.userAuth__c = 'Authenticated';
        cs.AccountId = null;
        Insert cs;
        return (String)cs.Id ;  
    }
}