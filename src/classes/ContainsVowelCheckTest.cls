@isTest
private class ContainsVowelCheckTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }
    
    /**
     * Test our ability to correctly count the number of alphabet characters
     * in a string
     *
     * Given               | Then
     * ------------------- | ----
     * a                   | 1
     * !@#$                | 0
     * Rapid7              | 1
     * Thi$ 2 shall p@ss   | 1
     * George R. R. Martin | 1
     * Angry Birds         | 1
     *                     | 0
     * In all cases, the points possible should be exactly 1.
     */
    @isTest
    private static void checkVowelChars() {
        
        // Given
        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'a' => 1,
            '!@#$' => 0,
            'Rapid7' => 1,
            'Thi$ 2 shall p@ss' => 1,
            'George R. R. Martin' => 1,
            'Angry Birds' => 1,
            null => 0
        };
        
        // When
        Test.startTest();
        
        Map<String, DataQuality.CheckResult> actualMap =
                new Map<String, DataQuality.CheckResult>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    new ContainsVowelCheck().process(eachString));
        }
        
        // Then
        Test.stopTest();
        
        for (String eachString : expectedMap.keySet()) {
            DataQuality.CheckResult result = actualMap.get(eachString);

            System.assertEquals(1, result.pointsPossible,
                    'points possible: ' + eachString);
            System.assertEquals(expectedMap.get(eachString), result.pointsAwarded,
                    'points awarded: ' + eachString);
        }
    }
}