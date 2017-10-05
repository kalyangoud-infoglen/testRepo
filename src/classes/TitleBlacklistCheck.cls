public with sharing class TitleBlacklistCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 

        if (DataQualityUtil.checkRestrictedName(value)) {
            result.error = TitleBlacklistCheck.class.getName()+ ' class failed';
        }
        else {
            result.error = null;
        }

        return result;
    }
}