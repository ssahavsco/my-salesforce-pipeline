/** Created by SUMIT SAHA | ssaha@victoria.com
 *  on 7th Dec 2023
 */

public with sharing class VS_MostRecentCustomerOrder {

    public static Map<String, LBrands_API_Integration_Setting__mdt> lbAPIIntegSettingsMap = LBrands_API_Integration_Setting__mdt.getAll();

    public void authenticate() {}

    @AuraEnabled
    public static string getOrderNumber(String query){
        String inputString = query.replace('Sort','SortField');
        Input input = (Input)JSON.deserialize(inputString,Input.class );
        User usr = [Select FederationIdentifier from user where id =: UserInfo.getUserId()];
        input.Query = input.Query + ' AND CreatedBy = \'' +usr.FederationIdentifier + '\' AND CreatedTimestamp > CURRENTTIME(-1H) ' ;
        inputString = JSON.serialize(input).replace('sortField', 'Sort');
        VS_MostRecentCustomerOrder vs = new VS_MostRecentCustomerOrder();
        String ordNbr = vs.recentOrder(inputString)  ;
        return ordNbr;
    }


    public string recentOrder(String query){
        String orderNumber;
        try {
            HttpRequest calloutRequest = new HttpRequest();
            calloutRequest.setMethod( 'POST' );
            calloutRequest.setEndpoint( lbAPIIntegSettingsMap.get('AOOrderMaxFulfillmentStatusId').Endpoint__c  );
            calloutRequest.setBody( query );
    
            HTTPResponse resp = new Http().send( calloutRequest );
            Integer statusCode = resp.getStatusCode();

            if( statusCode == 200 ) {
                if( resp.getBody() != null ) {
                    Map<String, Object> r = ( Map<String, Object> ) JSON.deserializeUntyped( resp.getBody() );
                    List<Object> dataList = (List<Object>) r.get('data');
                    if( dataList[0] != null ) {
                        Map<String, Object> r1 = (Map<String, Object>) dataList[0];
                        orderNumber = r1.get('OrderId').toString() ;
                    }
                }
            }         
            return orderNumber;
        } catch (Exception e) {
            return orderNumber;
        }
    }

    public class Input{
        public String Query;
        public String Size;
        public SortField sortField;
        public Template Template;

        public Input (){
            this.sortField = new SortField();
            this.template = new Template();
        }
    }

    public class SortField{
        public String attribute;
        public String direction;
    }

    public class Template{
        public String OrderId;
        public String CreatedTimestamp;
        public String CustomerEmail;
        public String CreatedBy;
    }

}