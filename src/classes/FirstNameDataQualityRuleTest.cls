@isTest
private class FirstNameDataQualityRuleTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    @isTest
    private static void getField() {

        // Given
        DataQuality.Rule rule =
                new FirstNameDataQualityRule(Schema.Lead.FirstName);

        // When
        Test.startTest();

        Schema.SObjectField field = rule.getField();

        // Then
        Test.stopTest();

        System.assertEquals(Schema.Lead.FirstName, field,
                'DataQuality.Rule.getField');
    }

    /**
     * - Given the string "Gordon";
     * - When the string is processed through the First Name rule;
     * - Then a score of 100 and cleaned value "Gordon" is returned
     */
    @isTest
    private static void processCleanValue() {

        // Given
        String name = 'Gordon';

        // When
        Test.startTest();

        DataQuality.RuleResult result =
                new FirstNameDataQualityRule(Schema.Lead.FirstName).process(name);

        // Then
        Test.stopTest();

        System.assertEquals(100.0, result.score, 'data quality score');
        System.assertEquals('Gordon', result.cleanValue, 'clean value');
    }

    /**
     * - Given the string "G";
     * - When the string is processed through the First Name rule;
     * - Then a score of 33 is returned, along with a null clean value and
     *   "G" as the resultant value
     */
    @isTest
    private static void processSingleCharValue() {

        // Given
        String name = 'G';

        // When
        Test.startTest();

        DataQuality.RuleResult result =
                new FirstNameDataQualityRule(Schema.Lead.FirstName).process(name);

        // Then
        Test.stopTest();

        System.assertEquals(33.0, result.score, 'data quality score');
        System.assertEquals(null, result.cleanValue, 'clean value');
        System.assertEquals('G', result.getValue(), 'value');
    }

    /**
     * - Given the string "ng";
     * - When the string is processed through the First Name rule;
     * - Then a score of 67 is returned, along with 'Ng' as the clean value
     */
    @isTest
    private static void processTwoCharNoVowelValue() {

        // Given
        String name = 'ng';

        // When
        Test.startTest();

        DataQuality.RuleResult result =
                new FirstNameDataQualityRule(Schema.Lead.FirstName).process(name);

        // Then
        Test.stopTest();

        System.assertEquals(67.0, result.score, 'data quality score');
        System.assertEquals('Ng', result.cleanValue, 'clean value');
        System.assertEquals('Ng', result.getValue(), 'value');
    }

    /**
     * - Given the string "!@#$";
     * - When the string is processed through the First Name rule;
     * - Then a score of 33 is returned (no swear words),
     *   along with null as the clean value and '!@#$' as the resultant value
     */
    @isTest
    private static void processSpecialTwoCharValue() {

        // Given
        String name = '!@#$';

        // When
        Test.startTest();

        DataQuality.RuleResult result =
                new FirstNameDataQualityRule(Schema.Lead.FirstName).process(name);

        // Then
        Test.stopTest();

        System.assertEquals(33.0, result.score, 'data quality score');
        System.assertEquals(null, result.cleanValue, 'clean value');
        System.assertEquals('!@#$', result.getValue(), 'value');
    }
}