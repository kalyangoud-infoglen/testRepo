/**
 * This class provides unit tests for LeadLicenseKeyJob
 */
@isTest
private class LeadLicenseKeyWorkflowTest {

    /**
     * Create a test lead and call out to the mock service. Check
     * to see that the expected ProcessEvent record is created.
     */
    @isTest
    private static void workflowTest() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        // Find the lead
        Lead daffy = new Lead(
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'daffy@acme.test',
                LeadSource = 'Freemium',
                RestrictedPartyJobStatus__c = AsyncJobUtil.SUCCESS_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS);

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadLicenseKeyJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        Test.setMock(HttpCalloutMock.class, new LeadLicenseKeyServiceMock(200));

        // Run the test
        Test.startTest();

        insert daffy;

        // Stop the test
        Test.stopTest();

        // Validate expected outcomes
        daffy = [
            SELECT Id, LicenseKeyJobStatus__c
            FROM Lead
            WHERE Id = :daffy.Id
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, daffy.LicenseKeyJobStatus__c,
                Schema.SObjectType.Lead.fields.LicenseKeyJobStatus__c.label);

        List<ProcessEvent__c> events = [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadLicenseKeyJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ];

        System.assertEquals(1, events.size());
    }

    @testSetup
    private static void setup() {

        // Create credential
        OauthCredential__c credential = new OauthCredential__c(
            Name = 'LEAD_SEARCH_SERVICE',
            Realm__c = 'Test', 
            ConsumerKey__c = 'Test', 
            ConsumerSecret__c = 'Test', 
            Token__c = 'Test', 
            TokenSecret__c = 'Test'
        );
        insert credential; 
    }
}