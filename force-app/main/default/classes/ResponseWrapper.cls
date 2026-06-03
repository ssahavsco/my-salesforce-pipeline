public with sharing class ResponseWrapper {
    @AuraEnabled
    public String data;
    @AuraEnabled
    public Boolean status;
    @AuraEnabled
    public String errormessage;
  
    public ResponseWrapper(){
      this.status = false;
      this.data = '';
    }
  
    public ResponseWrapper(String data, Boolean status, string errormessage) {
      this.data = data;
      this.status = status;
      this.errormessage = errormessage;
    }
}