/**
* @File Name : SuggestionBoxController_Test.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : April 2, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 2, 2025 |   | Initial Version
**/

@isTest
public class SuggestionBoxController_Test {
    @isTest
    static void testGetUserMapping() {
        // Create active and inactive users
        User activeUser1 = new User(
            FirstName = 'Active',
            LastName = 'User1',
            Email = 'activeuser1@example.com',
            Username = 'activeuser1@example.com' + System.currentTimeMillis(),
            Alias = 'actusr1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert activeUser1;

        User activeUser2 = new User(
            FirstName = 'Active',
            LastName = 'User2',
            Email = 'activeuser2@example.com',
            Username = 'activeuser2@example.com' + System.currentTimeMillis(),
            Alias = 'actusr2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert activeUser2;

        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'User',
            Email = 'inactiveuser@example.com',
            Username = 'inactiveuser@example.com' + System.currentTimeMillis(),
            Alias = 'inactusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        insert inactiveUser;

      

        // Call the method and verify the results
        Test.startTest();
        Map<String, String> userMapping = SuggestionBoxController.getUserMapping('ASSOCIATE ENGAGEMENT/PERFORMANCE: Associate Celebration, Recognition, Wall of Gratitude, etc.');
        Test.stopTest();

     }
}