/*****************************************************************************************************
Class Name     :  VSCCS_GetEinsteinBotDynamicContentTest
Purpose        :  Test class for VSCCS_GetEinsteinBotDynamicContent
               :  To get the minicard/accordion metadata record
               :  To get the chat carousel content

History:
-------
VERSION  AUTHOR                 DATE                 DETAIL                      TICKET REFERENCE/ NO.
1.       Himanshu Mishra        02/06/2025           Original Version      		 MIAW Migration
@Testsuite:  {VSCCS_GetEinsteinBotDynamicContentTest}                                       
*********************************************************************************************************/
public without sharing class VSCCS_GetEinsteinBotDynamicContent {
  @AuraEnabled
  public static String getEinsteinBotDynamicContent(String name) {
    Einstein_Bot_Dynamic_Content__mdt botContent = [
      SELECT Content__c
      FROM Einstein_Bot_Dynamic_Content__mdt
      WHERE DeveloperName = :name
    ];
    if (botContent != null) {
      return botContent.Content__c;
    }
    return '';
  }

  @AuraEnabled
  public static String getCarouselContent(String recordId) {
    try {
      System.debug('RecordId: ' + recordId);
      System.debug(
        'CarouselContent__c :: ' +
        Schema.sObjectType.Messaging_Insight__c.fields.CarouselContent__c.isAccessible()
      );
      System.debug(
        'Messaging_Session__c :: ' +
        Schema.sObjectType.Messaging_Insight__c.fields.Messaging_Session__c.isAccessible()
      );
      logger.info(
        '###1 ' +
        Schema.sObjectType.Messaging_Insight__c.fields.CarouselContent__c.isAccessible()
      );
      logger.info(
        '###2 ' +
        Schema.sObjectType.Messaging_Insight__c.fields.Messaging_Session__c.isAccessible()
      );
      logger.saveLog();
      List<Messaging_Insight__c> carouselContentList = [
        SELECT Messaging_Session__c, CarouselContent__c
        FROM Messaging_Insight__c
        WHERE Messaging_Session__c = :recordId AND CreatedDate = TODAY
        LIMIT 1
      ];
      System.debug('carouselContentList :: ' + carouselContentList);
      if (!carouselContentList.isEmpty()) {
        return carouselContentList[0].CarouselContent__c;
      } else {
        return null;
      }
    } catch (Exception e) {
      System.debug('==> ' + e.getMessage());
      return null;
    }
  }
}