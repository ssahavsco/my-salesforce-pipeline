/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller class for newCase
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-12
* @modified       2021-05-28
* @systemLayer    Controller
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ravikant.kedia@neuraflash.com
* 2021-04-14      code commenting

* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-14      updated method getDetails()

* v1.0            ravikant.kedia@neuraflash.com
* 2021-05-28      updated method getDetails()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class newCaseController {

    public class CaseResponse{
        // @AuraEnabled public Contact customer;
        @AuraEnabled public Account customer;
        @AuraEnabled public Account acc;
        @AuraEnabled public String accType;
        @AuraEnabled public List<SelectOpt> caseRecordTypeOptions;
        @AuraEnabled public String defaultCaseRecordTypeId;
    }
    
    public class SelectOpt{
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public SelectOpt( String label, String value ){
            this.label = label;
            this.value = value;
        }
    }
    
    public class SaveData{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Case newCase;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * get initial data for creating new case
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    customerId  String( customer Id on the selected order )
    * @param    originStore  String( store Id )
    * @return   String      structured data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static String getDetails( String customerId, String originStore ){
        CaseResponse res = new CaseResponse();

        if( customerId != NULL ){
            List<Account> accList = [ SELECT Id, PersonContactId, Name, Phone, PersonEmail FROM Account WHERE CID__c = :customerId ];
            if( !accList.isEmpty() ){
                res.customer = accList[0];
            }
        }
        
        if( originStore != NULL ){
            List<Account> accList = [ SELECT Id, Name, RecordTypeId FROM Account WHERE SAP_Store__c = :originStore ];
            if( !accList.isEmpty() ){
                res.acc     = accList[0];
                res.accType = Schema.SObjectType.Account.getRecordTypeInfosById().get( res.acc.RecordTypeId ).getDeveloperName();
            }
        }

        res.caseRecordTypeOptions = new List<SelectOpt>();
        for( RecordTypeInfo info : Case.SObjectType.getDescribe().getRecordTypeInfos() ) {
            if( info.isAvailable() && !info.isMaster() ){
                res.caseRecordTypeOptions.add( new SelectOpt( info.getName(), info.getRecordTypeId() ) );
            }
            if( info.isDefaultRecordTypeMapping() ){
                res.defaultCaseRecordTypeId = info.getRecordTypeId();
            }
        }

        return JSON.serialize( res );
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * create new case
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    caseData    String( case Data )
    * @return   String      structured data
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static String createCase( String caseData ){
        SaveData data = new SaveData();
        data.success = true;

        try{
            Case newCase = ( Case ) JSON.deserialize( caseData, Case.class );
            insert newCase;
            data.newCase = newCase;
        } catch( Exception ex ){
            data.success = false;
            data.errorMessage = ex.getMessage();
            return JSON.serialize( data );
        }
        return JSON.serialize( data );
    }
}