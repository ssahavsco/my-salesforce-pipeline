/***************************************************************
Interface Name : LB_InvokeContactActionFive9
CreatedDate : 06/28/2022
Description :  
Created By : Pooja Korrapati

Revision History

Date Name Story Number Description
* TODO: 06/28/2022  Pooja | DP-54273  - Case Creation: Automatically create a case Invokable method
 
***************************************************************/
public class LB_InvokeContactActionFive9 
{
  @InvocableMethod(callout=true label='Get Conatct Five9')    
     public static List<FlowResponseWrapper> getContact ( List<FlowRequestWrapper> flowInputs ){
         system.debug(flowInputs);
         List<FlowResponseWrapper> returnWrap = new List<FlowResponseWrapper>();
         FlowResponseWrapper singleWrap = new FlowResponseWrapper();
         //SOSL to find contact using ANI number
         //List<List<SObject>> searchList = [FIND :flowInputs[0].aniNumber IN ALL FIELDS Returning Account(Id, Name, CID__c  ORDER BY LastModifiedDate DESC) ];
         
         List<Account> searchAccountList = new   List<Account> ();
         searchAccountList = [Select Id, Name, CID__c,Phone_Search__c, PersonContactId  from Account where Phone_search__c = : flowInputs[0].aniNumber  ORDER BY LastModifiedDate DESC LIMIT 1 ];
         
         string conID;
         boolean cidPresent = false;
         
         // Check if multiple contacts returned and have CID
         if(searchAccountList.size()>1){
             for(Account acc : searchAccountList){
                 if(acc.CID__c !=null){
                     cidPresent=true;
                     conID = acc.PersonContactId;
                     break;
                 }
             }
             if(!cidPresent){
                 conID = searchAccountList[0].PersonContactId;
             }
         }else if(searchAccountList.size()==1){
            conID = searchAccountList[0].PersonContactId;
         }
         
         singleWrap.conRecordId = conID;
         returnWrap.add(singleWrap);
         return returnWrap; 
     }
    
    //Input Variables Wrapper
      public class FlowRequestWrapper{
        @InvocableVariable(label = 'ANI Phone Number')
        public String aniNumber;
    }
    
    //Output Variables Wrapper
     public class FlowResponseWrapper{
        @InvocableVariable(label = 'Contact Record')
        public String conRecordId;
     }
    
    
}