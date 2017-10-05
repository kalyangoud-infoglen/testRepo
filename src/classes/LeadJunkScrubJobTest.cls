/**
 * Class providing functional coverage for scenarios not covered or difficult
 * to cover in other tests.
 *
 * @see LeadjunkScrubWorkflowTest
 */
@isTest
private class LeadJunkScrubJobTest {

    /**
     * This test simply makes sure that the Lead Company & Name Fuzzy Match
     * duplicate rule is working as expected.
     */
    @isTest
    private static void duplicatesDetected() {

        // When
        Test.startTest();

        insert new Lead(
                FirstName = 'Foghorn',
                LastName = 'Leghorn (TEST)',
                Company = 'Acme Corporation (TEST)');

        System.DmlException caught = null;

        try {
            insert new Lead(
                    FirstName = 'Foghorn',
                    LastName = 'Leghorn (TEST)',
                    Company = 'Acme Corporation (TEST)');
        }
        catch (System.DmlException e) {
            caught = e;
        }

        // Then
        Test.stopTest();

        System.assert(caught.getMessage().contains('DUPLICATES_DETECTED'),
                'DUPLICATES_DETECTED should be the error code');
    }
}