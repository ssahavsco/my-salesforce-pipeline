/**
 * Created by NeuraFlash LLC on 11/4/19.
 */

@IsTest
private class NF_IncrementIntTest {
    @IsTest
    static void test1() {
        System.assert(NF_IncrementInt.increment(new List<Integer>{1})[0] == 2, 'should be 2');
    }
}