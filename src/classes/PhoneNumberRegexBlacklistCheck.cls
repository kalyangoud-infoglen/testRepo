public with sharing class PhoneNumberRegexBlacklistCheck  implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult();
        
        //What we want to do here is to check for values
        //if the check fails we want the error ro display the name of the failed 
        //method; if it passes we want it to ne NULL (aka no error);

        if (PhoneUtil.checkRestrictedRegex(value)) {
            result.error = PhoneNumberRegexBlacklistCheck.class.getName() + ' class failed';
        }
        else {
            result.error = null;
        }

        return result;
    }
}