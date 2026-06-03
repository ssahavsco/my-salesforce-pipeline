/** Created by Sumit Saha 
 *  10-Oct-2023
 */
@istest
public with sharing class GraceDialougeYesNoTest {
    @isTest
    public static void getCCSDefinationYesTest(){  
        GraceDialougeYesNo.Input i = new GraceDialougeYesNo.Input();
        i.associateResponse = 'Yes';
        i.selectedMenu = 'Fulfilled';
        List<GraceDialougeYesNo.Input> input = new List<GraceDialougeYesNo.Input>();
        input.add(i);
        GraceDialougeYesNo.getCCSDefination(input);
    }
    @isTest
    public static void getCCSDefinationNoTest(){  
        GraceDialougeYesNo.Input i = new GraceDialougeYesNo.Input();
        i.associateResponse = 'No';
        i.selectedMenu = 'Fulfilled';
        List<GraceDialougeYesNo.Input> input = new List<GraceDialougeYesNo.Input>();
        input.add(i);
        GraceDialougeYesNo.getCCSDefination(input);
    }
    @isTest
    public static void getCCSDefinationNoRecordTest(){  
        GraceDialougeYesNo.Input i = new GraceDialougeYesNo.Input();
        i.associateResponse = 'No Records';
        i.selectedMenu = 'No Records';
        List<GraceDialougeYesNo.Input> input = new List<GraceDialougeYesNo.Input>();
        input.add(i);
        GraceDialougeYesNo.getCCSDefination(input);
    }
}