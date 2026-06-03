public with sharing class VS_HomeTryOnBotServiceCalls {
  @InvocableMethod(label='Get HTO Dashboard Details')
  public static List<Output> invokeDashboardService(List<Input> inputs) {
    try {
      List<Output> outputResponse = new List<Output>();
      Output outputInstance = new Output();
      ebotdata__Bot_Session__c[] ebotSession = [
        SELECT
          Id,
          Is_User_HTO_Subscribed__c,
          HTO_Box_Stance__c,
          HTO_Status_Code__c,
          Customer_Full_Name__c
        FROM ebotdata__Bot_Session__c
        WHERE ebotdata__Live_Agent_Session_Id__c = :inputs[0].chatkey
        LIMIT 1
      ];
      if (
        ebotSession.size() > 0 &&
        String.isEmpty(ebotSession[0].HTO_Box_Stance__c)
      ) {
        VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper dashboardResponseWrapper = new VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper();
        dashboardResponseWrapper = VS_HomeTryOnServicesCallout.getHTODashBoardDetails(
          inputs[0].email
        );
        system.debug('Status Code' + dashboardResponseWrapper.statusCode);
        outputInstance.htoStatusCode = dashboardResponseWrapper.statusCode;
        if (
          dashboardResponseWrapper.statusCode == 200 ||
          dashboardResponseWrapper.statusCode == 201
        ) {
          if (
            dashboardResponseWrapper.response.containsKey('stance') &&
            dashboardResponseWrapper.response.containsKey('membership') &&
            dashboardResponseWrapper.response.containsKey('memberDetails')
          ) {
            Map<String, Object> dashboardMemberDetails = (Map<String, Object>) dashboardResponseWrapper.response.get(
              'memberDetails'
            );
            Map<String, Object> dashboardMembership = (Map<String, Object>) dashboardResponseWrapper.response.get(
              'membership'
            );
            String currentHTOBoxFrequency;
            outputInstance.homeTryOnStance = (String) dashboardResponseWrapper.response.get(
              'stance'
            );
            if (dashboardMembership.containsKey('isHtoSubscribed')) {
              outputInstance.isHomeTryOnSubscribed = (Boolean) dashboardMembership.get(
                'isHtoSubscribed'
              );
            }
            if (dashboardMembership.containsKey('boxFrequency')) {
              currentHTOBoxFrequency = (String) dashboardMembership.get(
                'boxFrequency'
              );
            }
            //start of Parsing Pause information from API
            if (dashboardMembership.containsKey('canPauseLimited')) {
              outputInstance.isHTOCanPauseSubscription = (Boolean) dashboardMembership.get(
                'canPauseLimited'
              );
              if ((Boolean) dashboardMembership.get('canPauseLimited')) {
                Map<String, Object> dashboardPauseDetails = (Map<String, Object>) dashboardMembership.get(
                  'placementAfterPause'
                );
                if (dashboardPauseDetails.containsKey('option2months')) {
                  Map<String, Object> twoMonthOptions = (Map<String, Object>) dashboardPauseDetails.get(
                    'option2months'
                  );
                  if (twoMonthOptions.containsKey('month')) {
                    outputInstance.twoMonthPausedBoxScheduled = Datetime.newInstanceGmt(
                        2000,
                        (Integer) twoMonthOptions.get('month') + 1,
                        1
                      )
                      .format('MMMM');
                  }
                }
                if (dashboardPauseDetails.containsKey('option3months')) {
                  Map<String, Object> threeMonthOptions = (Map<String, Object>) dashboardPauseDetails.get(
                    'option3months'
                  );
                  if (threeMonthOptions.containsKey('month')) {
                    outputInstance.threeMonthPausedBoxScheduled = Datetime.newInstanceGmt(
                        2000,
                        (Integer) threeMonthOptions.get('month') + 1,
                        1
                      )
                      .format('MMMM');
                  }
                }
              }
            }
            //End of Parsing Pause information from API
            if (
              dashboardMemberDetails.containsKey('firstName') &&
              dashboardMemberDetails.containsKey('lastName')
            ) {
              outputInstance.customerName =
                dashboardMemberDetails.get('firstName') +
                ' ' +
                dashboardMemberDetails.get('lastName');
            }

            //start of Parsing Skip information from API
            if (dashboardResponseWrapper.response.containsKey('skipDetails')) {
              Map<String, Object> dashboardSkipDetails = (Map<String, Object>) dashboardResponseWrapper.response.get(
                'skipDetails'
              );
              if (dashboardSkipDetails.containsKey('canSkip')) {
                Map<String, Object> canSkipDetails = (Map<String, Object>) dashboardSkipDetails.get(
                  'canSkip'
                );
                if (canSkipDetails.containsKey('fromBoxManagement')) {
                  outputInstance.isHTOCanSkipBox = (Boolean) canSkipDetails.get(
                    'fromBoxManagement'
                  );
                }
                if (canSkipDetails.containsKey('skipMonth')) {
                  outputInstance.htoSkipMonth = (Integer) canSkipDetails.get(
                    'skipMonth'
                  );
                  outputInstance.nextBoxScheduledMonth = Datetime.newInstanceGmt(
                      2000,
                      outputInstance.htoSkipMonth + 2,
                      1
                    )
                    .format('MMMM');
                }
                if (canSkipDetails.containsKey('skipYear')) {
                  outputInstance.htoSkipYear = (Integer) canSkipDetails.get(
                    'skipYear'
                  );
                }
                outputInstance.htoSkipSource = 'box_management';
              }
            }
            //End of Parsing Skip information
            VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper htoHistoryResponseWrapper = new VS_HomeTryOnServicesCallout.HomeTryOnServiceResponseWrapper();
            htoHistoryResponseWrapper = VS_HomeTryOnServicesCallout.getOrderhistoryByCustomerId(
              inputs[0].email
            );
            //sending dynamic recenty 3 hto orders
            if (
              htoHistoryResponseWrapper.statusCode == 200 ||
              htoHistoryResponseWrapper.statusCode == 201
            ) {
              if (
                htoHistoryResponseWrapper.successData != null &&
                htoHistoryResponseWrapper.successData.transactions.size() > 0
              ) {
                Integer index = 0;
                for (
                  PHISTorderTransactionWrapper.ResponseOrder resp : htoHistoryResponseWrapper.successData.transactions
                ) {
                  if (index < 3) {
                    HtoOrderResponse orderHistory1 = new HtoOrderResponse();
                    orderHistory1.htoOrderPlaceHolder = resp.OrderId;
                    outputInstance.htoPreviousOrders.add(orderHistory1);
                    index++;
                  } else {
                    break;
                  }
                }
              }
            }
            if (outputInstance.isHomeTryOnSubscribed) {
              HtoOrderResponse orderHistory4 = new HtoOrderResponse();
              orderHistory4.htoOrderPlaceHolder = 'Manage Subscription';
              outputInstance.htoPreviousOrders.add(orderHistory4);
            }
            HtoOrderResponse orderHistory5 = new HtoOrderResponse();
            orderHistory5.htoOrderPlaceHolder = 'Make a return';
            outputInstance.htoPreviousOrders.add(orderHistory5);
            if (outputInstance.isHomeTryOnSubscribed) {
              //adding Update Frequency Option
              HtoSubscriptionMenu menuOption1 = new HtoSubscriptionMenu();
              menuOption1.htoSubcriptionMenuPlaceHolder = 'Update Frequency';
              outputInstance.htoSubcriptionMenuOptions.add(menuOption1);
              //adding Skip Next Box Option
              if (currentHTOBoxFrequency == 'monthly') {
                HtoSubscriptionMenu menuOption2 = new HtoSubscriptionMenu();
                menuOption2.htoSubcriptionMenuPlaceHolder = 'Skip Next Box';
                outputInstance.htoSubcriptionMenuOptions.add(menuOption2);
                //adding Pause 2 Months Option
                HtoSubscriptionMenu menuOption3 = new HtoSubscriptionMenu();
                menuOption3.htoSubcriptionMenuPlaceHolder = 'Pause 2 Months';
                outputInstance.htoSubcriptionMenuOptions.add(menuOption3);
                //adding Pause 3 Months Option
                HtoSubscriptionMenu menuOption4 = new HtoSubscriptionMenu();
                menuOption4.htoSubcriptionMenuPlaceHolder = 'Pause 3 Months';
                outputInstance.htoSubcriptionMenuOptions.add(menuOption4);
              }
              //adding Cancel Subscription Option
              HtoSubscriptionMenu menuOption5 = new HtoSubscriptionMenu();
              menuOption5.htoSubcriptionMenuPlaceHolder = 'Cancel Subscription';
              outputInstance.htoSubcriptionMenuOptions.add(menuOption5);
              //adding More Option
              HtoSubscriptionMenu menuOption6 = new HtoSubscriptionMenu();
              menuOption6.htoSubcriptionMenuPlaceHolder = 'More';
              outputInstance.htoSubcriptionMenuOptions.add(menuOption6);
            }
            outputResponse.add(outputInstance);
            try {
              ebotdata__Bot_Session__c eb = new ebotdata__Bot_Session__c();
              eb.Id = ebotSession[0].Id;
              eb.HTO_Status_Code__c = outputInstance.htoStatusCode;
              eb.Customer_Full_Name__c = outputInstance.customerName;
              eb.HTO_Box_Stance__c = outputInstance.homeTryOnStance;
              eb.Is_User_HTO_Subscribed__c = outputInstance.isHomeTryOnSubscribed;
              update eb;
            } catch (Exception e) {
              System.debug(
                'Line ==> ' +
                  e.getLineNumber() +
                  'BotLoyaltyService:: Unable to update : ' +
                  e.getMessage()
              );
            }
          }
        } else if (dashboardResponseWrapper.statusCode == 404) {
          Logger.error(
            'Simone-Error while processing dashboard api' +
            JSON.serialize(dashboardResponseWrapper.response)
          );
          Logger.saveLog();
          outputInstance.htoStatusCode = dashboardResponseWrapper.statusCode;
          outputResponse.add(outputInstance);
        } else {
          Logger.error(
            'Simone-Error while processing dashboard api' +
            JSON.serialize(dashboardResponseWrapper.response)
          );
          Logger.saveLog();
          outputInstance.htoStatusCode = dashboardResponseWrapper.statusCode;
          outputResponse.add(outputInstance);
        }
      } else if (ebotSession.size() > 0) {
        outputInstance.htoStatusCode = ebotSession[0].HTO_Status_Code__c;
        outputInstance.customerName = ebotSession[0].Customer_Full_Name__c;
        outputInstance.homeTryOnStance = ebotSession[0].HTO_Box_Stance__c;
        outputInstance.isHomeTryOnSubscribed = ebotSession[0]
          .Is_User_HTO_Subscribed__c;
        outputResponse.add(outputInstance);
      }
      return outputResponse;
    } catch (Exception ex) {
      Logger.error(
        'Simone-Exception while processing HTO Dashboard API at line number ' +
          ex.getStackTraceString() +
          'and the exception is : ' +
          ex.getMessage()
      );
      Logger.saveLog();
      return null;
    }
  }
  public class Input {
    @InvocableVariable(required=true)
    public String chatkey;

    @InvocableVariable(required=true)
    public String email;
  }
  public class Output {
    @InvocableVariable
    public Boolean isHomeTryOnSubscribed = false;
    @InvocableVariable
    public String homeTryOnStance;
    @InvocableVariable
    public String customerName;
    @InvocableVariable
    public Decimal htoStatusCode;
    @InvocableVariable
    public Boolean isHTOCanSkipBox = false;
    @InvocableVariable
    public Integer htoSkipMonth;
    @InvocableVariable
    public String nextBoxScheduledMonth;
    @InvocableVariable
    public Integer htoSkipYear;
    @InvocableVariable
    public String htoSkipSource;
    @InvocableVariable
    public Boolean isHTOCanPauseSubscription = false;
    @InvocableVariable
    public String twoMonthPausedBoxScheduled;
    @InvocableVariable
    public String threeMonthPausedBoxScheduled;
    @InvocableVariable
    public List<HtoOrderResponse> htoPreviousOrders = new List<HtoOrderResponse>();
    @InvocableVariable
    public List<HtoSubscriptionMenu> htoSubcriptionMenuOptions = new List<HtoSubscriptionMenu>();
  }
  public class HtoOrderResponse {
    public String htoOrderPlaceHolder;
  }
  public class HtoSubscriptionMenu {
    public String htoSubcriptionMenuPlaceHolder;
  }
}