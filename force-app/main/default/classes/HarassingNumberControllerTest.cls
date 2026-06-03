@isTest
public class HarassingNumberControllerTest {
    @istest
    public static void creaateOrUpdateRecordsTest() {

        HarassingNumberController.WrapperCaller obj = new HarassingNumberController.WrapperCaller();
        obj.caseNumber = '012365';
        obj.phoneNumber = '+123654789';
        obj.reason = 'Heavy Breathing';
        obj.userComments = 'Test comments';

        List<HarassingNumberController.WrapperCaller> listWrapper = new List<HarassingNumberController.WrapperCaller>();
        listWrapper.add(obj);
        HarassingNumberController.creaateOrUpdateRecords(listWrapper);

        Harassing_Number__c outPhoneNumber = [SELECT Id, Phone__c from Harassing_Number__c where Phone__c  =: obj.phoneNumber  ];
        System.assertEquals(obj.phoneNumber, outPhoneNumber.get('Phone__c'), 'Passed');

    }
}