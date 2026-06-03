/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Description : This Class will validate the HTO Subcription options from Simone
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Sharath Vadla  <svadla@victoria.com>
 * @version        1.0
 * @created        08/22/2023
 * @modified       10/22/2023
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * Modifications Log
 * Ver   Story#     Date         Author              Modification
 * 1.0   CCS-43      08/22/2023   Sharath Vadla       Initial Version.
 * 1.1               10/22/2023   Sharath Vadla       Added Nebula Loggers
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class VS_HTO_ManageSubscriptionValidation {
  public class Input {
    @InvocableVariable(required=false)
    public String chatKey;

    @InvocableVariable
    public HtoSubscriptionMenu htoSubscriptionMenu;
  }
  public class HtoSubscriptionMenu {
    public String htoSubcriptionMenuPlaceHolder;
  }
  public class Output {
    @InvocableVariable
    public Boolean isUpdateFrequencySelected;

    @InvocableVariable
    public Boolean isSkipNextBoxSelected;

    @InvocableVariable
    public Boolean isPause2MonthsSelected;

    @InvocableVariable
    public Boolean isPause3MonthsSelected;

    @InvocableVariable
    public Boolean isCancelSubscriptionSelected;

    @InvocableVariable
    public Boolean isMoreSelected;
    @InvocableVariable
    public String htoBoxFrequency;
  }

  @InvocableMethod(label='Selected HTO Manage Subscription Validation')
  public static List<Output> htoManageSubscriptionSelectionValidation(
    List<Input> input
  ) {
    Output out = new Output();
    List<Output> outputs = new List<VS_HTO_ManageSubscriptionValidation.Output>();
    out.isUpdateFrequencySelected = false;
    out.isSkipNextBoxSelected = false;
    out.isPause2MonthsSelected = false;
    out.isPause3MonthsSelected = false;
    out.isCancelSubscriptionSelected = false;
    out.isMoreSelected = false;
    try {
      if (input[0].htoSubscriptionMenu != null) {
        String selectedMenuItem = input[0]
          .htoSubscriptionMenu.htoSubcriptionMenuPlaceHolder;
        switch on selectedMenuItem {
          when 'Update Frequency' {
            out.isUpdateFrequencySelected = true;
          }
          when 'Skip Next Box' {
            out.isSkipNextBoxSelected = true;
          }
          when 'Pause 2 Months' {
            out.isPause2MonthsSelected = true;
            out.htoBoxFrequency = '2months';
          }
          when 'Pause 3 Months' {
            out.isPause3MonthsSelected = true;
            out.htoBoxFrequency = '3months';
          }
          when 'Cancel Subscription' {
            out.isCancelSubscriptionSelected = true;
          }
          when 'More' {
            out.isMoreSelected = true;
          }
          when else {
            System.debug('Nothing Selected');
          }
        }
        outputs.add(out);
      }
      return outputs;
    } catch (Exception e) {
      Logger.error(
        'Simone-Exception while choosing Subscription option at line number ' +
          e.getStackTraceString() +
          'and the exception is : ' +
          e.getMessage()
      );
      Logger.saveLog();
      return outputs;
    }
  }
}