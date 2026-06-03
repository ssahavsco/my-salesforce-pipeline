/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Schedulable class for the AVP Check Refund Request process, flags Case Resolutions as being sent.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Tara Chand  <tara.chand@neuraflash.com>
* @modifiedBy     Tara Chand  <tara.chand@neuraflash.com>
* @maintainedBy   Tara Chand  <tara.chand@neuraflash.com>
* @version        1.0
* @created        2021-05-07
* @modified       2021-05-07
* @systemLayer    Schedulable
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Tara Chand <tara.chand@neuraflash.com>
*               DP-37415: Initial implementation of AVP Check Refund batch job
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

// This class follows the SFDC structure for Schedulable classes
global with sharing class AvpCustomerCareBatchSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        AvpCustomerCareBatch batch = new AvpCustomerCareBatch(); 
        // DP-37415 Start the AVP Customer Care Batch job, with a batch size of 2000
        Database.executeBatch(batch, 2000);
    }
}