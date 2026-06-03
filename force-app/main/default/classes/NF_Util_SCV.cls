/**
 * @File Name          : NF_Util_SCV.cls
 * @Description        : Utility class to consolidate common code
 * @Author             : NeuraFlash
 **/
public without sharing class NF_Util_SCV {
    
    public static final String US_COUNTRY_CODE = '+1';

    /* PHONE DELIMETER NOT USED BECAUSE ONLY 
     * 1 PHONE NUMBER IS USED FOR ACCOUNT LOOKUP */
    public static final String PHONE_DELIM = '|';


    /**
     * Method to strip special characters from phone number
     * It will keep + and 0-9 in the phone number.
     * At the end, it will add a delimiter for making search easier in the
     * external SOQL query.
     * @return String
     **/
    public static String fixPhoneFormat(String oldPhone) {
        String newPhone = '';
        if (oldPhone != null) {
            system.debug('phone number old : '+oldPhone);
            newPhone =  oldPhone.replaceAll('[+]?[^0-9]+', '');
            system.debug('phone number new : '+newPhone);
            system.debug('phone number new : '+newPhone.length());
           
            if (newPhone.length() == 10) {
                newPhone = US_COUNTRY_CODE + newPhone;
            } else {
                newPhone = '+' + newPhone;
            }
        }
        return newPhone;
    }
}