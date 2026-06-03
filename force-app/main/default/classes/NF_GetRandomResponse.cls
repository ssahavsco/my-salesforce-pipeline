/**
 * Created by NeuraFlash LLC.
 */

public with sharing class NF_GetRandomResponse {
    static String BOT_NAME = 'HerBot';

    public class Input{
        @InvocableVariable(required=true)
        public String intentName;
    }
    public class Output{
        @InvocableVariable(required=true)
        public String response;
    }

    @InvocableMethod(label='Neuraflash - Get Random Response')
    public static List<Output> getResponse(List<Input> input){
        String intentName = input.get(0).intentName;
        List<Output> result = new List<Output>();
        Output out = new Output();
        out.response = getRandomResponse(intentName);
        result.add(out);
        return result;
    }
    public static String getRandomResponse(string intentName){
        try{
            Set<String>  respSet = new Set<String>();
            for(EinsteinBot_Dynamic_Message__mdt respSettings : [SELECT Bot_Name__c, Intent__c, Response__c FROM EinsteinBot_Dynamic_Message__mdt WHERE Bot_Name__c = :BOT_NAME AND Intent__c = :intentName]){
                respSet.add(respSettings.Response__c);
            }
            if(!respSet.isEmpty()){
                return new List<String>(respSet)[Math.mod(Math.abs(Crypto.getRandomLong().intValue()), respSet.size())];
            }
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG,'Exception: ' + e);
        }
        return null;
    }
}