public with sharing class EmailBlacklistCheck implements DataQuality.Check {
	public DataQuality.CheckResult process(Object value) {

        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 

        if(DataQualityUtil.checkRestrictedEmail(value)){
             result.error = EmailBlacklistCheck.class.getName()  + ' class failed';
        }
        
        else result.error = null;

        return result;
    }
}