@isTest
public class OrderTransactionDetails_Test {
	
    @isTest(SeeAllData=true)
    static void getPhistOrderDetailsTest1(){
        List<OrderTransactionDetails.Input> inputDataList = new List<OrderTransactionDetails.Input>();
        OrderTransactionDetails.Input inputData = new OrderTransactionDetails.Input();
        inputData.orderNumber = 'orderNumber1';
        
        inputDataList.add(inputData);
        system.debug('Input '+inputDataList);
        
        Test.setMock(  HttpCalloutMock.class, new PhistDigitalOrderTransactionService_Mock() );
        Test.startTest();
            //OrderTransactionDetails.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            List<OrderTransactionDetails.Output> output = OrderTransactionDetails.getOrderDetails(inputDataList);
            system.debug(output);
        
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void getPhistOrderDetailsTest2(){
        List<OrderTransactionDetails.Input> inputDataList = new List<OrderTransactionDetails.Input>();
        OrderTransactionDetails.Input inputData = new OrderTransactionDetails.Input();
        inputData.orderNumber = 'orderNumber2';
        
        inputDataList.add(inputData);
        system.debug('Input '+inputDataList);
        
        Test.setMock(  HttpCalloutMock.class, new PhistDigitalOrderTransactionService_Mock() );
        Test.startTest();
            //OrderTransactionDetails.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            List<OrderTransactionDetails.Output> output = OrderTransactionDetails.getOrderDetails(inputDataList);
            system.debug(output);
        
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void getPhistOrderDetailsTest3(){
        List<OrderTransactionDetails.Input> inputDataList = new List<OrderTransactionDetails.Input>();
        OrderTransactionDetails.Input inputData = new OrderTransactionDetails.Input();
        inputData.orderNumber = 'orderNumber3';
        
        inputDataList.add(inputData);
        system.debug('Input '+inputDataList);
        
        Test.setMock(  HttpCalloutMock.class, new PhistDigitalOrderTransactionService_Mock() );
        Test.startTest();
            //OrderTransactionDetails.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            List<OrderTransactionDetails.Output> output = OrderTransactionDetails.getOrderDetails(inputDataList);
            system.debug(output);
        
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void getPhistOrderDetailsTest4(){
        List<OrderTransactionDetails.Input> inputDataList = new List<OrderTransactionDetails.Input>();
        OrderTransactionDetails.Input inputData = new OrderTransactionDetails.Input();
        inputData.orderNumber = 'orderNumber4';
        
        inputDataList.add(inputData);
        system.debug('Input '+inputDataList);
        
        Test.setMock(  HttpCalloutMock.class, new PhistDigitalOrderTransactionService_Mock() );
        Test.startTest();
            //OrderTransactionDetails.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            List<OrderTransactionDetails.Output> output = OrderTransactionDetails.getOrderDetails(inputDataList);
            system.debug(output);
        
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void getPhistOrderDetailsTest5(){
        List<OrderTransactionDetails.Input> inputDataList = new List<OrderTransactionDetails.Input>();
        OrderTransactionDetails.Input inputData = new OrderTransactionDetails.Input();
        inputData.orderNumber = 'orderNumber5';
        
        inputDataList.add(inputData);
        system.debug('Input '+inputDataList);
        
        Test.setMock(  HttpCalloutMock.class, new PhistDigitalOrderTransactionService_Mock() );
        Test.startTest();
            //OrderTransactionDetails.lbAPIIntegSettingsMap = lbAPIIntegSettingsMapActiveTest;
            List<OrderTransactionDetails.Output> output = OrderTransactionDetails.getOrderDetails(inputDataList);
            system.debug(output);
        
        Test.stopTest();
    }
}