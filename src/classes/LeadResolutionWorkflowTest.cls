/**
 * This class provides unit tests for LeadResolutionJob and LeadResolutionWorkflow
 */
@isTest
private class LeadResolutionWorkflowTest {

    /**
     * Create a test lead and call out to the mock service. Check
     * to see that the expected ProcessEvent record is created.
     */
    @isTest
    private static void createClosedLead() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            NetsuiteCampaignInternalId__c = '121212'
        );
        insert testCampaign;

        // Create the lead
        Lead daffy = new Lead(
            FirstName = 'Test', 
            LastName = 'Lead1', 
            Street = '123 Any St',
            City = 'Springfield',
            Country = 'United States',
            PostalCode = '12345',
            Description = 'Test lead',
            Title = 'Senior Test', 
            Email = 'test@example.com',
            Phone = '800-555-1212', 
            Company = 'Test Corp', 
            LeadSource = 'Other', 
            LrpSid__c = '1234567890',
            RemoteIp__c = '10.1.1.1',
            Industry = 'Business',
            CompanyDunsNumber = '12345',
            AccessCode__c = '123XYZ',
            InferScore__c = 10.0,
            JobLevel__c = null,
            Status = 'Close',
            ClosedReason__c = 'Nurture',
            NetsuiteContactId__c = null,
            NetsuiteCustomerId__c = null,
            MergeJobStatus__c = 'Skipped',
            RestrictedPartyJobStatus__c = 'Skipped',
            LicenseKeyJobStatus__c = 'Skipped',
            ResolutionJobStatus__c = 'Not Started',
            MostRecentCampaign__c = testCampaign.id
        );

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadResolutionJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        Test.setMock(HttpCalloutMock.class, new LeadResolutionServiceMock());

        // Run the test
        Test.startTest();

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;
        Database.SaveResult result = Database.insert(daffy, dmlOptions);
        System.assert(result.isSuccess(), 'Test lead insert failed');

        // Stop the test
        Test.stopTest();

        // Validate expected outcomes
        daffy = [
            SELECT Id, ResolutionJobStatus__c
            FROM Lead
            WHERE Id = :daffy.Id
        ];

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, daffy.ResolutionJobStatus__c,
                Schema.SObjectType.Lead.fields.ResolutionJobStatus__c.label);
    }

    /**
     * GIVEN an open lead
     * WHEN the lead is closed with reason "Nurture"
     * THEN the lead resolution job should be enqueued and executed
     */
    @isTest
    private static void closeOpenLead() {

        // Validate the given
        Lead bugs = [
            SELECT Id, Status, ResolutionJobStatus__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            NetsuiteCampaignInternalId__c = '121212'
        );
        insert testCampaign;

        CampaignMember testCampaignMember = new CampaignMember(
            LeadId = bugs.Id,
            CampaignId = testCampaign.Id 
        );
        insert testCampaignMember;

        bugs.MostRecentCampaign__c = testCampaign.id;
        update bugs;

        System.assertEquals('Not Started', bugs.Status,
                Schema.SObjectType.Lead.fields.Status.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, bugs.ResolutionJobStatus__c,
                Schema.SObjectType.Lead.fields.ResolutionJobStatus__c.label);

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadResolutionServiceMock());
        Test.startTest();

        update new Lead(Id = bugs.Id,
                Status = 'Close',
                ClosedReason__c = 'Nurture',
                Phone = '919-555-5555');
        
        // Validate the then
        Test.stopTest();

        bugs = [
            SELECT Id, Status, ClosedReason__c, ResolutionJobStatus__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals('Close', bugs.Status,
                Schema.SObjectType.Lead.fields.Status.label);
        System.assertEquals('Nurture', bugs.ClosedReason__c,
                Schema.SObjectType.Lead.fields.ClosedReason__c.label);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, bugs.ResolutionJobStatus__c,
                Schema.SObjectType.Lead.fields.ResolutionJobStatus__c.label);
    }

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }
}