/**
 * This class provides unit tests for RequestRestrictedPartyWorkflow
 */
@isTest
private class RequestRestrictedPartyWorkflowTest {

    /**
     * Create a test request and see that the expected ProcessEvent record is created.
     */
    @isTest
    private static void workflowTest() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        // Create the lead
        AmberRoadRequest__c daffy = new AmberRoadRequest__c(
                Name = 'Daffy Duck (TEST)',
                Company__c = 'Acme Corporation (TEST)',
                RestrictedPartyJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS);

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :RequestRestrictedPartyJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock());

        // Run the test
        Test.startTest();

        insert daffy;

        // Stop the test
        Test.stopTest();

        // Validate expected outcomes
        daffy = [
            SELECT Id, RestrictedPartyJobStatus__c
            FROM AmberRoadRequest__c
            WHERE Id = :daffy.Id
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, daffy.RestrictedPartyJobStatus__c,
                Schema.SObjectType.AmberRoadRequest__c.fields.RestrictedPartyJobStatus__c.label);

        List<ProcessEvent__c> events = [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :RequestRestrictedPartyJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ];

        System.assertEquals(1, events.size());
    }
}