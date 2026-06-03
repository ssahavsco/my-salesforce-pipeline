/**
 * Created by Sumit Saha | Date: 11-Nov-2024
 */

public class VS_LocateChatOrigin {
  @InvocableMethod(
    label='Locate Chat Origin Country'
    description='Locate Chat Origin Country'
    category='Locate Chat Origin'
  )
  public static List<Output> getChatCountry(List<Input> chatkey) {
    List<Output> output = new List<Output>();
    Output obj = new Output();
    System.debug('chatkey :: ' + chatkey[0].chatkey);

    String query;
    try{
      if (
        chatkey[0]
          .chatkey.startswith(
            MessagingSession.sobjecttype.getDescribe().getKeyPrefix()
          )
      ) {
        query =
          'SELECT Id,Language_Code__c,  Location__c FROM MessagingSession where Id = ' +
          '\'' +
          chatkey[0].chatkey +
          '\'';
      } else {
        query =
          'SELECT Id, Language_Code__c, Location FROM LiveChatTranscript where Id = ' +
          '\'' +
          chatkey[0].chatkey +
          '\'';
      }

      List<SObject> chat = Database.query(query);
      String objName = chat.getsobjectType().toString();

      logger.info('Chat ' + chat);
      logger.saveLog();
      if (chat.size() == 1) {
        List<String> city_state_country = new List<String>();
        city_state_country = chat[0].get('Location__c').toString().split(',') ??
          chat[0].get('Location').toString().split(',');
        
        obj.city = city_state_country.size() == 3
          ? city_state_country[0].trim()
          : '';
        obj.state = city_state_country.size() == 3
          ? city_state_country[1].trim()
          : city_state_country[0].trim();
        obj.country = city_state_country.size() == 3
          ? city_state_country[2].trim()
          : city_state_country[1].trim();
        obj.languageCode = (String) chat[0].get('Language_Code__c');
        obj.liveChatTransriptSessionId = (String) chat[0].get('Id');
        obj.isUSAOrigin = obj.country == 'United States' ? true : false;
      } else {
        obj.languageCode = 'en_US';
        obj.liveChatTransriptSessionId = (String) chatkey[0].chatkey;
        obj.isUSAOrigin = true;
      }
      logger.info('Output ' + output);
      logger.saveLog();
      System.debug(output);
      output.add(obj);
      return output;
    } catch(Exception e){
      obj.languageCode = 'en_US';
      obj.liveChatTransriptSessionId = (String) chatkey[0].chatkey;
      obj.isUSAOrigin = true;
      output.add(obj);
      Logger.error('Error while locating chat origin')
      .setExceptionDetails(e)
      .addTag('BotException');
      Logger.saveLog();
      return output;
    }
  }

  public class Output {
    @InvocableVariable
    public Boolean isUSAOrigin;

    @InvocableVariable
    public String city;

    @InvocableVariable
    public String state;

    @InvocableVariable
    public String country;

    @InvocableVariable
    public String languageCode;

    @InvocableVariable
    public String liveChatTransriptSessionId;
  }

  public class Input {
    @InvocableVariable(required=true)
    public string chatkey;
  }
}