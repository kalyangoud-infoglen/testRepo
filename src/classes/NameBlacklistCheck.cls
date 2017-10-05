public with sharing class NameBlacklistCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 

        if(DataQualityUtil.checkRestrictedName(value)) {
            result.error = NameBlacklistCheck.class.getName()+ ' class failed';
        }
        else {
            result.error = null;
        }

        return result;
    }
}