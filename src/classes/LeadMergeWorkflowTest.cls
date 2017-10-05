@isTest
private class LeadMergeWorkflowTest {

    /**
     * Create an existing lead and a new lead that qualifies as a duplicate.
     * Verify that the job merges the new lead into the old lead, and that
     * the surviving lead is updated with the new lead's lead source value.
     */
    @isTest
    private static void leadMergeTest() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        Lead testLead2 = new Lead(
            LastName = 'Test2 (TEST)', 
            Email = 'test@example.com', 
            LeadSource = 'Webinar',
            Status = 'Not Started', 
            Company = 'Test Corp B (TEST)'
        );

        // Find the leads
        Lead testLead1 = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, MergeJobStatus__c
            FROM Lead
            WHERE Email = :testLead2.Email
        ];

        // Validate test conditions
        System.assert(testLead1.CreatedDate < startTime,
                'CreatedDate should be in the past');
        System.assertEquals('Test1 (TEST)', testLead1.LastName);
        System.assertEquals('test@example.com', testLead1.Email);
        System.assertEquals(null, testLead1.LeadSource);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, testLead1.MergeJobStatus__c);

        System.assertEquals(testLead1.Email, testLead2.Email);
        System.assertNotEquals(testLead1.LeadSource, testLead2.LeadSource);

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadMergeJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        // Run the test
        Test.startTest();

        // Avoid the DUPLICATES_DETECTED error, "Use one of these records?: []"
        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(testLead2, options);

        // Stop the test
        Test.stopTest();

        // Validate expected outcomes
        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, MergeJobStatus__c
            FROM Lead
            WHERE Email = :testLead2.Email
        ];

        System.assertEquals(1, testLeads.size(), 'Only one lead should exist');
        System.assertEquals(testLead1.Id, testLeads[0].Id,
                'Older lead should have survived');
        System.assertEquals(testLead1.LastName, testLeads[0].LastName);
        System.assertEquals(testLead2.LeadSource, testLeads[0].LeadSource, 
                'Lead should have survived and been updated with victims Lead Source value');
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].MergeJobStatus__c);

        // Validate expected process event logging
        List<ProcessEvent__c> events = [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c,
                Result__c, Message__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadMergeJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ];

        System.assertEquals(1, events.size());
        System.assertEquals(null, events[0].Message__c);
        System.assertEquals('SUCCESS', events[0].Result__c);
    }
//////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadReopenClosedNutrureTest() {
        //set existing Lead to Close - Nurture status 
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Test Campaign'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd };

        bugs.Status = 'Close';
        bugs.ClosedReason__c = 'Nurture';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        bugs.MergeJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS;   
        update bugs;

        Lead getBugs = [
            SELECT Id, Status, ClosedReason__c, MergeJobStatus__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals('Close', getBugs.Status);
        System.assertEquals('Nurture', getBugs.ClosedReason__c);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, getBugs.MergeJobStatus__c);

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead hacker = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-234-2345',
                Email = 'bugs@acme.test',
                RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(hacker, options);

        // Then
        Test.stopTest();

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                Status, MergeJobStatus__c
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].MergeJobStatus__c);
        System.assertEquals(1, testLeads.size(), 'Only one lead should exist');
        System.assertEquals('Not Started', testLeads[0].Status);
    }
//////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadNewClosedTest() {
        //set existing Lead to Close - Nurture status 
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Test Campaign'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c, Email
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd };

        bugs.Status = 'Close';
        bugs.ClosedReason__c = 'Language Barrier';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        update bugs;

        System.assertEquals('Close', bugs.Status);
        System.assertEquals('Language Barrier', bugs.ClosedReason__c);
        System.assertEquals('bugs@acme.test', bugs.Email);

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                FirstName, MergeJobStatus__c, Status
            FROM Lead
            WHERE Email = :bugs.Email
        ];

        System.assertEquals(1, testLeads.size(), 'only one lead should exist');

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead hacker = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-234-2345',
                Email = 'bugs@acme.test',
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(hacker, options);

        // Then
        Test.stopTest();

        testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                FirstName, MergeJobStatus__c, Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals(1, testLeads.size(), 'only one lead should exist');
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].MergeJobStatus__c);
        System.assertNotEquals('Close', testLeads[0].Status);
    }

//////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadCloseOppMatchTest() {
        //set existing Lead to Close - Nurture status 
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Test Campaign'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd };

        bugs.Status = 'Close';
        bugs.ClosedReason__c = 'Opportunity Match';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        update bugs;

        System.assertEquals('Close', bugs.Status);
        System.assertEquals('Opportunity Match', bugs.ClosedReason__c);

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead hacker = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-234-2345',
                Email = 'bugs@acme.test',
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(hacker, options);

        // Then
        Test.stopTest();

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                FirstName, MergeJobStatus__c, Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals(2, testLeads.size(), 'two leads should exist');
        System.assertEquals('Bugzy', testLeads[1].FirstName);
        System.assertNotEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[1].MergeJobStatus__c);
        System.assertEquals('Close', testLeads[0].Status);
    }

