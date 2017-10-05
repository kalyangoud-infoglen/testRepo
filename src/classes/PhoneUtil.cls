global class PhoneUtil {

    /**
     * @return a really long regex based on all of the known country codes
     */
    global static String getCountryCodeRegex() {

        // Compile a list of the country codes
        List<String> countryCodes = new List<String>();

        for (PhoneCountryCode__c eachEntry : PhoneCountryCode__c.getAll().values()) {
            countryCodes.add(eachEntry.Name);
        }

        return '^\\+*(' + String.join(countryCodes, '|') + ')';
    }

    //Phone number: check the entire phone string against a black listed List of 
    //strings saved in SFDC custom setiing.

    public static Boolean checkRestrictedPhone(Object value) {
        return checkRestrictedPhone((String)value);
    }
    
    public static Boolean checkRestrictedPhone(String value) {
        
        // Assume a nice clean value unless proven otherwise
        Boolean outcome = false;

        if (value != null) {
            for (String eachNumber : getRestrictedPhone()) {
                if (value.equals(eachNumber)) {
                    outcome = true;
                }
            }
        }

        return outcome;
    }

    public static Set<String> getRestrictedPhone() {
        Set<String> pNumbers = new Set<String>();

        for (PhoneNumbers__c eachEntry : PhoneNumbers__c.getAll().values()) {
            if (eachEntry.isInvalid__c) {
                pNumbers.add(eachEntry.Name);
            }
        }

        return pNumbers;
    }

    //Phone number: check the entire phone string against a black listed List of 
    //regular Expressions (regEx) saved in SFDC custom setiing.

    public static Boolean checkRestrictedRegex(Object value) {
        return checkRestrictedRegex((String)value);
    }
    
    public static Boolean checkRestrictedRegex(String value) {
        
        // Assume a nice clean value unlesl proven otherwise
        Boolean outcome = false;

        String phoneRegex = getRestrictedRegex();
        
        Matcher phoneNumMatcher =
                Pattern.compile(phoneRegex).matcher(value);

        outcome = phoneNumMatcher.find()
                ? true
                : false;

        return outcome;
    }

    public static String getRestrictedRegex() {
        List<String> getRestrictedRegex = new List<String>();

        for (PhoneNumbers__c eachEntry : PhoneNumbers__c.getAll().values()) {
            if (eachEntry.isRegex__c) {
                getRestrictedRegex.add(eachEntry.Name);
            }
        }

        return '^\\+*(' + String.join(getRestrictedRegex, '|') + ')';
    }
}