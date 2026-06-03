/**
 * @File Name          : NF_DisplayRecentOrders.cls
 * @Description        : This class will display the recent orders for a customer(Used for Greeting Flow)
 * @Author             : Manishi Kalra
 * @Created By         : NeuraFlash, LLC
**/

public with sharing class NF_DisplayRecentOrders {

    /*
    * method: displayMenu
    * description: it will return order details to be passed to bot as a menu.
    * @Params: order number entered/selected by user.
    */
    @InvocableMethod(label='NeuraFlash - Display Recent Order Menu For Greeting Flow')
    public static List<List<String>> displayRecentOrderMenu(List<String> recentOrderJson) {
        List<List<String>> output = new List<List<String>>();
        List<String> menuItems = new List<String>();

        try {

            List<NF_OrderHistoryService.OrderHistoryResponse> recentOrders = (List<NF_OrderHistoryService.OrderHistoryResponse>)JSON.deserializeStrict(recentOrderJson[0], List<NF_OrderHistoryService.OrderHistoryResponse>.class );

            for(NF_OrderHistoryService.OrderHistoryResponse o : recentOrders){
                menuItems.add(NF_Util.getOrderMenuItem(o));
            }

            String lastMenuItem = 'Ask something else';
            menuItems.add(lastMenuItem);

            output.add(menuItems);
        }
        catch(Exception e){
            System.debug(LoggingLevel.DEBUG,'Exception occured>>>'+ e.getStackTraceString());
        }
        return output;
    }

}