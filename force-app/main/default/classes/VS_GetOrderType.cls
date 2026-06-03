/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VS_GetOrderType
Created Date       : June 28, 2024
@description       : This Class is used to distinguish different kind of orders
@author            : Himanshu Mishra <hmishra@victoria.com>
@story             : CCS-509
Modification Log:
Ver   Date           	Author            Story/Defect#       Modification
1.0   June 28,2024   	Himanshu Mishra   CCS-509             Initial Version
1.1   January 14,2024   Himanshu Mishra   CCS-827             Added method to get order type as domestic or international 
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class VS_GetOrderType {
  @InvocableMethod(
    label='Get Order Type'
    description='Returns the order type based on the order number.'
  )
  public static List<Output> processOrderNumber(List<Input> inputList) {
    List<Output> outputList = new List<Output>();
    Output out = new Output();
    out.orderType = 'Domestic';
    out.isInternational = false;
    out.customerType = 'DOM';
    try {
      logger.info('Input ' + inputList);
      String orderNumber = isValidOrderNumber(inputList[0].orderNumber)
        ? inputList[0].orderNumber.remove('#')
        : 'I CAN\'T FIND IT';
      String orderPrefix = orderNumber == 'I CAN\'T FIND IT'
        ? 'NA'
        : orderNumber.substring(0, 1);
      //logger.info('orderPrefix ' + orderPrefix);
      //logger.saveLog();
      if (
        orderNumber != null &&
        orderNumber != '' &&
        (orderNumber.length() == 10 ||
        orderPrefix == 'NA')
      ) {
        out.orderType = getOrderType(orderPrefix);
        //logger.info('orderType ' + out.orderType);
        //logger.saveLog();
        out.isInternational = isInternationalOrderNumber(orderPrefix);
        //logger.info('isInternational ' + out.isInternational);
        //logger.saveLog();
        out.customerType = setCustomerType(inputList[0].chatkey, out.orderType);
        //logger.info('customerType ' + out.customerType);

        outputList.add(out);
      } else if (isTikTokOrder(orderNumber)) {
        out.orderType = 'TikTok';
        out.isInternational = isInternationalOrderNumber(orderPrefix);
        out.customerType = setCustomerType(inputList[0].chatkey, out.orderType);
        outputList.add(out);
      }
    } catch (Exception e) {
      outputList.add(out);
      Logger.error('Error while getting order type ')
        .setExceptionDetails(e)
        .addTag('BotException');
    }
    // String customerType =  setCustomerType(inputList[0].chatkey, outputList[0].orderType);
    logger.saveLog();
    return outputList;
  }

  /*
    ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    @Method Name    : getOrderType
    @author         : Himanshu Mishra <hmishra@victoria.com>
    @description    : This method is user to get order type from the order number
    @param          : orderNumber
    @return         : orderType
    ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    */
  public static String getOrderType(String orderPrefix) {
    String orderType = '';
    switch on orderPrefix {
      when 'T' {
        orderType = 'HTO';
      }
      when 'E' {
        orderType = 'eShopWorld';
      }
      when 'G' {
        orderType = 'Global-e';
      }
      when 'R' {
        orderType = 'Blind Return';
      }
      when 'Y' {
        orderType = 'Global-e Return';
      }
      when 'K' {
        orderType = 'EU Return';
      }
      when 'U' {
        orderType = 'EU Order';
      }
      when 'V' {
        orderType = 'EU Claim';
      }
      when 'W' {
        orderType = 'Domestic';
      }
      when 'H' {
        orderType = 'ShopPay';
      }
      when 'NA' {
        orderType = 'NA';
      }
      when else {
        orderType = 'Return';
      }
    }
    return orderType;
  }

  // Helper method to check if a given order number is International order
  public static Boolean isInternationalOrderNumber(String orderNumberPrefix) {
    // Order number should be 10 characters long and start with an alphabet
    String internationalOrderNumberPrefix = Label.International_Order_Prefixes;
    return Pattern.compile(internationalOrderNumberPrefix)
      .matcher(orderNumberPrefix)
      .matches();
  }
  // Helper method to check if a given order number is TikTok order
  public static Boolean isTikTokOrder(String orderNumber) {
    // Order number should be 18 characters long
    String tiktokRegex = '^([A-Za-z0-9]{18})$';
    Pattern tikTokPattern = Pattern.compile(tiktokRegex);
    Matcher tikTokMatcher = tikTokPattern.matcher(orderNumber);
    return tikTokMatcher.matches();
  }

  /**
   * @description set the customer type in Bot Session obj
   * @author Sumit Saha
   * @param  chatkey chatkey description
   */

  public static String setCustomerType(String chatkey, String orderType) {
    VS_LocateChatOrigin.Input i = new VS_LocateChatOrigin.Input();
    i.chatkey = chatkey;
    List<VS_LocateChatOrigin.Input> input = new List<VS_LocateChatOrigin.Input>();
    input.add(i);
    List<VS_LocateChatOrigin.Output> output = new List<VS_LocateChatOrigin.Output>();
    output = VS_LocateChatOrigin.getChatCountry(input);

    try {
      Customer_Type_Ruleset__mdt[] mdt = [
        SELECT
          Customer_Type__c,
          DeveloperName,
          Id,
          Order_Type__c,
          QualifiedApiName,
          USA_Origin__c
        FROM Customer_Type_Ruleset__mdt
        WHERE
          USA_Origin__c = :output[0].isUSAOrigin
          AND Order_Type__c = :orderType
      ];

      String customerType;
      if (mdt.size() == 1) {
        Messaging_Insight__c[] bs = new List<Messaging_Insight__c>(
          [
            SELECT Id, Messaging_Session__c, Customer_Type__c
            FROM Messaging_Insight__c
            WHERE Messaging_Session__c = :output[0].liveChatTransriptSessionId
          ]
        );
        if (bs.size() == 1) {
          try {
            customerType = mdt[0].Customer_Type__c;
            bs[0].Customer_Type__c = mdt[0].Customer_Type__c;
            update bs;
          } catch (Exception e) {
            logger.error(e.getMessage());
            logger.saveLog();
          }
        }
      } else {
        Logger.error('No Customer Type Rule found').addTag('BotException');
        Logger.saveLog();
      }
      return (String) customerType;
    } catch (Exception e) {
      Logger.error('Error while getting order type')
        .setExceptionDetails(e)
        .addTag('BotException');
      Logger.saveLog();
      return 'DOM';
    }
  }

  public static Boolean isValidOrderNumber(String orderNumber) {
    if (String.isBlank(orderNumber)) {
      return false;
    }
    orderNumber = orderNumber.trim();

    // 10-digit numeric domestic orders
    if (Pattern.matches('^[A-Za-z][0-9]{9}$', orderNumber)) {
      return true;
    }

    // 18-digit numeric TikTok orders
    if (Pattern.matches('^[0-9]{18}$', orderNumber)) {
      return true;
    }

    return false;
  }

  public class Input {
    @InvocableVariable
    public String orderNumber;

    @InvocableVariable(required=false)
    public String chatkey;
  }
  public class Output {
    @InvocableVariable
    public String orderType;

    @InvocableVariable
    public Boolean isInternational;

    @InvocableVariable
    public String customerType;
  }
}