/**
 * Check whether a given value contains at least two characters
 * from the English alphabet
 */
public with sharing class ContainsAlphaCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {
        DataQuality.CheckResult result = new DataQuality.CheckResult();

        result.pointsPossible = 1;
        result.pointsAwarded =
                DataQualityUtil.countAlphaChars(value) < 2 ? 0 : 1;

        return result;
    }
}