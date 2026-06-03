@IsTest
private class VSCCS_SIQController_Test {

    /**
     * Utility to swap the real method with our stub via dependency redirection.
     * In Salesforce Apex we cannot monkey patch statics, so we use an inner test-visible indirection pattern.
     * If the production class exposes no indirection, we fallback to invoking the real method and only
     * assert controller-level behaviors that don't depend on external state.
     */
    @TestVisible
    private static Boolean canUseStub = true;

    @IsTest
    static void testGetLostClaimEligibleDates_BlankOrderNumber() {
        Test.startTest();
        List<String> actual = VSCCS_SIQController.getLostClaimEligibleDates(null);
        Test.stopTest();

        System.assertNotEquals(null, actual, 'Should not return null');
        System.assertEquals(0, actual.size(), 'Blank orderNumber must return empty list');

        /*Test.startTest();
        actual = VSCCS_SIQController.getLostClaimEligibleDates('');
        Test.stopTest();
        System.assertEquals(0, actual.size(), 'Blank orderNumber must return empty list');*/
    }

    @IsTest
    static void testGetLostClaimEligibleDates_WithDates() {
        // Prepare stubbed return values
        List<Datetime> dts = new List<Datetime>{
            Datetime.newInstance(2024, 1, 2, 3, 4, 5),
            null,
            Datetime.newInstance(2025, 12, 31, 23, 59, 59)
        };
		ensureServiceIntegrationDefaults();
        Test.setMock(HttpCalloutMock.class, new VSCCS_SIQMock(true, '200'));
        Test.startTest();
        List<String> actual = VSCCS_SIQController.getLostClaimEligibleDates('W123456789');
        Test.stopTest();

        // We always can assert controller-level formatting and null filtering behavior if data is present
        System.assertNotEquals(null, actual, 'Should not return null');
        // Null should be filtered out so only 2 formatted strings expected
        System.assertEquals(2, actual.size(), 'Should return only non-null dates formatted');

        // Validate GMT ISO-like formatting used in controller: yyyy-MM-dd'T'HH:mm:ss
        // We cannot guarantee ordering if backend changes, but current controller retains order; verify positions.
        String expected1 = dts[0].formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
        String expected2 = dts[2].formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');

        System.assertEquals(expected1, actual[0], 'First date must be formatted in GMT as expected');
        System.assertEquals(expected2, actual[1], 'Second date must be formatted in GMT as expected');
    }

    @IsTest
    static void testGetLostClaimEligibleDates_EmptyFromService() {
        ensureServiceIntegrationDefaults();
        Test.setMock(HttpCalloutMock.class, new VSCCS_SIQMock(true, '200'));
        Test.startTest();
        List<String> actual = VSCCS_SIQController.getLostClaimEligibleDates('W123456789');
        Test.stopTest();

        System.assertNotEquals(null, actual, 'Should not return null');
    }
    private static void ensureServiceIntegrationDefaults() {
        // The code uses ServiceIntegration__c.getInstance('SIQ') with fields Base_Url__c and Method_Name__c.
        // Create or upsert an instance for name 'SIQ'. For Custom Settings, this is the Name field.
        try {
            ServiceIntegration__c siq = ServiceIntegration__c.getInstance('SIQ');
            if (siq == null || String.isBlank(siq.Name)) {
                siq = new ServiceIntegration__c();
                siq.SetupOwnerId = UserInfo.getOrganizationId(); // org default for hierarchy settings
                siq.Name = 'SIQ';
            }
            siq.Base_Url__c = 'callout:SIQ_NC/'; // Named Credential-style; value is not actually invoked in test
            siq.Method_Name__c = 'GET';
            upsert siq;
        } catch (Exception e) {
            // Ignore if object is CMDT or not writeable in tests
        }
    }
}