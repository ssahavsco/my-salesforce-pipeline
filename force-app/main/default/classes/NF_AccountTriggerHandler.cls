public with sharing class NF_AccountTriggerHandler implements NF_ITrigger {

    /***************** BEFORE EVETNTS *********************/
    public void bulkBefore(){}
    
    public void beforeInsert(List<SObject> newMapAccount){
        for (SObject newSObjectInstance : newMapAccount){
            Account newAccountInstance = (Account)newSObjectInstance;
            String oldPhone = newAccountInstance.Phone;
            String otherPhone = newAccountInstance.PersonMobilePhone;
            String phoneSearchField = '';

            phoneSearchField += NF_Util_SCV.fixPhoneFormat(oldPhone);
            //phoneSearchField += NF_Util_SCV.fixPhoneFormat(otherPhone);
            System.debug('Final Search String: ' + phoneSearchField);

            newAccountInstance.Phone_Search__c = phoneSearchField;
            newAccountInstance.Phone_Search__pc = phoneSearchField;
            newAccountInstance.PersonMobilePhone = oldPhone;
        }

    }

    public void beforeUpdate(List<SObject> newAccounts, List<SObject> oldAccounts,
                                Map<Id, SObject> newMapAccount, Map<Id, SObject> oldMapAccount){

        List<Account> fetchAccountListUpdate = new List<Account>();
        Integer index = 0;

        for(SObject newSobjectInstance : newAccounts){
            SObject oldSobjectInstance = oldAccounts.get(index++);
            Account newAccountInstance = (Account)newSobjectInstance;
            Account oldAccountInstance = (Account)oldSobjectInstance;
            System.debug('New Account: ' + newAccountInstance);
            System.debug('Old Account: ' + oldAccountInstance);
            if (newAccountInstance.Phone <> oldAccountInstance.Phone ||
                    newAccountInstance.PersonMobilePhone <> oldAccountInstance.PersonMobilePhone ||
                    newAccountInstance.Phone_Search_Reset__c  <> oldAccountInstance.Phone_Search_Reset__c) {

                String oldPhone = newAccountInstance.Phone;
                String otherPhone = newAccountInstance.PersonMobilePhone;
                String phoneSearchField = '';

                phoneSearchField += NF_Util_SCV.fixPhoneFormat(oldPhone);
                // phoneSearchField += NF_Util_SCV.fixPhoneFormat(otherPhone);
                System.debug('Final Search String: ' + phoneSearchField);

                newAccountInstance.Phone_Search__c = phoneSearchField;
                newAccountInstance.Phone_Search__pc = phoneSearchField;
                newAccountInstance.PersonMobilePhone = oldPhone;
                fetchAccountListUpdate.add(newAccountInstance);

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