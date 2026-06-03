/*****************************************************************************************************
Class Name     :  VSCCS_GetEinsteinBotDynamicContentTest
Purpose        :  Test class for VSCCS_GetEinsteinBotDynamicContent
               :  To get the minicard/accordion metadata record
               :  To get the chat carousel content

History:
-------
VERSION  AUTHOR                 DATE                 DETAIL                      TICKET REFERENCE/ NO.
NF_ChatTranscriptDataFixBatchTest1.       Himanshu Mishra        05/23/2025           Original Version      		 MIAW Migration
@Testsuite:  {VSCCS_GetEinsteinBotDynamicContentTest}                                       
*********************************************************************************************************/
@IsTest
public class VSCCS_GetEinsteinBotDynamicContentTest {
  @IsTest
  public static void testGetEinsteinBotDynamicContent() {
    // Call the getEinsteinBotDynamicContent method with the test data
    String result = VSCCS_GetEinsteinBotDynamicContent.getEinsteinBotDynamicContent(
      'Account_Analysis'
    );
  }

  @IsTest
  public static void testGetCarouselContent() {
    // Create a test Messaging_Insight__c record
    Messaging_Insight__c testInsight = new Messaging_Insight__c(
      CarouselContent__c = 'This is a test carousel content'
    );
    insert testInsight;

    // Call the getCarouselContent method with the test data
    String result = VSCCS_GetEinsteinBotDynamicContent.getCarouselContent(
      testInsight.Id
    );
  }
}