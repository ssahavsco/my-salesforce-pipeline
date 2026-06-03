@isTest
public class TrainingConfigurationControllerTest {
	@TestSetup
    static void createTestData(){
        Training_Configuration__c train = new Training_Configuration__c();
		train.RecordTypeId = Schema.SObjectType.Training_Configuration__c.getRecordTypeInfosByName().get('Tip of the Day').getRecordTypeId();
		train.IsActive__c = true;
        train.Selected_Profiles__c ='System Administrator;';
		insert train;                
        Training_Configuration__c train2 = new Training_Configuration__c();
		train2.RecordTypeId = Schema.SObjectType.Training_Configuration__c.getRecordTypeInfosByName().get('Breaking News').getRecordTypeId();
		train2.IsActive__c = true;
        train2.Selected_Profiles__c ='System Administrator;';
		insert train2; 
        Training_Configuration__c train3 = new Training_Configuration__c();
		train3.RecordTypeId = Schema.SObjectType.Training_Configuration__c.getRecordTypeInfosByName().get('Test Your Knowledge').getRecordTypeId();
		train3.IsActive__c = true;
        train3.Selected_Profiles__c ='System Administrator;';
		insert train3; 
        
    }
    @isTest
    static void getTrainingConfigurationRecordsTest(){
        TrainingConfigurationController.getTrainingConfigurationRecords();
	}
}