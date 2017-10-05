public with sharing class PhoneNumberBlacklistCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 

        if(PhoneUtil.checkRestrictedPhone(value)) {
            result.error = PhoneNumberBlacklistCheck.class.getName() + ' class failed';
        }
        else {
            result.error = null;
        }

        return result;
    }
}