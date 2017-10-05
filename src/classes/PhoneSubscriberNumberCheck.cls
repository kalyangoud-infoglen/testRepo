public with sharing class PhoneSubscriberNumberCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 
        String phoneNum = (String)value;
        Boolean valid = phoneNum.startsWithIgnoreCase('+') ? true : Phone.valueOf(phoneNum).isValid();
        
        result.pointsPossible = 1;
        result.pointsAwarded = valid ? 1 : 0;

        return result;
    }
}