public with sharing class CompanyNameBlacklistCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 

        //result.isFailed = DataQualityUtil.checkRestrictedName(value);

        if(DataQualityUtil.checkRestrictedName(value)){

            result.error = CompanyNameBlacklistCheck.class.getName()+ ' class failed';
        }
        else result.error = null;

        return result;
    }
}