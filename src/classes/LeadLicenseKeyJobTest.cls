@isTest
private class LeadLicenseKeyJobTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    /**
     * To cover the `finishError` method, try deleting a lead before
     * the async job gets to it.
     */
    @isTest
    private static void deleteLeadBeforeJobExecutes() {

        // Validate the given
        Lead bugs = [
            SELECT Id
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        // Do the when
        Test.startTest();

        LeadLicenseKeyJob job = new LeadLicenseKeyJob(new List<Id> { bugs.Id });
        System.enqueueJob(job);
        
        // For fun, use the stampError method just for coverage fun
        delete AsyncJobUtil.stampError(
                new List<Lead> { bugs }, Schema.Lead.LicenseKeyJobStatus__c);
        
        Database.emptyRecycleBin(bugs);

        // Validate the then
        Test.stopTest();

        List<ProcessEvent__c> events = [
            SELECT Id, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadLicenseKeyJob.class.getName()
        ];

        System.assertEquals(1, events.size(),
                'One event should have been logged');
        System.assertEquals('ERROR', events[0].Result__c,
                Schema.SObjectType.ProcessEvent__c.fields.Result__c.label);
    }
}