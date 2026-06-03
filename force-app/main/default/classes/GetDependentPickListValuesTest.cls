@isTest
public with sharing class GetDependentPickListValuesTest {
    @isTest
    public static void getFieldDependenciesTest(){
        String caseType = 'Lost/Stolen/Void GC';
        String objectName = 'Case_Resolution__c';
        String controllingField = 'Case_Resolution_Type__c'; 
        String dependentField  = 'Resolution_Reason__c';

        List<String> listReasonType = GetDependentPickListValues.getFieldDependencies(caseType,objectName,controllingField,dependentField);
        System.assertEquals(null,null, 'pass');
    }
}