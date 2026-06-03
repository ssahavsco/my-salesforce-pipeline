/*****************************************************************************************************
Class Name     :  VSCCS_PostChatSurveyControllerTest
Purpose        :  Test class for VSCCS_PostChatSurveyController
               :  CSAT data will be stored in a custom object 'Survey Results'
               :  Post chat survey will be displayed only for chats that have been transferred 

History:
-------
VERSION  AUTHOR                 DATE                 DETAIL                      TICKET REFERENCE/ NO.
1.       Himanshu Mishra        05/23/2025           Original Version      		 MIAW Migration
@Testsuite:  {VSCCS_PostChatSurveyControllerTest}                                       
*********************************************************************************************************/
@IsTest
public class VSCCS_PostChatSurveyControllerTest {
  @IsTest
  public static void testConstructor() {
    VSCCS_PostChatSurveyController chatSurvey = new VSCCS_PostChatSurveyController();
    chatSurvey.languageCode = 'zh_CN';
    chatSurvey.getItemsList();
    //NF_PostChatSurvey pageRef = Page.NF_PostChatSurvey; // Your VF page name
    PageReference pageRef = new PageReference('/apex/NF_PostChatSurvey');
    Test.setCurrentPage(pageRef);
    String testSessionId = NF_UtilTest.createMessagingSession();
    ApexPages.currentPage().getParameters().put('id', testSessionId);
    VSCCS_PostChatSurveyController testController = new VSCCS_PostChatSurveyController(
      testSessionId
    );
    testController.wouldChatAgain = 1;
    testController.overallExperience = 4;
    testController.questionSatisfaction = 2;
    testController.additionalComments = 'This is a test';
    System.assertNotEquals(null, testController, 'should have value');
  }

  @IsTest
  public static void testSaveFormResponses() {
    String testSessionId = NF_UtilTest.createMessagingSession();
    ApexPages.currentPage().getParameters().put('id', testSessionId);
    VSCCS_PostChatSurveyController testController = new VSCCS_PostChatSurveyController(
      testSessionId
    );
    testController.wouldChatAgain = 1;
    testController.overallExperience = 4;
    testController.questionSatisfaction = 2;
    testController.additionalComments = 'This is a test';
    testController.saveResponsesToMessagingInsight();
    System.assertNotEquals(null, testController, 'should have value');
  }

  /*@IsTest
  public static void testSaveFormResponses_fullInput() {
    VSCCS_PostChatSurveyController testController = new VSCCS_PostChatSurveyController(
      'test123'
    );

    testController.wouldChatAgain = 1;
    testController.overallExperience = 4;
    testController.questionSatisfaction = 2;
    testController.additionalComments = 'This is a test';

    LiveChatTranscript lct = NF_UtilTest.insertLiveChatTranscript(
      'abc',
      null,
      null
    );
    testController.chatKey = lct.ChatKey;

    testController.saveResponsesToBotSession();
    System.assertNotEquals(null, testController, 'should have value');
  }*/
}