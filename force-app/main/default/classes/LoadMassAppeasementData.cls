public with sharing class LoadMassAppeasementData {
    
    @AuraEnabled
    public static String loadRecords(String input){
        List<Object> jsonArray = (List<Object>) JSON.deserializeUntyped(input);
        List<Mass_Appeasement__c> ma = new List<Mass_Appeasement__c>();
        String batchId;

        for (Object jsonObject : jsonArray) {

            Map<String, Object> jsonMap = (Map<String, Object>) jsonObject;
            Mass_Appeasement__c c = new Mass_Appeasement__c();
            
            String email = (String) jsonMap.get('Email');
            String firstName = (String) jsonMap.get('FirstName');
            String lastName = (String) jsonMap.get('LastName');
            batchId = String.valueOf( jsonMap.get('Batch'));
            String phoneNumber = String.valueOf(jsonMap.get('PhoneNumber'));
            Integer amount = Integer.valueOf(jsonMap.get('Amount'));

            c.RECIPIENT_EMAIL__C = email;
            c.RECIPIENT_FIRST_NAME__C = firstName;
            c.RECIPIENT_LAST_NAME__C = lastName;
            c.RECIPIENT_PHONE__C = phoneNumber;
            c.GIFT_CARD_AMOUNT__C = (decimal) amount;
            c.Price_Override_Reason__c = 'CD_POR';
            c.Gift_Card_Type__c = 'EGC';
            c.BatchID__c = batchId;
            ma.add(c);
        }

        Database.SaveResult[] srList = Database.insert(ma, false);

        List<String> result = new List<String>();
        Mass_Appeasement__c [] newReorcds = [Select Id , Name, Recipient_First_Name__c, Recipient_Last_Name__c,  Recipient_Email__c, Gift_Card_Amount__c,   
        CreatedDate, BatchID__c from Mass_Appeasement__c where CreatedDate = today and BatchID__c =: batchId];

        List<Response> listResponse = new List<Response>();
       
        
            for (Mass_Appeasement__c index : newReorcds) {
                result.add(index.Name + '::' + index.Recipient_Email__c + '::' + index.GIFT_CARD_AMOUNT__C );
                Response response = new Response();
                response.status = 'Successfully Inserted';
                response.records.ordDate = String.valueOf( index.CreatedDate);
                response.records.orderNumber = index.Name ;
                response.records.firstName = index.Recipient_First_Name__c;
                response.records.lastName = index.Recipient_Last_Name__c;
                response.records.amount = String.valueOf( index.Gift_Card_Amount__c );
                response.records.email = index.Recipient_Email__c;
                response.records.batchId = index.BatchID__c;
                listResponse.add(response);
            }

            for (Integer i=0; i < srList.size(); i++) {
                Database.SaveResult sr = srList[i];
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        result.add(err.getMessage() + '=>' + jsonArray[i]);
                        Map<String, Object> jsonMap = (Map<String, Object>) jsonArray[i];
                        Response response = new Response();
                        response.status = 'FAILED';
                        response.errorMsg = err.getMessage();
                        response.records.firstName = (String) jsonMap.get('FirstName');
                        response.records.lastName = (String) jsonMap.get('LastName');
                        response.records.email = (String) jsonMap.get('Email') ;
                        response.records.amount = String.valueOf(jsonMap.get('Amount'));
                        response.records.batchId = String.valueOf( jsonMap.get('Batch'));
                        listResponse.add(response);
                    }
                }
            }
        System.debug(JSON.serialize(listResponse));    

       return JSON.serialize(listResponse);   
    }

    @AuraEnabled
    public static string displayRecords(String orderBatchNumber){
        Mass_Appeasement__c [] dispRecords = [Select Id,  Name, CreatedDate, Message_Id__c, BatchID__c, Recipient_First_Name__c, Recipient_Last_Name__c, Gift_Card_Amount__c , Recipient_Email__c from Mass_Appeasement__c where CreatedDate = today and BatchID__c =:orderBatchNumber];

        List<Response> listResponse = new List<Response>();
        

        for (Mass_Appeasement__c index : dispRecords) {
            Response response = new Response();
            response.status = 'Successfully Inserted';
            response.records.ordDate = String.valueOf( index.CreatedDate);
            response.records.orderNumber = index.Name ;
            response.records.firstName = index.Recipient_First_Name__c;
            response.records.lastName = index.Recipient_Last_Name__c;
            response.records.amount = String.valueOf( index.Gift_Card_Amount__c );
            response.records.email = index.Recipient_Email__c;
            response.records.batchId = index.BatchID__c;
            response.records.messageId = index.Message_Id__c;
            listResponse.add(response);
        }
        System.debug(JSON.serialize(listResponse));    
        return JSON.serialize(listResponse); 
    }


    public class Response{
        String status;
        String errorMsg;
        Records records; 

        Response(){
            this.records = New Records();
        }

    }

    public class Records{
        string ordDate;
        String orderNumber;
        String firstName;
        String lastName;
        String email;
        String amount;
        String batchId;
        String messageId;
    }

}