//////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadCompleteInSalesforceTest() {
        //set existing Lead to Close - Nurture status 
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Test Campaign'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd };

        bugs.Status = 'CompleteInSalesforce';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        bugs.MergeJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS; 
        update bugs;

        System.assertEquals('CompleteInSalesforce', bugs.Status);

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead hacker = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-234-2345',
                Email = 'bugs@acme.test',
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(hacker, options);

        // Then
        Test.stopTest();

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                FirstName, MergeJobStatus__c, Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals(2, testLeads.size(), 'two leads should exist');
        System.assertEquals('Bugzy', testLeads[1].FirstName);
        System.assertNotEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[1].MergeJobStatus__c);
        System.assertEquals('CompleteInSalesforce', testLeads[0].Status);
    }

    //////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadReopenInactiveOwnerTest() {
        //set existing Lead to Close - Nurture status 
        User getuser = [
            SELECT Id, isActive
            FROM User
            WHERE email = 'test@cp.com.test'
        ];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            getuser.isActive = false;
            update getuser;
        }
        

        Set<String> emailSet = new Set<String>{'inactiveLead@example.com'};
        Lead getLead = [
            SELECT Email, Status, ClosedReason__c, MergeJobStatus__c
            FROM Lead
            WHERE Email IN :emailSet
            AND (Status IN :LeadContext.OPEN_STATUS_SET
                    OR (Status = 'Close' AND ClosedReason__c IN :LeadContext.REOPEN_CLOSEREASON_SET))
        ];

        System.assertEquals('Close', getLead.Status);
        System.assertEquals('Nurture', getLead.ClosedReason__c);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, getLead.MergeJobStatus__c);
        System.assertEquals(false, getuser.isActive);

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead newLead = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Test Corp A (TEST)',
                Phone = '617-234-2345',
                Email = 'inactiveLead@example.com',
                LeadSource = 'Website',
                RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        options.assignmentRuleHeader.useDefaultRule = false;

        Database.SaveResult result = Database.insert(newLead, options);
        System.assertEquals(true, result.isSuccess());

        // Then
        Test.stopTest();

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                Status, MergeJobStatus__c, OwnerId, AssignJobStatus__c, 
                JunkScrubAssignJobStatus__c, JunkScrubStatus__c
            FROM Lead
            WHERE Email = :newLead.Email
        ];

        System.assertEquals(getLead.id, testLeads[0].id);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].MergeJobStatus__c);
        System.assertEquals(1, testLeads.size(), 'Only one lead should exist');
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].AssignJobStatus__c);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, testLeads[0].JunkScrubAssignJobStatus__c);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, testLeads[0].JunkScrubStatus__c);
        System.assertNotEquals(getuser.id, testLeads[0].OwnerId);
        System.assertEquals('Not Started', testLeads[0].Status);

    }

    //////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadReopenClosed30DaysTest() {
        //set existing Lead to Close - Nurture status 
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Test Campaign'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd };

        bugs.Status = 'Close';
        bugs.ClosedReason__c = 'Nurture';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        bugs.MergeJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS;   
        update bugs;

        bugs.LastClosedDate__c = DateTime.now().addDays(-70);
        update bugs;

        Lead getBugs = [
            SELECT Id, Status, ClosedReason__c, MergeJobStatus__c, WeekdaysCloseDuration__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals('Close', getBugs.Status);
        System.assertEquals('Nurture', getBugs.ClosedReason__c);
        System.assertEquals(70, getBugs.WeekdaysCloseDuration__c);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, getBugs.MergeJobStatus__c);

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead hacker = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-234-2345',
                Email = 'bugs@acme.test',
                RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(hacker, options);

        // Then
        Test.stopTest();

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                Status, MergeJobStatus__c, AssignJobStatus__c, LastClosedDate__c,
                WeekdaysCloseDuration__c
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals(bugs.id, testLeads[0].id);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].MergeJobStatus__c);
        System.assertEquals(1, testLeads.size(), 'Only one lead should exist');
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].AssignJobStatus__c);
        System.assertEquals(null, testLeads[0].LastClosedDate__c);
        System.assertEquals('Not Started', testLeads[0].Status);
    }

    //////////////////////////////////////////////////////////////////////////////////
    @isTest
    private static void leadReopenClosedDifferentProductTest() {
        //set existing Lead to Close - Nurture status 
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Test Campaign'
        ];

        Campaign insightOpsAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Test Campaign (InsightOps)'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd };

        bugs.Status = 'Close';
        bugs.ClosedReason__c = 'Nurture';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        bugs.MergeJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS;   
        update bugs;

        Lead getBugs = [
            SELECT Id, Status, ClosedReason__c, MergeJobStatus__c, MostRecentCampaign__r.ProductFamily__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals('Close', getBugs.Status);
        System.assertEquals('Nurture', getBugs.ClosedReason__c);
        System.assertEquals('Other', getBugs.MostRecentCampaign__r.ProductFamily__c);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, getBugs.MergeJobStatus__c);

        //Add new Lead with the same email address as currently existing Lead 
        //according to Merge logic two Leads will be merged together

        Lead hacker = new Lead(
                FirstName = 'Bugzy',
                LastName = 'bee',
                Title = 'COO',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-234-2345',
                Email = 'bugs@acme.test',
                RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                JunkScrubAssignJobStatus__c = AsyncJobUtil.ERROR_STATUS,
                JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );

        Test.startTest();

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        Database.insert(hacker, options);

        CampaignMember hackerInsightOpsAd = new CampaignMember(
            CampaignId = insightOpsAd.Id,
            LeadId = hacker.Id
        );
        insert hackerInsightOpsAd;

        // set the prerequisite status so merge can run
        hacker.JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        Database.update(hacker, options);

        // Then
        Test.stopTest();

        List<Lead> testLeads = [
            SELECT Id, CreatedDate, Email, LastName, LeadSource, 
                Status, MergeJobStatus__c, AssignJobStatus__c, LastClosedDate__c,
                MostRecentCampaign__r.ProductFamily__c, PreviousCampaign__r.ProductFamily__c
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals(bugs.id, testLeads[0].id);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].MergeJobStatus__c);
        System.assertEquals(1, testLeads.size(), 'Only one lead should exist');
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, testLeads[0].AssignJobStatus__c);
        System.assertEquals('Other', testLeads[0].PreviousCampaign__r.ProductFamily__c);
        System.assertEquals('InsightOps', testLeads[0].MostRecentCampaign__r.ProductFamily__c);
        System.assertEquals(null, testLeads[0].LastClosedDate__c);
        System.assertEquals('Not Started', testLeads[0].Status);
    }
    //////////////////////////////////////////////////////////////////////////////////

    @testSetup
    private static void setup() {

        insert new List<DaysClosedThreshold__c> {
            new DaysClosedThreshold__c(DaysSinceClosed__c = 30)
        };

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;

        //Get test user from the sustem who is active and is a BDR
        //Then update that users email, we will need that in Test classes 
        Id BRDProfile = [Select Id from Profile where name = 'R7 Sales BDR User'].Id;

        User getuser = [
                Select Id, Email 
                FROM User 
                WHERE ProfileId =:BRDProfile AND isActive = true LIMIT 1
        ];

        getuser.email = 'test@cp.com.test';
        update getuser;

        Lead inactiveLead = new Lead(
            LastName = 'Mike (TEST)', Email = 'inactiveLead@example.com', LeadSource = null,
            Status = 'Not Started', Company = 'Test Corp A (TEST)',
            Phone = '919-555-5555', OwnerId = getuser.id,
            Country = 'United States', Title = 'Lead Bunny',
            MergeJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS
            );

        Lead testLead1 = new Lead(
            LastName = 'Test1 (TEST)', Email = 'test@example.com', LeadSource = null,
            Status = 'Not Started', Company = 'Test Corp A (TEST)',
            RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
            SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS
            );

        Lead bugs = new Lead(
                FirstName = 'Bugs',
                LastName = 'Bunny (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'bugs@acme.test',
                CountryCode = null,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);


        Database.insert(inactiveLead , dmlOptions);
        Database.insert(testLead1 , dmlOptions);
        Database.insert(bugs , dmlOptions);


        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            NetsuiteCampaignInternalId__c = '121212',
            ProductFamily__c = 'Other'
        );
        insert testCampaign;

        Campaign testCampaign1 = new Campaign(
            Name = 'Test Campaign (InsightOps)',
            NetsuiteCampaignInternalId__c = '131313',
            ProductFamily__c = 'InsightOps'
        );
        insert testCampaign1;

        CampaignMember testCampaignMember1 = new CampaignMember(
            LeadId = inactiveLead.Id,
            CampaignId = testCampaign.Id 
        );
        insert testCampaignMember1;

        OauthCredential__c credential = new OauthCredential__c(
            Name = 'LEAD_SEARCH_SERVICE',
            Realm__c = 'Test', 
            ConsumerKey__c = 'Test', 
            ConsumerSecret__c = 'Test', 
            Token__c = 'Test', 
            TokenSecret__c = 'Test'
        );
        insert credential;

        Lead inactiveLeadUpdate = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE Email = 'inactiveLead@example.com'
        ];

        inactiveLeadUpdate.Status = 'Close';
        inactiveLeadUpdate.ClosedReason__c = 'Nurture';

        update inactiveLeadUpdate; 

         Lead testMyLead = [
            SELECT Id, Status, ClosedReason__c, MostRecentCampaign__c
            FROM Lead
            WHERE Email = 'inactiveLead@example.com'
        ];

        System.assertNotEquals(null, testMyLead.MostRecentCampaign__c);
        System.assertEquals('Close', testMyLead.Status);
    }
}