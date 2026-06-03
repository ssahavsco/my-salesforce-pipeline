public with sharing class NF_UtilCustomPicklist {
    // local class 
    public class CustomPicklistValue {
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public string value {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
    }

    @AuraEnabled
    public static List<CustomPicklistValue> getAvailableRecordTypes(string sObjectType) {
        try {
            List<CustomPicklistValue> returnVals = new List<CustomPicklistValue>();

            // get all the available record types for an object for the current user
            for(RecordTypeInfo info:NF_Util.getAvailableRecordTypes(sObjectType)) {
                CustomPicklistValue plv = new CustomPicklistValue();
                plv.label = info.getName();
                plv.value = info.getRecordTypeId();
                plv.selected = info.isDefaultRecordTypeMapping();
                returnVals.add(plv);
            }
            return returnVals;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CustomPicklistValue> getAvailablePicklistValues(string sObjectType, string fieldName) {
        try {
            List<CustomPicklistValue> returnVals = new List<CustomPicklistValue>();
            
            List<Schema.PicklistEntry> ple = NF_Util.getAvailableFieldResults(sObjectType, fieldName);
            for( Schema.PicklistEntry pickListVal : ple){
                if (pickListVal.isActive()) {
                    CustomPicklistValue plv = new CustomPicklistValue();
                    plv.label = pickListVal.getLabel();
                    plv.value = pickListVal.getValue();
                    plv.selected = pickListVal.isDefaultValue();
                    returnVals.add(plv);
                }
            }
            return returnVals;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}