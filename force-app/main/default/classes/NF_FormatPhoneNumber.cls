/**
 * Created by adamundus on 10/1/20.
 */

public with sharing class NF_FormatPhoneNumber {

    public class Input{
        @InvocableVariable(required=true)
        public String phoneNumber;
    }

    public class Output{
        @InvocableVariable(required=true)
        public String formattedNumber;
    }

    @InvocableMethod(Label='Neuraflash - Format Phone Number')
    public static List<Output> formatPhoneNumber(List<input> inputs){
        List<Output> outputs = new List<NF_FormatPhoneNumber.Output>();
        Output out = new Output();
        out.formattedNumber = inputs[0].phoneNumber.replaceAll('[^0-9]','');
        if(out.formattedNumber.length() > 10){
            out.formattedNumber = out.formattedNumber.substring(out.formattedNumber.length()-10);
        }
        System.debug(LoggingLevel.DEBUG,'NF_FormatPhoneNumber >> Formatted number "'+inputs[0].phoneNumber+'" to "'+out.formattedNumber+'"');
        outputs.add(out);
        return outputs;
    }

}