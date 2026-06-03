/**
 * Created by adamundus on 9/16/20.
 */

@IsTest
private class NF_SetBoolTest {
    @IsTest
    static void test1() {
        System.assert(NF_SetBool.setBool(new List<String>{'true'})[0], 'should have true value');
    }
    @IsTest
    static void test2() {
        System.assert(!NF_SetBool.setBool(new List<String>{'false'})[0], 'should have false value');
    }
}