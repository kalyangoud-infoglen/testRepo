@isTest
private class DataQualityUtilTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    /**
     * Test the cleaning of special characters
     *
     * Given     | Then
     * --------- | ---------
     * Marty     | Marty
     * brett     | Brett
     * john paul | John paul
     * !@#$      | !@#$
     */
    @isTest
    private static void cleanProperCase() {

        // Validate the given
        String martyIn = 'Marty';
        String brettIn = 'brett';
        String jpIn = 'john paul';
        String swearIn = '!@#$';
        String nullIn = null;

        // Do the when
        Test.startTest();

        String martyOut = DataQualityUtil.cleanProperCase(martyIn);
        String brettOut = DataQualityUtil.cleanProperCase(brettIn);
        String jpOut = DataQualityUtil.cleanProperCase(jpIn);
        String swearOut = DataQualityUtil.cleanProperCase(swearIn);
        String nullOut = DataQualityUtil.cleanProperCase(nullIn);

        // Validate the then
        Test.stopTest();

        System.assertEquals('Marty', martyOut);
        System.assertEquals('Brett', brettOut);
        System.assertEquals('John paul', jpOut);
        System.assertEquals('!@#$', swearOut);
        System.assertEquals(null, nullOut);
    }

    /**
     * Test the cleaning of special characters
     *
     * Given                                    | Then
     * ---------------------------------------- | ---------------
     * special ~!@#$%^&*()_+{}|:"<>?`-=[]\;',./ | special &()_+-/
     * M@$terpiec3                              | Mterpiec3
     * Rapid Seven                              | Rapid Seven
     */
    @isTest
    private static void cleanSpecialChars() {

        // Validate the given
        String specialIn = 'special ~!@#$%^&*()_+{}|:"<>?`-=[]\\;\',./';
        String masterpieceIn = 'M@$terpiec3';
        String rapid7In = 'Rapid Seven';
        String nullIn = null;

        // Do the when
        Test.startTest();

        String specialOut = DataQualityUtil.cleanSpecialChars(specialIn);
        String masterpieceOut = DataQualityUtil.cleanSpecialChars(masterpieceIn);
        String rapid7Out = DataQualityUtil.cleanSpecialChars(rapid7In);
        String nullOut = DataQualityUtil.cleanSpecialChars(nullIn);

        // Validate the then
        Test.stopTest();

        System.assertEquals('special &()_+-/', specialOut);
        System.assertEquals('Mterpiec3', masterpieceOut);
        System.assertEquals('Rapid Seven', rapid7Out);
        System.assertEquals(null, nullOut);
    }
    
    /**
     * Test our ability to correctly count the number of alphabet characters
     * in a string
     *
     * Given               | Then
     * ------------------- | ----
     * a                   | 1
     * !@#$                | 0
     * Rapid7              | 5
     * Thi$ 2 shall p@ss   | 11
     * George R. R. Martin | 14
     *                     | 0
     */
    @isTest
    private static void countAlphaChars() {
        
        // Given
        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'a' => 1,
            '!@#$' => 0,
            'Rapid7' => 5,
            'Thi$ 2 shall p@ss' => 11,
            'George R. R. Martin' => 14,
            null => 0
        };
        
        // When
        Test.startTest();
        
        Map<String, Integer> actualMap = new Map<String, Integer>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    DataQualityUtil.countAlphaChars(eachString));
        }
        
        // Then
        Test.stopTest();
        
        for (String eachString : expectedMap.keySet()) {
            System.assertEquals(
                    expectedMap.get(eachString),
                    actualMap.get(eachString),
                    'count: ' + eachString);
        }
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
     * Poop        | 1
     * poopy       | 1
     * fUdGe       | 1
     * fudgeheck   | 2
     * fud geh eck | 0
     *             | 0
     */
    @isTest
    private static void countSwearWords() {

        // Given
        System.assertEquals(true, DataQualityUtil.getSwearWordSet().contains('poop'));
        System.assertEquals(true, DataQualityUtil.getSwearWordSet().contains('fudge'));
        System.assertEquals(true, DataQualityUtil.getSwearWordSet().contains('heck'));
        
        System.assertEquals(false, DataQualityUtil.getSwearWordSet().contains('cow'));

        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'Poop' => 1,
            'poopy' => 1,
            'fUdGe' => 1,
            'fudgeheck' => 2,
            'fud geh eck' => 0,
            null => 0
        };

        // When
        Test.startTest();
        
        Map<String, Integer> actualMap = new Map<String, Integer>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    DataQualityUtil.countSwearWords(eachString));
        }
        
        // Then
        Test.stopTest();
        
        for (String eachString : expectedMap.keySet()) {
            System.assertEquals(
                    expectedMap.get(eachString),
                    actualMap.get(eachString),
                    'count: ' + eachString);
        }
    }
    
    /**
     * Test our ability to correctly count the number of alphabet characters
     * in a string
     *
     * Given               | Then
     * ------------------- | ----
     * a                   | 1
     * !@#$                | 0
     * Rapid7              | 2
     * Thi$ 2 shall p@ss   | 2
     * George R. R. Martin | 5
     * Angry Birds         | 3
     *                     | 0
     */
    @isTest
    private static void countVowelChars() {
        
        // Given
        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'a' => 1,
            '!@#$' => 0,
            'Rapid7' => 2,
            'Thi$ 2 shall p@ss' => 2,
            'George R. R. Martin' => 5,
            'Angry Birds' => 3,
            null => 0
        };
        
        // When
        Test.startTest();
        
        Map<String, Integer> actualMap = new Map<String, Integer>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    DataQualityUtil.countVowelChars(eachString));
        }
        
        // Then
        Test.stopTest();
        
        for (String eachString : expectedMap.keySet()) {
            System.assertEquals(
                    expectedMap.get(eachString),
                    actualMap.get(eachString),
                    'count: ' + eachString);
        }
    }
}