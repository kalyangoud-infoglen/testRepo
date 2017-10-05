@isTest
private class ContainsSwearCheckTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }
    
    /**
     * Test our ability to correctly identify swear words. For this test,
     * we will be creating more sanitized swear word entries in our glossary
     * so that people reading the code aren't unnecessarily offended by
     * foul language.
     *
     * Let's assume the following words are considered swear words.
     *
     * - poop
     * - fudge
     * - heck
     *
     * The following table lists expected results from counting the number of
     * swear words present in a string.
     *
     * Given       | Then
     * ----------- | ----
     * Poop        | 0
     * poopy       | 0
     * fUdGe       | 0
     * fudgeheck   | 0
     * fud geh eck | 1
     *             | 1
     *
     * In all cases, the points possible should be exactly 1.
     */
    @isTest
    private static void checkSwearWords() {
        
        // Given
        System.assertEquals(true, DataQualityUtil.getSwearWordSet().contains('poop'));
        System.assertEquals(true, DataQualityUtil.getSwearWordSet().contains('fudge'));
        System.assertEquals(true, DataQualityUtil.getSwearWordSet().contains('heck'));
        
        System.assertEquals(false, DataQualityUtil.getSwearWordSet().contains('cow'));
        
        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'Poop' => 0,
            'poopy' => 0,
            'fUdGe' => 0,
            'fudgeheck' => 0,
            'fud geh eck' => 1,
            null => 1
        };
        
        // When
        Test.startTest();
        
        Map<String, DataQuality.CheckResult> actualMap =
                new Map<String, DataQuality.CheckResult>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    new ContainsSwearCheck().process(eachString));
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