@IsTest
private class RestrictUnauthorizedAPIAcEvent_Test {

   
    @IsTest
    static void testEvaluate_GuestUserBlocked() {
        // Arrange
        Profile guestProfile = [SELECT Id, Name, UserLicense.Name FROM Profile WHERE UserType = 'Guest' LIMIT 1];
        User guestUser = new User(
            Alias = 'guser',
            Email = 'guestuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Guest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            ProfileId = guestProfile.Id,
            Username = 'guestuser_' + System.currentTimeMillis() + '@test.com'
        );
        insert guestUser;

        ApiEvent apiEvent = new ApiEvent();
        apiEvent.UserId = guestUser.Id;

        RestrictUnauthorizedAPIAcEventCondition condition = new RestrictUnauthorizedAPIAcEventCondition();

        // ✅ Call the public interface method (SObject argument)
        Boolean result = condition.evaluate((SObject)apiEvent);

        System.assertEquals(true, result, 'Guest user API access should be blocked.');
    }

    @IsTest
    static void testEvaluate_NormalUserAllowed() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User normalUser = new User(
            Alias = 'nuser',
            Email = 'normaluser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Normal',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            ProfileId = standardProfile.Id,
            Username = 'normaluser_' + System.currentTimeMillis() + '@test.com'
        );
        insert normalUser;

        ApiEvent apiEvent = new ApiEvent();
        apiEvent.UserId = normalUser.Id;

        RestrictUnauthorizedAPIAcEventCondition condition = new RestrictUnauthorizedAPIAcEventCondition();

        // ✅ Use (SObject) cast to ensure correct visibility
        Boolean result = condition.evaluate((SObject)apiEvent);

        System.assertEquals(false, result, 'Normal user should not be blocked.');
    }

    

    @IsTest
    static void testEvaluate_NonApiEvent() {
        LoginEvent loginEvent = new LoginEvent();

        RestrictUnauthorizedAPIAcEventCondition condition = new RestrictUnauthorizedAPIAcEventCondition();

        // ✅ Passing another event type to trigger "when else" branch
        Boolean result = condition.evaluate((SObject)loginEvent);

        System.assertEquals(false, result, 'Non-API events should return false.');
    }
}