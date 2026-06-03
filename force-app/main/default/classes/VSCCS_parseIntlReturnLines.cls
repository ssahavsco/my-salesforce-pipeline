/** created by Sumit Saha
 *
 */

public class VSCCS_parseIntlReturnLines {
  public class OrderLine {
    public String OrderLineId;
    public String ItemId;
    public String ItemDescription;
    public String SmallImageURI;
    public Integer Quantity;
    public Integer UserSelectedQuantity;
    public String reasonCode;
  }

  public class Input {
    @InvocableVariable(required=true)
    public String caseResolutionId;
    @InvocableVariable(required=true)
    public String orderNumber;
    @InvocableVariable(required=false)
    public String returnReasonCode;
    @InvocableVariable(required=true)
    public String returnLines;
  }

  @InvocableMethod(
    label='Insert INTL Return Lines'
    category='International Return Lines'
  )
  public static void insertRecords(List<Input> input) {
    List<OrderLine> orderLines = (List<OrderLine>) System.JSON.deserialize(
      input[0].returnLines,
      List<OrderLine>.class
    );

    List<International_Return_Lines__c> listName = new List<International_Return_Lines__c>();

    for (OrderLine ord : orderLines) {
      International_Return_Lines__c c = new International_Return_Lines__c();
      c.Order_Line_Id__c = ord.OrderLineId;
      c.Item_Name__c = ord.ItemId;
      c.Item_Description__c = ord.ItemDescription;
      c.Item_Image_Link__c = ord.SmallImageURI;
      c.Quantity__c = ord.UserSelectedQuantity;
      c.Line_Level_Reason__c = ord.reasonCode;
      c.Case_Resolution__c = input[0].caseResolutionId;
      c.Order_Number__c = input[0].orderNumber;
      listName.add(c);
    }

    try {
      insert listName;
    } catch (Exception e) {
      logger.error(
        'Exception in inserting Return Order Lines:: ' + e.getMessage()
      );
      logger.saveLog();
    }
  }
}