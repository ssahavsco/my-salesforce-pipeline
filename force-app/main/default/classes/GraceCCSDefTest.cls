/** Created by Sumit Saha 
 *  10-Oct-2023
 */
@isTest
public with sharing class GraceCCSDefTest {
    @isTest
    public static void getCCSDefinationTest(){
        GraceCCSDef.Input i = new GraceCCSDef.Input();
        i.selectedMenu = 'Fulfilled';
        List<GraceCCSDef.Input> input = new List<GraceCCSDef.Input>();
        input.add(i);
        GraceCCSDef.getCCSDefination(input);

    }
    @isTest
    public static void getCCSDefinationNoRecordTest(){
        GraceCCSDef.Input i = new GraceCCSDef.Input();
        i.selectedMenu = 'NO_RECORDS';
        List<GraceCCSDef.Input> input = new List<GraceCCSDef.Input>();
        input.add(i);
        GraceCCSDef.getCCSDefination(input);

    }
}