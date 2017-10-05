public with sharing class EmailDataQualityRule implements DataQuality.Rule {

    /**
     * The score at which the value is considered to have passed the
     * data quality requirement embodied by the rule
     */
    public static final Decimal PASSING_SCORE = 34.0;

    private Schema.SObjectField field;

    public EmailDataQualityRule(Schema.SObjectField field) {
        this.field = field;
    }

    public static String clean(String value) {
        value = value.toLowerCase();
        return value;
    }

    public static DataQuality.ScoreResult score(String value) {

         DataQuality.ScoreResult result = new  DataQuality.ScoreResult();

        // Assume a terrible score unless proven otherwise
        Decimal score = 0.0;
        List<String> junkReasons = new List<String>();

        // Only try calculating a score if there's even a value to examine
        // in the First Name field
        if (value != null) {
            Decimal pointsPossible = 0.0;
            Decimal pointsAwarded = 0.0;

            for (DataQuality.Check eachCheck : getChecks()) {
                DataQuality.CheckResult res = eachCheck.process(value);
                pointsPossible += res.pointsPossible;
                pointsAwarded += res.pointsAwarded;
                if (res.isFailed()) junkReasons.add(res.error);
            }

            score = pointsAwarded / pointsPossible * 100;
        }

        result.score = score.setScale(0);
        result.failReason = junkReasons.size() == 0 ? null : String.join(junkReasons, '; ');

        return result;
    }


    public static List<DataQuality.Check> getChecks() {
        return new List<DataQuality.Check> {
            new EmailDomainCheck(),
            new EmailBlacklistCheck(),
            new DomainBlacklistCheck()
        };
    }

    public Schema.SObjectField getField() {
        return this.field;
    }

    public DataQuality.RuleResult process(Object value) {

        // Initialize the result
        DataQuality.RuleResult result = new DataQuality.RuleResult();
        result.rawValue = value;

        // Calculate the score
        DataQuality.ScoreResult scoreFinal = score((String)value);
        result.score = scoreFinal.score;

        // If we've got a passing score, clean the value
        if (result.score >= PASSING_SCORE) {
            result.cleanValue = clean((String)value);
        }

        result.failReason = scoreFinal.failReason;

        return result; 
    }
}