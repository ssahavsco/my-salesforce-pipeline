public with sharing class NF_SetString {
    @InvocableMethod(label='Neuraflash - Set String')
    public static List<String> setString(List<String> input){
        return new List<String>{input[0]};
    }
}