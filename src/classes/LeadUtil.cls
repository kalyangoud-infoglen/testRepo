public with sharing class LeadUtil {

    public static final String JUNK_SCRUB_ASSIGNMENT_RULE = 'Junk Scrub';

    public static AssignmentRule getAssignmentRule(String name) {
        return [
            SELECT Id
            FROM AssignmentRule
            WHERE Name = :name
        ];
    }

    public static List<DataQuality.Rule> getDataQualityRules() {
        return new List<DataQuality.Rule> {
            new FirstNameDataQualityRule(Schema.Lead.FirstName),
            new LastNameDataQualityRule(Schema.Lead.LastName),
            new TitleDataQualityRule(Schema.Lead.Title),
            new PhoneDataQualityRule(Schema.Lead.Phone),
            new EmailDataQualityRule(Schema.Lead.Email),
            new CompanyDataQualityRule(Schema.Lead.Company)
        };
    }

    public static AssignmentRule getJunkScrubAssignmentRule() {
        return getAssignmentRule(JUNK_SCRUB_ASSIGNMENT_RULE);
    }

    /**
     * Given a list of leads, score the data quality for the leads based
     * on established business rules. In the process of scoring, some fields
     * on the Lead records may be modified for cleaning purposes either before
     * or after scoring.
     *
     * @param records The Lead records to score
     * 
     * @return the Lead records with Data Quality Score and other fields
     *.        set to expected values
     */
    public static List<Lead> scoreDataQuality(List<Lead> records) {


        List<DataQuality.Rule> rules = getDataQualityRules();
        for (Lead eachRecord : records) {
            Decimal totalScore = 0;
            List<String> failedReasons = new List<String>();

            for (DataQuality.Rule eachRule : rules) {
                DataQuality.RuleResult result = DataQualityUtil.process(eachRecord, eachRule);
                totalScore += result.score;

                if (result.failReason != null) {
                    failedReasons.add(result.failReason);
                }
            }

            eachRecord.DataQualityScore__c = (totalScore / rules.size()).setScale(0);
            eachRecord.JunkedReason__c = failedReasons.size() == 0 ? null : String.join(failedReasons, '; ');
        }

        return records;
    }
    
    public static Boolean isOwnerQueueMember(Id ownerId) {
        Boolean result = false;
        List<LeadAssignment__Queue_Member_Detail__c> memberList = [Select Id,LeadAssignment__Queue_member__c from LeadAssignment__Queue_Member_Detail__c where LeadAssignment__Queue_member__c =:ownerId AND LeadAssignment__Queue_Detail__r.LeadAssignment__Active__c =: true limit 1];
        if(!memberList.isempty() && memberList.size() > 0) {
            result = true;
        }
        else {
            result = false;
        }
        return result;
    }
}