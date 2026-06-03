/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TriggerHandler on Order_Transaction__c object
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-05-05
* @modified       2021-05-05
* @systemLayer    Trigger
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class OrderTransactionTriggerHandler extends NF_TriggerHandler {

    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Checks to see if the trigger has been disabled either by custom setting or by running code
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @return Boolean
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override Boolean isDisabled() {
        TriggerSwitches__mdt  triggerSettings = TriggerSwitches__mdt.getInstance( 'OrderTransactionTriggerHandler' );
        TriggerDisabled = ( triggerSettings != null && triggerSettings.IsDisabled__c ) ? true : TriggerDisabled;
        return TriggerDisabled;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * * Add error to records for which status on Case is Closed
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param oldItems Map<Id, SObject> oldItems - map of deleted records
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void beforeDelete( Map<Id, SObject> oldItems ){
        for( Order_Transaction__c ot : [ SELECT Id, Case__r.Status FROM Order_Transaction__c WHERE Id IN :oldItems.keySet() ] ){
            if( ot.Case__r.Status == 'Closed' ){
                oldItems.get( ot.Id ).addError( 'Cannot delete Order Transactions on a Closed case. Reopen the case to make further changes to the Order Transactions.' );
            }
        }
    }
}