/*****************************************************************************************************@@
Class Name     :  NF_GetMenuOptions
Purpose        :  This class is use to display menu options after order carousel in einstein bot.
History:
-------
VERSION  AUTHOR                 DATE                DETAIL                      TICKET REFERENCE/ NO.
1.       apoorv                09/22/2020            Original Version             
2.       manishi               08/11/2021            Phase 3 modifications 		DP-39264, DP-39922, DP-39924, DP-39925
													 in menu options for 
													 authenticated user  
3.		manishi					09/17/2021			 missing menu option		DP-48181
4.      Himanshu                09/02/2024           Added custom labels        CCS-619
                                                     for hard-coded menu options
                                                     to support translation

@Testsuite:  {NF_GetMenuOptionsTest}        
*********************************************************************************************************/
public with sharing class NF_GetMenuOptions {
    public class Input{
        @InvocableVariable(required=false)
        public String chatKey;

        @InvocableVariable(required=false)
        public Boolean isUserAuthenticated;

        @InvocableVariable(required=false)
        public String dialogName;

        @InvocableVariable(required=false)
        public String originFlow;

        @InvocableVariable(Required=false)
        public String languageCode = 'en_US';
    }
    public class Output{
        @InvocableVariable
        public List<String> menuOptions = new List<String>();
    }

    public static String moreOrderInformation = 'View more order information';
    public static String checkAnotherItem = 'Check another order';
    public static String speakToAssociate = 'Speak to an associate';
    public static String askSomethingElse = 'Ask something else';
    public static String cancelBackorderItems = 'Cancel backordered items';
    public static String modifyOrder = 'Modify this order';
    public static String iAmDone = 'I\'m done';

    @InvocableMethod(label='Neuraflash - Get Menu Options')
    public static List<Output> getMenuOptions(List<Input> input) {

        moreOrderInformation    = Label.get('', 'VS_More_Order_Information', input[0].languageCode);
        checkAnotherItem        = Label.get('', 'VS_Check_Another_Item', input[0].languageCode);
        speakToAssociate        = Label.get('', 'VS_Speak_To_Associate', input[0].languageCode);
        askSomethingElse        = Label.get('', 'VS_Ask_Something_Else', input[0].languageCode);
        cancelBackorderItems    = Label.get('', 'VS_Cancel_Backorder_Items', input[0].languageCode);
        modifyOrder             = Label.get('', 'VS_Modify_Order', input[0].languageCode);
        iAmDone                 = Label.get('', 'VS_I_Am_Done_Menu', input[0].languageCode);

        String dialogName = input[0].dialogName;
        System.debug(LoggingLevel.DEBUG,'>>NF_GetMenuOptions: dialogName='+dialogName);

        Boolean isUserAuthenticated = input[0].isUserAuthenticated != null && input[0].isUserAuthenticated;
        System.debug(LoggingLevel.DEBUG,'>>NF_GetMenuOptions: isUserAuthenticated='+isUserAuthenticated);

        String originFlow = input[0].originFlow;
        System.debug(LoggingLevel.DEBUG,'>>NF_GetMenuOptions: originFlow='+originFlow);

        List<Output> outputs = new List<Output>();
        Output output = new Output();
        List<String> menuOptions = new List<String>();
        
        if(dialogName == 'bus_order_claim_end') {
            if (!isUserAuthenticated){
                menuOptions.add(moreOrderInformation);
            }
            menuOptions.add(checkAnotherItem);
        }

        else if (dialogName == 'bus_order_parent_partiallyReturned_end') {
            if (!isUserAuthenticated){
                menuOptions.add(moreOrderInformation);
            }
            menuOptions.add(checkAnotherItem);
        }

        else if (dialogName == 'bus_order_parent_returned_end') {
            if (!isUserAuthenticated){
                menuOptions.add(moreOrderInformation);
            }
            menuOptions.add(checkAnotherItem);
            menuOptions.add(askSomethingElse);
        }

        else if (dialogName == 'bus_order_oneShipment') {
            if (!isUserAuthenticated) {
                menuOptions.add(moreOrderInformation);
            }

            //LBRAN-317,  if she went down order mod (returned) flow, don't let Her modify her order
            //otherwise, add the modify order menu option
            if('orderMod'.equalsIgnoreCase(originFlow) == false && !isUserAuthenticated){
                menuOptions.add(modifyOrder);
            }
            
            /* DP-48181 */
            if (!isUserAuthenticated) {
                menuOptions.add(checkAnotherItem);
            }
        }

        else if(dialogName == 'bus_order_returned') {
            if (!isUserAuthenticated)
            {
                menuOptions.add(moreOrderInformation);
            	menuOptions.add(checkAnotherItem);
             	menuOptions.add(speakToAssociate);
            }
        }

        else if(dialogName == 'bus_order_cancelled') {
            if (!isUserAuthenticated)
            {
                menuOptions.add(moreOrderInformation);
             	menuOptions.add(checkAnotherItem);
            }
            menuOptions.add(speakToAssociate);
            if(isUserAuthenticated) {
                menuOptions.add(askSomethingElse);
                menuOptions.add(iAmDone);
            }
            
        }
        //bus_order_backorder
        else if(dialogName == 'bus_order_backorder') {
            if (!isUserAuthenticated)
            {
                menuOptions.add(moreOrderInformation);
             	menuOptions.add(checkAnotherItem);
            }
            menuOptions.add(modifyOrder);
            menuOptions.add(cancelBackorderItems);
            if(isUserAuthenticated) {
                menuOptions.add(iAmDone);
            }
        }
        //bus_order_multShipment
        else if(dialogName == 'bus_order_multShipment') {
            if (!isUserAuthenticated)
            {	
                menuOptions.add(moreOrderInformation);
                menuOptions.add(checkAnotherItem);
            	menuOptions.add(modifyOrder);
            }
            
        }

        else if (dialogName == 'bus_greeting_partiallyReturned' || dialogName == 'bus_greeting_returned' || dialogName == 'bus_greeting_payment') {
            menuOptions.add(checkAnotherItem);
            menuOptions.add(askSomethingElse);
        }

        else if (input[0].dialogName == 'bus_greeting_backorder') {
            menuOptions.add(cancelBackorderItems);
            menuOptions.add(modifyOrder);
            menuOptions.add(askSomethingElse);
        }

        else if(dialogName == 'bus_greeting_multShipment' || dialogName == 'bus_greeting_oneShipment') {
            menuOptions.add(modifyOrder);
            menuOptions.add(askSomethingElse);
            menuOptions.add(iAmDone);
        }

        output.menuOptions = menuOptions;
        System.debug(LoggingLevel.DEBUG,'>>NF_GetMenuOptions: output='+output);

        outputs.add(output);
        return outputs;
    }
}