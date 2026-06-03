/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Invokable class to get record types available to a profile for a given
* SObject, invocable from a flow
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Peter Waddington  <peter.waddington@neuraflash.com>
* @modifiedBy     Peter Waddington  <peter.waddington@neuraflash.com>
* @maintainedBy   Peter Waddington  <peter.waddington@neuraflash.com>
* @version        1.0
* @created        2021-05-11
* @modified       2021-05-11
* @systemLayer    InvocableMethod
* @jiraNumber     DP-41261
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0          Peter Waddington  <peter.waddington@neuraflash.com>
*
* First version of class
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class NF_UtilRecordTypeAvailableFlowInvokable {
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Input params for the Invocable method
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @property     sObjectName     String      Name of the sObject we wish to get RT permissions for
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RecordTypeQuery {
        @InvocableVariable(Required=true)
        public String sObjectName;
    }
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Output object from the Invocable
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @property RecordTypes List<RecordType>    List of RecordTypes to which user has access
    * @property RecordTypeCount Integer         Size of the list, eliminates need for flow to count
    * @property DefaultRecordTypeId Id          Which RecordType is the user's default
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class RecordTypeResult {
        @InvocableVariable(Required=true)
        public List<RecordType> RecordTypes = new List<RecordType>();
        @InvocableVariable(Required=true)
        public Integer RecordTypeCount = 0;
        @InvocableVariable(Required=true)
        public Id DefaultRecordTypeId;
    }
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Invocable method, returns the List of RecordTypes for a given sObject depending on the user
    * which invokes it. Invocables expect a List<> as the param and output, when run from a flow
    * these List items will contain a single item.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    gcrId           List<RecordTypeQuery>
    * @return   List<RecordTypeResult>
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @InvocableMethod(label='Get Record Type For User' description='Get the record types available for the current user profile')
    public static List<RecordTypeResult> getRecordTypes(List<RecordTypeQuery> paramsList) {
        RecordTypeQuery params = paramsList[0];

        List<RecordTypeInfo> rtiList = NF_Util.getAvailableRecordTypes(params.sObjectName);
        List<ID> rtIdList = new List<ID>();

        RecordTypeResult rtr = new RecordTypeResult();

        for (RecordTypeInfo rti:rtiList) {
            if (rti.isDefaultRecordTypeMapping()) {
                rtr.DefaultRecordTypeId = rti.getRecordTypeId();
            }
            rtIdList.add(rti.getRecordTypeId());
        }

        if (rtIdList.size() > 0) {
            rtr.RecordTypes = [SELECT Id, Name, DeveloperName, Sobjecttype FROM RecordType WHERE Id IN :rtIdList];
            rtr.RecordTypeCount = rtr.RecordTypes.size();
        }

        return new List<RecordTypeResult>{rtr};
    }
}