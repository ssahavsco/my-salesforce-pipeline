@isTest
public class VS_HomeTryOnOrderLookupTest {
	@isTest
    static void invokeGetHtoOrder(){
        ebotdata__Bot_Session__c ebotsession1 = new ebotdata__Bot_Session__c();
        ebotsession1.Is_User_HTO_Subscribed__c=true;
        ebotsession1.HTO_Box_Stance__c='';
        ebotsession1.HTO_Status_Code__c=200;
        ebotsession1.Customer_Full_Name__c='Test';
        ebotsession1.ebotdata__Live_Agent_Session_Id__c='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
    	insert ebotsession1;
        Test.setMock(HttpCalloutMock.class, new VS_HomeTryOnServiceCallout_Mock('invokeGetHtoOrderValid', 'valid'));
        Test.startTest();
        VS_HomeTryOnOrderLookup.Input input1 = new VS_HomeTryOnOrderLookup.Input();
        input1.chatkey='778315c3-b1bc-43bf-868e-e9b76a5a02e3';
        input1.email='test@salesforc.ecom';
        input1.orderId='T1099090';
        VS_HomeTryOnOrderLookup.invokeGetHtoOrder(new List<VS_HomeTryOnOrderLookup.Input>{input1});
        Test.stopTest();

    }
}