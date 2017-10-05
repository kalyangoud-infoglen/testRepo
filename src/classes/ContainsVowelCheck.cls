public with sharing class ContainsVowelCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {
        DataQuality.CheckResult result = new DataQuality.CheckResult();

        result.pointsPossible = 1;
        result.pointsAwarded =
                DataQualityUtil.countVowelChars(value) > 0 ? 1 : 0;

        return result;
    }
}