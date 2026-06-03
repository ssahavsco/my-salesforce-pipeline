public with sharing class NF_ContactTriggerHandler implements NF_ITrigger {

    /***************** BEFORE EVETNTS *********************/
    public void bulkBefore(){}
    
    public void beforeInsert(List<Sobject> newContacts){
        List<Contact> fetchContactListUpdate = new List<Contact>();
        Integer index = 0;

        for(SObject sobj : newContacts){
            Contact newContactInstance = (Contact)sobj;
            System.debug('New Contact: ' + newContactInstance);

            String oldPhone = newContactInstance.Phone;
            String otherPhone = newContactInstance.MobilePhone;
            String phoneSearchField = '';

            phoneSearchField += NF_Util_SCV.fixPhoneFormat(oldPhone);
            //phoneSearchField += NF_Util_SCV.fixPhoneFormat(otherPhone);
            System.debug('Final Search String: ' + phoneSearchField);

            newContactInstance.Phone_Search__c = phoneSearchField;
            fetchContactListUpdate.add(newContactInstance);

        }

    }

    public void beforeUpdate(List<Sobject> newContacts, List<Sobject> oldContacts, 
                                Map<Id, Sobject> newContactMap, Map<Id, Sobject> oldContactMap){
        List<Contact> fetchContactListUpdate = new List<Contact>();
        Integer index = 0;

        for(SObject newSobj : newContacts){
            Contact newContactInstance = (Contact)newSobj;
            Contact oldContactInstance = (Contact)oldContacts.get(index++);
            System.debug('New Contact: ' + newContactInstance);
            System.debug('Old Contact: ' + oldContactInstance);
            if (newContactInstance.Phone <> oldContactInstance.Phone ||
                    newContactInstance.MobilePhone  <> oldContactInstance.MobilePhone ||
                    newContactInstance.Phone_Search_Reset__c  <> oldContactInstance.Phone_Search_Reset__c) {

                String oldPhone = newContactInstance.Phone;
                String mobilePhone = newContactInstance.MobilePhone;
                String phoneSearchField = '';

                phoneSearchField += NF_Util_SCV.fixPhoneFormat(oldPhone);
               // phoneSearchField += NF_Util_SCV.fixPhoneFormat(mobilePhone);
                System.debug('Final Search String: ' + phoneSearchField);

                newContactInstance.Phone_Search__c = phoneSearchField;
                fetchContactListUpdate.add(newContactInstance);

            }
        }


    }

    public void beforeDelete(List<Sobject> oldContacts,Map<Id,Sobject> oldContactMap){}  
    

    /***************** AFTER EVENTS *********************/
    public void bulkAfter(){}

    public void afterInsert(List<Sobject> newContacts,Map<Id,Sobject> newContactMap){}

    public void afterUpdate(List<Sobject> newContacts,List<Sobject> oldContacts,
                                Map<Id,Sobject> newContactMap, Map<Id,Sobject> oldContactMap){}

    public void afterDelete(List<Sobject> oldContacts,Map<Id,Sobject> oldContactMap){}


    /**************** FINAL EXECUTION ******************/
    public void andFinally(){}
    
}