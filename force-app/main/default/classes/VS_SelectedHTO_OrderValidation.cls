public with sharing class VS_SelectedHTO_OrderValidation {
  public class Input {
    @InvocableVariable(required=false)
    public String chatKey;

    @InvocableVariable
    public HtoOrderResponse htoOrders;
  }
  public class HtoOrderResponse {
    public String htoOrderPlaceHolder;
  }
  public class Output {
    @InvocableVariable
    public Boolean isHTOOrderChoosen;

    @InvocableVariable
    public Boolean isManageSubscriptionChoosen;

    @InvocableVariable
    public Boolean isMakeReturnChoosen;

    @InvocableVariable
    public String orderNumberSelected;
  }
  @InvocableMethod(label='Selected HTO Order Validation')
  public static List<Output> htoOrderSelectionValidation(List<Input> input) {
    Output out = new Output();
    List<Output> outputs = new List<VS_SelectedHTO_OrderValidation.Output>();
    out.isHTOOrderChoosen = false;
    out.isMakeReturnChoosen = false;
    out.isManageSubscriptionChoosen = false;
    try {
      if (input[0].htoOrders != null) {
        String orderValue = input[0].htoOrders.htoOrderPlaceHolder;
        if (orderValue == 'Manage Subscription') {
          out.isManageSubscriptionChoosen = true;
        } else if (orderValue == 'Make a return') {
          out.isMakeReturnChoosen = true;
        } else {
          out.orderNumberSelected = orderValue;
        }
        outputs.add(out);
      }
      return outputs;
    } catch (Exception e) {
      Logger.error(
        'Error while HTO Order Validation' + String.valueOf(e.getMessage())
      );
      Logger.saveLog();
      return outputs;
    }
  }
}