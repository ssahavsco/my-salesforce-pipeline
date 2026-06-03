public with sharing class NF_ValidateEmail {

    public class Input{
        @InvocableVariable(Required=true)
        public String inputEmailAddress;
    }
    public class Output{

        @InvocableVariable(Required=true)
        public String emailAddress = '';

        @InvocableVariable(Required=true)
        public Boolean isEmailValid = null;
    }

    @InvocableMethod(Label='Neuraflash - Validate Email Address')
    public static List<Output> validateEmailAddress(List<Input> input){
        List<Output> result = new List<Output>();
        Output out = new Output();
        System.debug(LoggingLevel.DEBUG,'>> validateEmailAddress : Email Input: ' + input[0].inputEmailAddress);
        if (String.isBlank(input[0].inputEmailAddress)){
            System.debug(LoggingLevel.DEBUG,'>> validateEmailAddress : Email is blank');
            out.isEmailValid = false;
            result.add(out);
            return result;
        }
        RegexResultWrapper regexResult = validateEmail(input[0].inputEmailAddress);
        if (!regexResult.isValid){
            // invalid email address provided
            System.debug(LoggingLevel.DEBUG,'>> validateEmailAddress : Email Validation Fail');
            out.isEmailValid = false;
            result.add(out);
            return result;
        } else {
            System.debug(LoggingLevel.DEBUG,'>> validateEmailAddress : Email Validation Passed');
            out.isEmailValid = true;
            out.emailAddress = regexResult.matchGroupValue;
        }
        result.add(out);
        return result;

    }

    public static RegexResultWrapper validateEmail(String email) {
        //Boolean res = true;
        RegexResultWrapper regexResultWrapper = new RegexResultWrapper();
        regexResultWrapper.isValid = false;
        String emailRegex = '.*?([a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}).*';
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(email);
        regexResultWrapper.isValid = myMatcher.matches();
        regexResultWrapper.matchGroupValue = regexResultWrapper.isValid ? myMatcher.group(1) : '';

        if (!myMatcher.matches())
        {
            regexResultWrapper.isValid = false;
        }
        return regexResultWrapper;
    }

    public class RegexResultWrapper {
        public Boolean isValid;
        public String matchGroupValue;
    }
}