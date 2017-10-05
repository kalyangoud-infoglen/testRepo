@isTest
private class EmailDomainCheckTest {
    
    /**
     * Test our ability to correctly award points based on a given string
     * as an email address.
     *
     * In all cases, the points possible should be exactly 1.
     *
     * Given               | Then
     * ------------------- | ----
     * bugs                | 0
     * bugs@gmail.com      | 1
     * bugs@slalom.com     | 1
     * bugs@no.mail.servce | 0
     */
    @isTest
    private static void validateEmails() {
        
        // Given
        Map<String, Integer> expectedMap = new Map<String, Integer> {
            'bugs' => 0,
            'bugs@gmail.com' => 1,
            'bugs@slalom.com' => 1,
            'bugs@no.mail.server' => 0
        };
        
        // When
        Test.setMock(HttpCalloutMock.class, new MetasploitServiceMock());
        Test.startTest();
        
        Map<String, DataQuality.CheckResult> actualMap =
                new Map<String, DataQuality.CheckResult>();
        
        for (String eachString : expectedMap.keySet()) {
            actualMap.put(eachString,
                    new EmailDomainCheck().process(eachString));
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