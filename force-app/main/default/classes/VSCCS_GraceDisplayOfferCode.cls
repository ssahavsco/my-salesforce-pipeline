/*****************************************************************************************************@@
Class Name     :  VSCCS_GraceDisplayOfferCode
Description    :  Display KOD offer codes details in einstein bot(Grace)
Modification log : 
-------
VERSION  AUTHOR                 DATE                DETAIL                                  TICKET REFERENCE/ NO.
1.      Himanshu Mishra        10/29/25          Original dev                               CCS-1265
  
*********************************************************************************************************/
public with sharing class VSCCS_GraceDisplayOfferCode {
    
  public class Input {
    @InvocableVariable(required=false)
    public String routableId;

    @InvocableVariable(required=false)
    public String offerCode;

    @InvocableVariable(required=false)
    public String digitalDisclaimer;

    @InvocableVariable(required=false)
    public String gwpItemNumber;

    @InvocableVariable(required=false)
    public String liveOpsInfo;

    @InvocableVariable(required=false)
    public String productExcludedText;

    @InvocableVariable(required=false)
    public String offerStartDate;

    @InvocableVariable(required=false)
    public String offerExpiryDate;
  }

  public class Output {
    public Boolean success = false;
  }

  @InvocableMethod(label='VS - Grace Display Offer Code')
  public static List<String> display(List<Input> input) {
    try{
      List<Output> outputs = new List<Output>();
      Output out = new Output();

      String routableId = input[0].routableId;
      String digitalDisclaimer = input[0].digitalDisclaimer;
      String offerCodeName = input[0]?.offerCode?.length() > 97 ? input[0]?.offerCode?.substring(97) : input[0]?.offerCode;
      String gwpItemNumber = String.isNotBlank(input[0].gwpItemNumber) ? 
      '<div class=\'content\' style=\'overflow: auto; margin: 3px; text-align: left; zoom: 75%; \'> GWP Item Number: ' +
      '<b>' + input[0].gwpItemNumber + '</b></div>' : '';
      String liveOpsInfo = String.isNotBlank(input[0].liveOpsInfo) ? 
      '<div class=\'content\' style=\'overflow: auto; margin: 3px; text-align: left; zoom: 75%; \'>' +
      input[0].liveOpsInfo + '</div>' : '';
      String productExcludedText = String.isNotBlank(input[0].productExcludedText) ? 
      '<div class=\'content\' style=\'overflow: auto; margin: 3px; text-align: left; zoom: 75%; \'> Items Excluded: ' +
      input[0].productExcludedText + '</div>' : '';
      String dates = '';
      if(String.isNotBlank(input[0].offerStartDate) && String.isNotBlank(input[0].offerExpiryDate)){
          dates = '<div class=\'content\' style=\'overflow: auto; margin: 3px; text-align: left; zoom: 75%; \'>' +
      input[0].offerStartDate + ' - ' + input[0].offerExpiryDate + '</div>';
      }else if(String.isNotBlank(input[0].offerStartDate) && String.isBlank(input[0].offerExpiryDate)){
          dates = '<div class=\'content\' style=\'overflow: auto; margin: 3px; text-align: left; zoom: 75%; \'>' +
          input[0].offerStartDate + '</div>';
      } else if(String.isBlank(input[0].offerStartDate) && String.isNotBlank(input[0].offerExpiryDate)){
          dates = '<div class=\'content\' style=\'overflow: auto; margin: 3px; text-align: left; zoom: 75%; \'>' + 
          input[0].offerExpiryDate + '</div>';
      }
      String card =
        '<div class=\'offerCarousel\'>' +
        '<div class=\'Rectangle\' style=\'height: 250px !important;\'>' +
        '<h4 style=\'padding-top: 5px;  text-align: center; color : #AF5071\'>' +
        offerCodeName +
        '</h4>' +
        '<hr style=\'width: 86%; align-content: center; margin: 5% 0 5% 7%; padding: 0px; height: 0px; border-top: 2px solid black\'>' +
        gwpItemNumber + liveOpsInfo + productExcludedText + dates +
        '<div class=\'content\' style=\'height: 230px; overflow: auto; margin: 3px; height: 70%; text-align: left; zoom: 75%; \'>' +
        digitalDisclaimer +
        '</div></div></div>';
      String cardContent = JSON.serialize(card);

      return String.isNotEmpty(card) ? new List<String>{ card } : null;
    } catch(Exception e){
      Logger.error('Error displaying offer details in Grace')
        .setExceptionDetails(e)
        .addTag('GraceException');
      Logger.saveLog();
      return null;
    }
  }
}