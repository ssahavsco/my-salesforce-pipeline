/****************************************************************************************************************
* Program Name         : SCS_WordCloudController
* Description          : Test class for SCS_WordCloudController class
* Version              : 1.1
* Modification Log     : 11 May,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-38414      1.1    Chayan Batabyal    11 May,2021      Test class for SCS_WordCloudController class
*****************************************************************************************************************/
@isTest(seeAllData = false)
public class SCS_WordCloudControllerTest {
    @TestSetup
    static void makeData(){
        SocialPost post = new SocialPost(
            Name = 'Test SocialPost ' + LABEL.SCS_WORD_CLOUD_JUNK_WORDS.split(' ')[0],
            Content = 'Just for Cardmembers!',
            Posted = System.now()
        );
        insert post;
    }

    /**
    * @description Testing the getRecordDetails method
    * @author cbatabyal@contractor.lb.com | 05-11-2021
    **/
    public static testMethod void getRecordDetailsTest(){
        Test.startTest();

        System.assert(
            SCS_WordCloudController.getRecordDetails(
                'SocialPost', 'Name', 'Name != null'
            ).isSuccess, 'Success'
        );
        System.assert(
            !SCS_WordCloudController.getRecordDetails(
                'SocialPost', 'Name', 'Name'
            ).isSuccess, 'Unsuccess'
        );

        Test.stopTest();
    }
}