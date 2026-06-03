@isTest 
private class NF_UtilCustomPicklistTest {
    @IsTest
    static void validateStoreAssociateValues() {
        User u = NF_UtilTest.generateSampleUserForProfile('Chat Associate');
        Test.startTest();
        System.runAs(u){
            List<NF_UtilCustomPicklist.CustomPicklistValue> picklistEntities = NF_UtilCustomPicklist.getAvailableRecordTypes('Case');
            Boolean foundTestCaseRT = false;
            for (NF_UtilCustomPicklist.CustomPicklistValue ple : picklistEntities) {
                String lab = ple.label;
                String val = ple.value;
                Boolean sel = ple.selected;
                if (ple.label == 'Chat Case') {
                    foundTestCaseRT = true;
                }
            }
            System.assertEquals(true, foundTestCaseRT, 'Chat Associate profile should have access to the Chat Case Record Type.');

            picklistEntities = null;
            try {
                picklistEntities = NF_UtilCustomPicklist.getAvailableRecordTypes('CaseFake');
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e, 'Invalid object types should throw an AuraHandledException');
                System.assertEquals(null, picklistEntities, 'Invalid object types should get angry and throw an Aura exception');
            }
            

            picklistEntities = NF_UtilCustomPicklist.getAvailablePicklistValues('Case', 'Status');
            Boolean foundPicklistValue = false;
            for (NF_UtilCustomPicklist.CustomPicklistValue ple : picklistEntities) {
                if (ple.label == 'New') {
                    foundPicklistValue = true;
                }
            }
            System.assertEquals(true, foundPicklistValue, 'Store Associate profile should have access to the Case Status New.');


            picklistEntities = null;
            try {
                picklistEntities = NF_UtilCustomPicklist.getAvailablePicklistValues('Case', 'StatFake');
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e, 'Invalid fields should throw an AuraHandledException');
                System.assertEquals(null, picklistEntities, 'Invalid fields should get angry and throw an Aura exception');
            }
            try {
                picklistEntities = NF_UtilCustomPicklist.getAvailablePicklistValues('CaseFake', 'StatFake');
            } catch (AuraHandledException e) {
                System.assertNotEquals(null, e, 'Invalid sobjects should throw an AuraHandledException');
                System.assertEquals(null, picklistEntities, 'Invalid sobjects should get angry and throw an Aura exception');
            }
            try {
                picklistEntities = NF_UtilCustomPicklist.getAvailablePicklistValues('Case', 'Description');
            } catch (AuraHandledException e) {
            }
            System.assertEquals(0, picklistEntities.size(), 'Non-picklist fields return a blank array.');
            
        }
        Test.stopTest();
    }
}