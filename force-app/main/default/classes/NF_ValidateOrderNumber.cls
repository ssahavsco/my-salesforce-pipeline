/* Modified on 10/1/2020 for LBRAN-54 
regex chnage to incorporate case-sensitive order number
*/
public with sharing class NF_ValidateOrderNumber {
    public class Input {
        @InvocableVariable(required=true)
        public String inputOrderNumber;
    }
    public class Output {
        @InvocableVariable(required=true)
        public String orderNumber = '';
        
        @InvocableVariable(required=true)
        public Boolean isOrderNumberValid = null;
        
        @InvocableVariable(required=true)
        public Boolean isHtoOrder = null;
    }
    
    @InvocableMethod(label='Neuraflash - Validate Order Number')
    public static List<Output> validateOrderNumber(List<Input> input) {
        List<Output> result = new List<Output>();
        Output out = new Output();
        System.debug(
            LoggingLevel.DEBUG,
            '>> validateEmailAddress : Email Input: ' + input[0].inputOrderNumber
        );
        if (String.isBlank(input[0].inputOrderNumber)) {
            System.debug(
                LoggingLevel.DEBUG,
                '>> validateEmailAddress : Email is blank'
            );
            out.isOrderNumberValid = false;
            result.add(out);
            return result;
        }
        RegexResultWrapper regexResult = validateEmail(input[0].inputOrderNumber);
        if (!regexResult.isValid) {
            // invalid email address provided
            System.debug(
                LoggingLevel.DEBUG,
                '>> validateEmailAddress : Email Validation Fail'
            );
            
            out.isOrderNumberValid = false;
            result.add(out);
            return result;
        } else {
            System.debug(
                LoggingLevel.DEBUG,
                '>> validateEmailAddress : Email Validation Passed'
            );
            
            if (input[0].inputOrderNumber.startsWith('T')) {
                out.isHtoOrder = true;
            } 
            
            system.debug('out.isHtoOrder'+out.isHtoOrder);
            out.isOrderNumberValid = true;
            out.orderNumber = regexResult.matchGroupValue;
        }
        result.add(out);
        return result;
    }
    
    public static RegexResultWrapper validateEmail(String orderNumber) {
        RegexResultWrapper regexResultWrapper = new RegexResultWrapper();
        regexResultWrapper.isValid = false;
    
        if (String.isBlank(orderNumber)) {
            return regexResultWrapper;
        }
    
        orderNumber = orderNumber.trim();
    
        // Standard order: exactly 10 chars, letter + 9 digits
        String standardRegex = '^[A-Za-z][0-9]{9}$';
        Pattern standardPattern = Pattern.compile(standardRegex);
        Matcher standardMatcher = standardPattern.matcher(orderNumber);
    
        // TikTok order: exactly 18 digits
        String tiktokRegex = '^[0-9]{18}$';
        Pattern tikTokPattern = Pattern.compile(tiktokRegex);
        Matcher tikTokMatcher = tikTokPattern.matcher(orderNumber);
    
        if (standardMatcher.matches()) {
            regexResultWrapper.isValid = true;
            regexResultWrapper.matchGroupValue = orderNumber;
        }
        else if (tikTokMatcher.matches()) {
            regexResultWrapper.isValid = true;
            regexResultWrapper.matchGroupValue = orderNumber;
        }
        else {
            // “I can't find it” case
            String cantFindRegex = '(?i).*((don(\'?)t know)|((can(\'?)t)|(couldn(\'?)t)) find).*';
            Pattern cantFindPattern = Pattern.compile(cantFindRegex);
            Matcher cantFindMatcher = cantFindPattern.matcher(orderNumber);
    
            if (cantFindMatcher.matches()) {
                regexResultWrapper.isValid = true;
                regexResultWrapper.matchGroupValue = 'I CAN\'T FIND IT';
            }
        }
    
        return regexResultWrapper;
    }

    
    public class RegexResultWrapper {
        public Boolean isValid;
        public String matchGroupValue;
    }
}