@isTest
public class LeadJobsQueuedUpFailTest {

    @isTest
    private static void testOne() {

        // Validate the given
        Lead newLead = new Lead(
                LastName = 'Test Lead' , 
                Company = 'Test Company', 
                JobLevel__c = 'Director', 
                Status = 'In Progress',
                Email = 'jon@chipotle.com',
                SearchNetsuiteJobStatus__c = 'Requested',
                RestrictedPartyJobStatus__c = 'Requested',
                JunkScrubStatus__c = 'Skipped',
                LicenseKeyJobStatus__c = 'Skipped',
                MergeJobStatus__c = 'Skipped',
                ResolutionJobStatus__c = 'Skipped',
                TrackTouchpointsJobStatus__c = 'Skipped',
                AssignJobStatus__c  = 'Skipped'
        );

        insert newLead;

        // Do the when
        Test.startTest();

        Lead newLead2 = [
            SELECT Id
            FROM Lead
            WHERE Email = 'jon@chipotle.com' AND Company = 'Test Company'
        ];

        newLead2.JobLevel__c = 'Student';
        
        update newLead2;
        
        Test.stopTest();

        // Validate the then
        System.assertEquals('Student', newLead2.JobLevel__c);
    } 
}