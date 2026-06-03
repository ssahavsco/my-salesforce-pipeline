/**
 * Created by NeuraFlash LLC on 9/4/20.
 */

public with sharing class NF_SetBool {
    @InvocableMethod(label='Neuraflash - Set Boolean')
    public static List<Boolean> setBool(List<String> input) {
        String val = input.get(0);
        if(val.toLowerCase() == 'true'){
            return new List<Boolean>{true};
        }
        return new List<Boolean>{false};
    }
}