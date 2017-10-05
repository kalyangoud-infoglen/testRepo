public with sharing class ContainsSwearCheck implements DataQuality.Check {
    public DataQuality.CheckResult process(Object value) {
        DataQuality.CheckResult result = new DataQuality.CheckResult();

        result.pointsPossible = 1;
        result.pointsAwarded =
                DataQualityUtil.countSwearWords(value) > 0 ? 0 : 1;

        return result;
    }
}