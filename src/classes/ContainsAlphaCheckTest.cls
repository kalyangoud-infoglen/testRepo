@isTest
private class ContainsAlphaCheckTest {
    
    /**
     * Test our ability to correctly award points based on a given string
     * checked for the number of alphabet characters in the string.
     *
     * In all cases, the points possible should be exactly 1.
     *
     * Given               | Then
     * ------------------- | ----
     * a                   | 0
     * aa                  | 1
     * !@#$                | 0
     * Rapid7              | 1
     * Thi$ 2 shall p@ss   | 1
     * George R. R. Martin | 1
     *                     | 0
     */
    @isTest
    private static void checkAlphaChars() {
        
        // Given
        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'a' => 0,
            'aa' => 1,
            '!@#$' => 0,
            'Rapid7' => 1,
            'Thi$ 2 shall p@ss' => 1,
            'George R. R. Martin' => 1,
            null => 0
        };
        
        // When
        Test.startTest();
        
        Map<String, DataQuality.CheckResult> actualMap =
                new Map<String, DataQuality.CheckResult>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    new ContainsAlphaCheck().process(eachString));
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