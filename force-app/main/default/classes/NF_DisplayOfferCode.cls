/**
 * Created by apoorvrajput on 8/31/20.
 * Modified by Sumit Saha on 5th Aug 25
 */

public with sharing class NF_DisplayOfferCode {
  public class Input {
    @InvocableVariable(required=false)
    public String chatKey;

    @InvocableVariable(required=false)
    public String offerCode;

    @InvocableVariable(required=false)
    public String digitalDisclaimer;
  }

  public class Output {
    public Boolean success = false;
  }

  @InvocableMethod(label='VSCO - Display Offer Code')
  public static List<String> display(List<Input> input) {
    System.debug(
      LoggingLevel.DEBUG,
      'NF_DisplayOfferCode: chatKey=' + input[0].chatKey
    );
    List<Output> outputs = new List<Output>();
    Output out = new Output();

    String chatKey = input[0].chatKey;
    String digitalDisclaimer = input[0].digitalDisclaimer;
    String offerCodeName = input[0].offerCode;

    String card =
      '<div class=\'offerCarousel\'>' +
      '<div class=\'Rectangle\' style=\'height: 250px !important;\'>' +
      //header
      '<h2 style=\'padding-top: 5px;  text-align: center; color : #AF5071\'>' +
      offerCodeName +
      '</h2>' +
      '<hr style=\'width: 86%; align-content: center; margin: 5% 0 5% 7%; padding: 0px; height: 0px; border-top: 2px solid black\'>' +
      //content
      '<div class=\'content\' style=\'height: 230px; overflow: auto; margin: 3px; height: 70%; text-align: left; zoom: 75%; \'>' +
      digitalDisclaimer +
      '</div></div></div>';
    String cardContent = JSON.serialize(card);

    return String.isNotEmpty(card) ? new List<String>{ card } : null;
  }
}