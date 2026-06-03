/**
 * Created by adamundus on 9/16/20.
 */

@IsTest
private class NF_GetRandomResponseTest {
    @IsTest
    static void test1() {
        NF_GetRandomResponse.Input input = new NF_GetRandomResponse.Input();
        input.intentName = 'nonexistent';
        System.assert(NF_GetRandomResponse.getResponse(new List<NF_GetRandomResponse.Input>{input})[0].response == null);
    }
}