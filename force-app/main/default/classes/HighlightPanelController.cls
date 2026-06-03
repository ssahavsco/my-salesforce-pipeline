public with sharing class HighlightPanelController {

    @AuraEnabled
    public static ReturnWP fetchFields(String recordId, String objectName, String fieldSetName) {
        ReturnWP res = new ReturnWP();
        try {
            // Querying Name Field
            if(String.isBlank(recordId)) {
                res.message = 'Invalid Id';
                return res;
            }
            List<sObject> objectList;
            if(objectName == 'MessagingSession'){
                objectList = Database.query('SELECT id, Name,EndUserContactId FROM ' + objectName + ' WHERE Id =: recordId');
            } else {
            	objectList = Database.query('SELECT id, Name,ContactId FROM ' + objectName + ' WHERE Id =: recordId');
            }
            res.nameField = String.valueof(objectList[0].get('Name'));
                
            // Fetching Highlight Panel Field Set
            if(String.isBlank(fieldSetName)) {
                res.message = 'Please provide a Field Set Name';
                return res;
            }
            Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName);
            if(fieldSet == null) {
                res.message = 'Field Set provided is not Valid';
                return res;
            }
            res.fieldsAPI = new List<String>();
            for(Schema.FieldSetMember fieldSetMem:fieldSet.getFields()){
                res.fieldsAPI.add(fieldSetMem.getFieldPath());
            }
            return res;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ReturnWP {
        @AuraEnabled public String message;
        @AuraEnabled public String nameField;
        @AuraEnabled public List<String> fieldsAPI;
    }
}