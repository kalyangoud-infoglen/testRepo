public with sharing class EmailDomainCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {

        // Get the Metasploit service
        MetasploitService metasploit = MetasploitService.getInstance();


        // Construct and return the result
        DataQuality.CheckResult result = new DataQuality.CheckResult(); 
        result.pointsPossible = 1;
        result.pointsAwarded =
                metasploit.validateEmail((String) value).valid ? 1 : 0;

        System.debug('(EmailDomainCheck)result.pointsAwarded = '+result.pointsAwarded
            + ' value is = '+ value);

        return result;
    }
}