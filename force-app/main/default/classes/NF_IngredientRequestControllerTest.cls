/**************************************************************************************************************************
* Program Name         : NF_IngredientRequestControllerTest
* Description          : Test class for NF_IngredientRequestController Apex Class
* Version              : 1.1
* Modification Log     : 22 Jul,2021.
*--------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*--------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-38057      1.1    Chayan Batabyal    22 Jul,2021      Covers and tests the functionalities of the
                                                                            NF_IngredientRequestController Apex Class
***************************************************************************************************************************/
@isTest(seeAllData = false)
public class NF_IngredientRequestControllerTest {
    
    //Setup method for the test class
    @TestSetup
    static void makeData(){
        Test.startTest();

        Id personAccountRecordTypeId =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(
            RecordTypeId = personAccountRecordTypeId,
            LastName = 'Test Name'
        );
        insert acc;

        Case cs = new Case(
            AccountId = acc.Id
        );
        insert cs;
        
        Product__c vsProd = new Product__c(
            Full_Ingredient_List__c = 'Ingredient1, Ingredient2',
            Product_Variant__c = 'zz12345688'
        );
        insert vsProd;
        
        insert new Case_Product__c(
            Case__c = cs.Id,
            Product__c = vsProd.Id,
            Customer_Has_Product__c = 'Yes'
        );
    }
    
    //Checks the functionality of the methods
    public static testMethod void AllMethodsTest(){
        Test.startTest();
        
        NF_IngredientRequestController objClass = new NF_IngredientRequestController();
        objClass.currentCaseId = [SELECT Id FROM Case LIMIT 1].Id;
        System.assert(String.isNotBlank(objClass.getTopSectionValue()));
        System.assert(String.isNotBlank(objClass.getBottomSectionValue()));
        System.assert(objClass.wrapperList[0].ingredients.equalsIgnoreCase('Ingredient1, Ingredient2'));
        
        update new Product__c(
            Id = [SELECT Id FROM Product__c LIMIT 1].Id,
            Full_Ingredient_List__c = ''
        );
        System.assert(String.isNotBlank(objClass.getTopSectionValue()));
        System.assert(objClass.wrapperList[0].ingredients.equalsIgnoreCase('No ingredients listed for this product'));
        
        Test.stopTest();
    }
}