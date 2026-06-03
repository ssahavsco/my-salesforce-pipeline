/** created by Sumit Saha
 *
 */

@isTest(SeeAllData=true)
public class VSCCS_parseIntlReturnLinesTest {
  @isTest
  static void testInsertRecords() {
    Case_Resolution__c cr = [
      SELECT Id
      FROM Case_Resolution__c
      WHERE CreatedDate = LAST_N_YEARS:2
      LIMIT 1
    ];

    List<VSCCS_parseIntlReturnLines.OrderLine> orderLines = new List<VSCCS_parseIntlReturnLines.OrderLine>();
    VSCCS_parseIntlReturnLines.OrderLine line = new VSCCS_parseIntlReturnLines.OrderLine();
    line.OrderLineId = 'OL123';
    line.ItemId = 'ITEM001';
    line.ItemDescription = 'Test Item';
    line.SmallImageURI = 'http://example.com/image.jpg';
    line.Quantity = 2;
    line.UserSelectedQuantity = 1;
    line.reasonCode = 'Late arrival';
    orderLines.add(line);

    String returnLinesJson = JSON.serialize(orderLines);

    VSCCS_parseIntlReturnLines.Input input = new VSCCS_parseIntlReturnLines.Input();
    input.caseResolutionId = cr.id.toString();
    input.orderNumber = 'OL123';
    input.returnReasonCode = 'Late arrival';
    input.returnLines = returnLinesJson;

    Test.startTest();
    VSCCS_parseIntlReturnLines.insertRecords(
      new List<VSCCS_parseIntlReturnLines.Input>{ input }
    );
    Test.stopTest();
  }
}