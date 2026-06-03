/**
 * Class NF_TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public with sharing class NF_TriggerFactory {

    /**
    * private static method to get the appropriate handler for the object type.
    * Modify this method to add any additional handlers.
    *
    * Arguments: Type classType - apex class type
    *
    * @return: NF_ITrigger - A Trigger handler if one exists or null.
    */
    @testVisible
    private static NF_ITrigger getHandler(Type classType){
        // Instantiate the type
        Object o = classType.newInstance();
        // if its not an instance of NF_ITrigger return null
        if (!(o instanceOf NF_ITrigger)) {
            return null;
        }
        return (NF_ITrigger)o;
    }

    /**
     * public static method to create and execute a Trigger handler
     *
     * Arguments:Type classType - The apex class to instantiate and execute
     *
     * Throws a NF_TriggerException if no handler is found.
     */
    public static void createAndExecuteHandler(Type classType){
        // Get a handler appropriate to the class being processed
        NF_ITrigger handler = getHandler(classType);
        // Make sure we have a handler implements NF_ITrigger
        if (handler == null){
            throw new NF_TriggerException('No Trigger Handler registered for Class Type: ' + classType.getName());
        }
        
        // Execute the handler to fulfil the Trigger        
        if (TriggerEnabled(classType)) {
            execute(handler); 
        } else {
             System.debug('Skip Trigger execution because override found in TriggerFactoryOverride__mdt');
        }
    }

    /**
    * private static method to control the execution of the handler
    *
    * Arguments: NF_ITrigger handler - A Trigger Handler to execute
    */
    private static void execute(NF_ITrigger handler){

        // Before Trigger
        if (Trigger.isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();

            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.old,Trigger.oldMap);
            }

            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.new);
            }

            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
        }else {  
            
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();

            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete) {
                handler.afterDelete(Trigger.old,Trigger.oldMap);
            }

            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert) {
                handler.afterInsert(Trigger.new,Trigger.newMap);
            }

            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate) {
                handler.afterUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
        }

        // Perform any post processing
        handler.andFinally();
    }

    /**
    * private static method to check if Trigger should be run for the current context(user/profile)
    * Modify this method to add any additional checks/rules.
    *
    * Arguments: Type classType - the apex handler class
    *
    * @return: Boolean - flag - whether to run the Trigger or skip processing
    */
    private static Boolean TriggerEnabled(Type classType){
        String className = classType.getName();
        List<Profile> usersProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        
        if(usersProfile.size() == 0) {
            return true;
        }
        String myProfileName = usersProfile[0].Name;
        String myUserName = UserInfo.getUserName();
        List<String> metadataKeys = new List<String>();
        metadataKeys.add(myUserName + '|' + className); //UserName & Trigger combo override
        metadataKeys.add(myProfileName + '|' + className); //Profile & Trigger combo override
        metadataKeys.add('*|' + className); //Trigger level override
        metadataKeys.add(myProfileName + '|*'); //Profile level override
        metadataKeys.add(myUserName + '|*'); //UserName level override
        metadataKeys.add('*|*'); //Global override

        //We only need to find one match that has Disable checked to skip the Trigger
        List<NF_TriggerFactoryOverride__mdt>  tfo = [SELECT DisableTrigger__c
                                                    FROM NF_TriggerFactoryOverride__mdt
                                                        WHERE ProfileTrigger__c = :metadataKeys AND DisableTrigger__c = true
                                                            LIMIT 1];

        if (tfo.size() > 0) {
             System.debug('Skip Trigger execution because override found in TriggerFactoryOverride__mdt');
             return false;
        }
        return true;
    }
}