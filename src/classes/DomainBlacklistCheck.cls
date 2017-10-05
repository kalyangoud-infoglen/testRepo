public with sharing class DomainBlacklistCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 

        if(DataQualityUtil.checkRestrictedDomain(value)){
            result.error = DomainBlacklistCheck.class.getName()  + ' class failed';

        }
        
        else result.error = null;

        return result;
    }
}