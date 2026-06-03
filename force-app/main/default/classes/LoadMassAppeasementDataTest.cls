@isTest
public with sharing class LoadMassAppeasementDataTest {
    @isTest
    public static void loadRecordsTest(){
         String jsonData = '[{"Email":"test@example.com","FirstName":"John","LastName":"Doe","Batch":123,"PhoneNumber":"555-1234","Amount":50},' +
         '{"Email":"another@example.com","FirstName":"Jane","LastName":"Smith","Batch":456,"PhoneNumber":"555-5678","Amount":75}]';
         String result = LoadMassAppeasementData.loadRecords(jsonData);
    }

   @isTest
   public static void displayRecordsTest(){
            Mass_Appeasement__c ma = new Mass_Appeasement__c();
            ma.BatchID__c = 'TestBatch';
            ma.Message_Id__c = '65465465465465';
            ma.Recipient_First_Name__c = 'SUMIT';
            ma.Recipient_Last_Name__c = 'SAHA';
            ma.Gift_Card_Amount__c = 100.00;
            ma.Recipient_Email__c = 'ssaha@lb.com';
            insert ma;
    
            String result = LoadMassAppeasementData.displayRecords('TestBatch');
            delete ma;
   }
}