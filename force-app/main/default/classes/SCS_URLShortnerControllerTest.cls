/****************************************************************************************************************
* Program Name         : SCS_URLShortnerControllerTest
* Description          : Test class for scs_UrlShortner LWC
* Version              : 1.2
* Modification Log     : 22 April,2021.
* Modification Log     : 05 May,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-39681      1.1    Chayan Batabyal    22 April,2021    Test class for scs_UrlShortner LWC
*   CB_02          DP-40793      1.2    Chayan Batabyal    05 May,2021      Included the test methods for schedulable methods & limit counts
*****************************************************************************************************************/
@isTest(seeAllData = false)
public with sharing class SCS_URLShortnerControllerTest {
    /**
    * @description Setup Data for test class
    * @author cbatabyal@contractor.lb.com | 04-22-2021
    **/
    @TestSetup
    static void makeData(){
        SocialPost post = new SocialPost(
            Name = 'Test SocialPost',
            Content = 'Just for Cardmembers!',
            Posted = System.now()
        );
        insert post;

        insert new Support_Time_Threshold__c(Name = 'TestChayan');
    }

    /**
    * @description Test method for generateShortURL
    * @author cbatabyal@contractor.lb.com | 04-22-2021
    **/
    public static testMethod void generateShortURLTest(){
        Test.startTest();

        SocialPost post = [SELECT Id FROM SocialPost LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new TestHttpMock(
            200, 'OK', '{"plan_limits":[{"name":"encodes","limit":1000,"count":2}]}')
        );

        System.assertEquals(
            true, SCS_URLShortnerController.generateShortURL(
                'https://login.salesforce.com', post.Id, 'Brand__c'
            ).isSuccess, 'Callout Successful'
        );

        System.assertEquals(
            false, SCS_URLShortnerController.generateShortURL(
                'https://login.salesforce.com', post.Id, 'WrongFieldAPIName__c'
            ).isSuccess, 'Callout Unsuccessful'
        );

        System.assertEquals(
            null, SCS_URLShortnerController.generateShortURL(
                null, null, null
            ), 'Null Response'
        );

        Test.stopTest();
    }

    /**
    * @description Tests the update of threshold records for Pink config
    * @author cbatabyal@contractor.lb.com | 05-03-2021
    **/
    public static testMethod void updateSupportTimeThresholdPink(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new TestHttpMock(
            200, 'OK', '{"plan_limits":[{"name":"encodes","limit":2,"count":2}]}')
        );

        SCS_URLShortnerController.updateSupportTimeThreshold('pink');

        Test.stopTest();

        System.assertEquals(2, [
            SELECT Id, Number_of_Shortened_URLs_Pink__c, Number_of_Shortened_URLs_VS__c
            FROM Support_Time_Threshold__c
        ][0].Number_of_Shortened_URLs_Pink__c, 'Set count to 2');
    }

    /**
    * @description Tests the scheduling of counter reset
    * @author cbatabyal@contractor.lb.com | 05-03-2021
    **/
    public static testMethod void executeTest(){
        Test.startTest();

        String jobId = System.schedule(
            'Reset Bitly Counter Test',
            '0 0 0 1 * ? *',
            new SCS_URLShortnerController()
        );
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE id =: jobId];
        System.assertEquals(ct.Id, jobId, 'Job Created');

        Test.stopTest();
    }

    /**
    * @description Tests the invocable method for url shortening
    * @author cbatabyal@contractor.lb.com | 05-03-2021
    **/
    public static testMethod void generateShortURLInvocablePositiveTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new TestHttpMock(
            200, 'OK', '{"link":"shortenedURL"}'
        ));

        List<SCS_URLShortnerController.FlowRequestWrapper> flowInputs =
            new List<SCS_URLShortnerController.FlowRequestWrapper>();
        SCS_URLShortnerController.FlowRequestWrapper wrap =
            new SCS_URLShortnerController.FlowRequestWrapper();

        wrap.urlToShorten = 'https://login.salesforce.com';
        wrap.recordId = [SELECT Id FROM SocialPost LIMIT 1].Id;
        wrap.fieldAPIName = 'Brand__c';
        flowInputs.add(wrap);

        System.assertEquals(
            true,
            SCS_URLShortnerController.generateShortURL(flowInputs)[0].isSuccess,
            'Callout Successful'
        );

        Test.stopTest();
    }

    /**
    * @description Tests the invocable method for url shortening
    * @author cbatabyal@contractor.lb.com | 05-03-2021
    **/
    public static testMethod void generateShortURLInvocableNegativeTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new TestHttpMock(
            200, 'OK', '{"description":"Something is wrong, I can feel it ~ Eminem"}'
        ));

        List<SCS_URLShortnerController.FlowRequestWrapper> flowInputs =
            new List<SCS_URLShortnerController.FlowRequestWrapper>();
        SCS_URLShortnerController.FlowRequestWrapper wrap =
            new SCS_URLShortnerController.FlowRequestWrapper();

        wrap.urlToShorten = 'https://login.salesforce.com';
        wrap.recordId = [SELECT Id FROM SocialPost LIMIT 1].Id;
        wrap.fieldAPIName = 'Brand__c';
        flowInputs.add(wrap);

        System.assertEquals(
            false,
            SCS_URLShortnerController.generateShortURL(flowInputs)[0].isSuccess,
            'Callout Unsuccessful'
        );

        Test.stopTest();
    }
}