public with sharing class DataQualityUtil {

    /**
     * Character class representing the alphabet
     */
    public static final String ALPHA_CHARS_REGEX = '\\p{Alpha}';

    /**
     * Special characters that should be stripped when cleaning a string
     */
    public static final String SPECIAL_CHARS_REGEX =
            '[~!@#$%^*{}|:"<>?`=\\[\\]\\\\;\',.]';
    
    /**
     * Characters that count as vowels for scoring purposes
     */
    public static final String VOWEL_CHARS_REGEX = '[AEIOUYaeiouy]';

    /**
     * @param value Phone number
     *
     * @return a consistently formatted phone number that has a country prefix
     *         and also all English vanity characters transcribed as numbers
     */
    public static String cleanPhone(String value) {
        if (value != null) {

            // Format the country prefix

            // Transform vanity characters

            // Strip non-digits

        }

        return value;
    }

    public static String cleanSpecialChars(String value) {
        return value == null
                ? null
                : value.replaceAll(SPECIAL_CHARS_REGEX, '');
    }

    public static String cleanProperCase(String value) {
        return value == null
                ? null
                : value.capitalize();
    }

    public static Integer countAlphaChars(Object value) {
        return countAlphaChars((String)value);
    }
    
    public static Integer countAlphaChars(String value) {
        return value == null
                ? 0
                : value.length() - value.replaceAll(ALPHA_CHARS_REGEX, '').length();
    }

    public static Integer countSwearWords(Object value) {
        return countSwearWords((String)value);
    }
    
    public static Integer countSwearWords(String value) {
        
        // Assume a nice clean value unlesl proven otherwise
        Integer count = 0;

        if (value != null) {

            // Drop the case on the value,
            // assuming swear words are entered in all lowercase in our glossary
            value = value.toLowerCase();

            for (String eachWord : getSwearWordSet()) {
                if (value.contains(eachWord)) {
                    count++;
                }
            }
        }

        return count;
    }

    public static Integer countVowelChars(Object value) {
        return countVowelChars((String)value);
    }
    
    public static Integer countVowelChars(String value) {
        return value == null
                ? 0
                : value.length() - value.replaceAll(VOWEL_CHARS_REGEX, '').length();
    }

    public static Set<String> getSwearWordSet() {
        Set<String> words = new Set<String>();

        for (GlossaryEntry__c eachEntry : GlossaryEntry__c.getAll().values()) {
            if (eachEntry.IsSwear__c) {
                words.add(eachEntry.Name);
            }
        }

        return words;
    }

    public static DataQuality.RuleResult process(Sobject record, DataQuality.Rule rule) {
        DataQuality.RuleResult result = rule.process(record.get(rule.getField()));
        record.put(rule.getField(), result.getValue());
        return result;
    }

    //Check the email string against a list of restricted email strings. 
    //Those are stored as a custom setting EmailDomain__c in Salesforce 
    //with a checkbox identifying those strings as BadEmail
    public static Boolean checkRestrictedEmail(Object value) {
        return checkRestrictedEmail((String)value);
    }
    
    public static Boolean checkRestrictedEmail(String value) {
        
        // Assume a nice clean value unless proven otherwise
        Boolean outcome = false;

        if (value != null) {
            for (String eachEmail : getRestrictedEmail()) {
                if (value.contains(eachEmail)) {
                    outcome = true;
                }
            }
        }

        return outcome;
    }

    public static Set<String> getRestrictedEmail() {
        Set<String> emails = new Set<String>();

        for (EmailDomain__c eachEntry : EmailDomain__c.getAll().values()) {
            if (eachEntry.BadEmail__c) {
                emails.add(eachEntry.Name);
            }
        }

        return emails;
    }

    //Check the email string against a list of restricted domains. 
    //Those are stored as a custom setting EmailDomain__c in Salesforce 
    //with a checkbox identifying those strings as BadDomain
    public static Boolean checkRestrictedDomain(Object value) {
        return checkRestrictedDomain((String)value);
    }
    
    public static Boolean checkRestrictedDomain(String value) {
        
        // Assume a nice clean value unless proven otherwise
        Boolean outcome = false;

        if (value != null) {
            for (String eachDomian : getRestrictedDomain()) {
                if (value.contains(eachDomian)) {
                    outcome = true;
                }
            }
        }

        return outcome;
    }

    public static Set<String> getRestrictedDomain() {
        Set<String> domains = new Set<String>();

        for (EmailDomain__c eachEntry : EmailDomain__c.getAll().values()) {
            if (eachEntry.BadDomain__c) {
                domains.add(eachEntry.Name);
            }
        }

        return domains;
    }

    //Check Lead's FirstName, LastName, Title, and Companyname strings
    //against a list of restricted name values. 
    //Those are stored as a custom setting GlossaryEntry__c in Salesforce 
    //with a checkbox identifying those strings as isRestricted
    public static Boolean checkRestrictedName(Object value) { 
        return checkRestrictedName((String)value);
    }
    
    public static Boolean checkRestrictedName(String value) {
        
        // Assume a nice clean value unless proven otherwise
        Boolean outcome = false;

        if (value != null) {
            for (String eachWord : getRestrictedName()) {
                if (value.equals(eachWord)) {
                    outcome = true; 
                }
            }
        }

        return outcome;
    }

    public static Set<String> getRestrictedName() {
        Set<String> words = new Set<String>();

         for (GlossaryEntry__c eachEntry : GlossaryEntry__c.getAll().values()) {
            if (eachEntry.isRestricted__c) {
                words.add(eachEntry.Name);
            }
        }

        return words;
    }
}