/**
 * Created by adamundus on 9/25/20.
 */

@IsTest
private class NF_GetMenuOptionsTest {

    @IsTest
    static void testBehavior() {
        List<String> testDialogs = new List<String>();
        testDialogs.add('bus_order_claim_end');
        testDialogs.add('bus_order_parent_partiallyReturned_end');
        testDialogs.add('bus_order_parent_returned_end');
        testDialogs.add('bus_greeting_partiallyReturned');
        testDialogs.add('bus_greeting_backorder');
        testDialogs.add('bus_greeting_multShipment');
        testDialogs.add('bus_order_oneShipment');
        testDialogs.add('bus_order_returned');
        testDialogs.add('bus_order_cancelled');
        testDialogs.add('bus_order_backorder');
        testDialogs.add('bus_order_multShipment');


        List<NF_GetMenuOptions.Input> inputs = new List<NF_GetMenuOptions.Input>();
        NF_GetMenuOptions.Input inp = new NF_GetMenuOptions.Input();
        inp.isUserAuthenticated = false;
        inp.chatKey = 'abc';
        inputs.add(inp);
        Test.startTest();
        for( String d : testDialogs) {
            inp.dialogName = d;
            inputs[0] = inp;
            List<NF_GetMenuOptions.Output> out = NF_GetMenuOptions.getMenuOptions(inputs);
            System.assertNotEquals(0, out[0].menuOptions.size(), 'should have value');
        }
        Test.stopTest();

    }
}