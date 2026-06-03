/** Created by sumit saha
 * date: 28-sep-23
 */
@isTest
public with sharing class GraceTrainActionSelectionTest {
    @isTest
    public static void getActionPathTest(){
        GraceTrainActionSelection.Input i = new GraceTrainActionSelection.Input();
        i.selectedMenuOption = 'Test';
        List<GraceTrainActionSelection.Input> input = new  List<GraceTrainActionSelection.Input> ();
        input.add(i);
        GraceTrainActionSelection.getActionPath(input);
    }
}