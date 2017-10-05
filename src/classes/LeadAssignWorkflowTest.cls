@isTest
private class LeadAssignWorkflowTest {

    @testSetup
    private static void setup() {
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        TestUtil.setup();
    }

    /**
     * Create a new lead as if lead was created by web form submission.
     * Emulate the setting of a bad Infer score, and then make sure the lead
     * is assigned correctly by the assignment rule.
     */
    @isTest
    private static void createJunkLeadThenSetInferScore() {

        // Given
        Group junkScrubQueue = [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = 'JunkScrub'
        ];
        
        Group leadServiceProcessing = [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Queue'
                AND Name = 'Lead Service Processing'
        ];

        Lead wile = [
            SELECT Id, AssignJobStatus__c, JunkScrubStatus__c,
                JunkScrubAssignJobStatus__c, ResolutionJobStatus__c,
                Name, OwnerId, Status
            FROM Lead
            WHERE LastName = 'Coyote (TEST)'
        ];

        System.assertEquals('Not Started', wile.Status,
                Schema.SObjectType.Lead.fields.Status.label);
        System.assertEquals(junkScrubQueue.Id, wile.OwnerId,
                wile.Name + ' should be owned by ' + junkScrubQueue.Name);
        
        System.assertEquals(AsyncJobUtil.REQUESTED_STATUS, wile.JunkScrubAssignJobStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(AsyncJobUtil.NOT_STARTED_STATUS, wile.AssignJobStatus__c,
                Schema.SObjectType.Lead.fields.AssignJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, wile.ResolutionJobStatus__c,
                Schema.SObjectType.Lead.fields.ResolutionJobStatus__c.label);

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        infer3__Score_Object__c inferScore = new infer3__Score_Object__c(
                infer3__Score_1__c = '010',
                infer3__Score_2__c = '100');

        insert new List<infer3__Score_Object__c> { inferScore };

        update new Lead(Id = wile.Id,
                LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                infer3__Score_Index__c = 85,
                infer3__Score_Object_ID__c = inferScore.Id);

        // Then
        Test.stopTest();

        Group autoClosed = [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Queue'
                AND Name = 'Auto-Closed'
        ];

        wile = [
            SELECT Id,
                AssignJobStatus__c,
                DataQualityScore__c,
                InferScore2__c,
                JunkScrubStatus__c,
                JunkScrubAssignJobStatus__c,
                Name,
                OwnerId,
                SearchNetsuiteJobStatus__c,
                Status
            FROM Lead
            WHERE LastName = 'Coyote (TEST)'
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, wile.JunkScrubAssignJobStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubAssignJobStatus__c.label);
        System.assertEquals(10.0, wile.InferScore2__c,
                Schema.SObjectType.Lead.fields.InferScore2__c.label);
        System.assertEquals('Close', wile.Status,
                Schema.SObjectType.Lead.fields.Status.label);

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, wile.SearchNetsuiteJobStatus__c,
                Schema.SObjectType.Lead.fields.SearchNetsuiteJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, wile.AssignJobStatus__c,
                Schema.SObjectType.Lead.fields.AssignJobStatus__c.label);
        System.assertEquals(autoClosed.Id, wile.OwnerId,
                wile.Name + ' should be finally be assigned to ' + autoClosed.Name);
    }

    /**
     * Create a new lead as if lead was created by web form submission.
     * Emulate the setting of an Infer score, and then make sure the lead
     * is assigned correctly by the assignment rule.
     *
     * TODO: Figure out why this is failing even though this same sequence
     *       of events results in a correctly assigned lead when manually
     *       performed in Salesforce. Then enable this test.
     */
    private static void createLeadThenSetInferScore() {

        // Given
        System.assert([
            SELECT Id FROM ProcessEvent__c
        ].size() > 0, 'COUNT(Process Event) > 0');

        System.assertEquals(0, [
            SELECT Id FROM ProcessEvent__c WHERE Result__c = 'ERROR'
        ].size(), 'COUNT(Process Event errors)');

        Group junkScrubQueue = [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = 'JunkScrub'
        ];

        Group leadServiceProcessing = [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Queue'
                AND Name = 'Lead Service Processing'
        ];

        Lead marshall = [
            SELECT Id,
                AssignJobStatus__c,
                DataQualityScore__c,
                InferScore2__c,
                JunkScrubStatus__c,
                LicenseKeyJobStatus__c,
                MergeJobStatus__c,
                Name,
                OwnerId,
                ResolutionJobStatus__c,
                RestrictedPartyJobStatus__c,
                SearchNetsuiteJobStatus__c,
                Status                
            FROM Lead
            WHERE LastName = 'Mathers (TEST)'
        ];

        System.assertEquals(junkScrubQueue.Id, marshall.OwnerId,
                marshall.Name + ' should be owned by ' + junkScrubQueue.Name);

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.RestrictedPartyJobStatus__c,
                Schema.SObjectType.Lead.fields.RestrictedPartyJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.LicenseKeyJobStatus__c,
                Schema.SObjectType.Lead.fields.LicenseKeyJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.NOT_STARTED_STATUS, marshall.MergeJobStatus__c,
                Schema.SObjectType.Lead.fields.MergeJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.NOT_STARTED_STATUS, marshall.SearchNetsuiteJobStatus__c,
                Schema.SObjectType.Lead.fields.SearchNetsuiteJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.REQUESTED_STATUS, marshall.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(AsyncJobUtil.NOT_STARTED_STATUS, marshall.AssignJobStatus__c,
                Schema.SObjectType.Lead.fields.AssignJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.ResolutionJobStatus__c,
                Schema.SObjectType.Lead.fields.ResolutionJobStatus__c.label);

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();
        System.debug('TEST_STARTED');

        infer3__Score_Object__c inferScore = new infer3__Score_Object__c(
                infer3__Score_1__c = '000',
                infer3__Score_2__c = '100');

        insert new List<infer3__Score_Object__c> { inferScore };

        update new Lead(Id = marshall.Id,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
                infer3__Score_Index__c = 170,
                infer3__Score_Object_ID__c = inferScore.Id);

        // Then
        Test.stopTest();
        System.debug('TEST_STOPPED');

        Group unassignableQueue = [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = 'Unassignable'
        ];

        marshall = [
            SELECT Id,
                AssignJobStatus__c,
                DataQualityScore__c,
                InferScore2__c,
                JunkScrubStatus__c,
                LicenseKeyJobStatus__c,
                MergeJobStatus__c,
                Name,
                OwnerId,
                ResolutionJobStatus__c,
                RestrictedPartyJobStatus__c,
                SearchNetsuiteJobStatus__c,
                Status
            FROM Lead
            WHERE LastName = 'Mathers (TEST)'
        ];

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.RestrictedPartyJobStatus__c,
                Schema.SObjectType.Lead.fields.RestrictedPartyJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.LicenseKeyJobStatus__c,
                Schema.SObjectType.Lead.fields.LicenseKeyJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.MergeJobStatus__c,
                Schema.SObjectType.Lead.fields.MergeJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.SearchNetsuiteJobStatus__c,
                Schema.SObjectType.Lead.fields.SearchNetsuiteJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, marshall.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, marshall.AssignJobStatus__c,
                Schema.SObjectType.Lead.fields.AssignJobStatus__c.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, marshall.ResolutionJobStatus__c,
                Schema.SObjectType.Lead.fields.ResolutionJobStatus__c.label);

        System.assertEquals(100.0, marshall.InferScore2__c,
                Schema.SObjectType.Lead.fields.InferScore2__c.label);
        System.assertEquals('Not Started', marshall.Status,
                Schema.SObjectType.Lead.fields.Status.label);
        System.assertEquals(unassignableQueue.Id, marshall.OwnerId,
                marshall.Name + ' should be finally be assigned to ' + unassignableQueue.Name);
    }

    /**
     * Create a new lead with Country set to United States, but without
     * requesting to assign the lead using the active assignment rule.
     * The lead should remain owned by the user who created the lead.
     */
    @isTest
    private static void insertNorthAmericaLeadDoNotAssign() {

        // Do the when
        Test.startTest();

        Lead yosemite = new Lead(
                FirstName = 'Yosemite',
                LastName = 'Sam (TEST)',
                Company = 'Acme Corporation (TEST)',
                Country = 'United States',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        insert yosemite;

        // Validate the then
        Test.stopTest();

        yosemite = [
            SELECT Id, OwnerId
            FROM Lead
            WHERE LastName = 'Sam (TEST)'
        ];

        System.assertEquals(UserInfo.getUserId(), yosemite.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * Create a new lead with Country set to United States, and do request
     * to assign the lead using the active assignment rule. The lead should
     * afterward be owned by the North America queue.
     */
    @isTest
    private static void insertNorthAmericaLeadAndAssign() {

        // Do the when
        Test.startTest();

        Lead yosemite = new Lead(
                FirstName = 'Yosemite',
                LastName = 'Sam (TEST)',
                Company = 'Acme Corporation (TEST)',
                Country = 'United States',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Database.DMLOptions options = new Database.DMLOptions();
        options.assignmentRuleHeader.useDefaultRule = true;
        yosemite.setOptions(options);

        insert yosemite;

        // Validate the then
        Test.stopTest();

        yosemite = [
            SELECT Id, OwnerId
            FROM Lead
            WHERE LastName = 'Sam (TEST)'
        ];

        Group northAmerica = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND Name = 'North America'
        ];

        System.assertEquals(northAmerica.Id, yosemite.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * Update a lead with Country set to United States, where the lead was
     * previously assigned to user, and request to assign the lead using the
     * active assignment rule. The lead should then be owned by
     * the North America queue.
     */
    @isTest
    private static void updateNorthAmericaLeadAndAssign() {

        // Validate the given
        Lead bugs = [
            SELECT Id, OwnerId
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(UserInfo.getUserId(), bugs.OwnerId);

        // Do the when
        Test.startTest();

        bugs.Country = 'United States';

        Database.DMLOptions options = new Database.DMLOptions();
        options.assignmentRuleHeader.useDefaultRule = true;
        bugs.setOptions(options);

        update bugs;

        // Validate the then
        Test.stopTest();

        bugs = [
            SELECT Id, OwnerId
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        Group northAmerica = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND Name = 'North America'
        ];

        System.assertEquals(northAmerica.Id, bugs.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);

    }

    /**
     * Create an unassignable lead, and assuming that the active assignment
     * rule will at the very end assign a lead to the Unassignable queue,
     * verify that running the LeadAssignJob for this lead will result
     * in the lead being assigned to the Unassignable queue.
     */
    @isTest
    private static void assignLeadToUnassignableQueue() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        // Find the queue
        Group unassignable = [
            SELECT Id
            FROM Group
            WHERE Name = 'Unassignable' AND Type = 'Queue'
        ];

        // Find the lead
        Lead bugs = [
            SELECT Id, OwnerId,
                CountryCode,
                MergeJobStatus__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        // Validate test conditions
        System.assertNotEquals(unassignable.Id, bugs.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals(null, bugs.CountryCode,
                Schema.SObjectType.Lead.fields.CountryCode.label);
        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, bugs.MergeJobStatus__c,
                Schema.SObjectType.Lead.fields.MergeJobStatus__c.label);

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadAssignJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        // Run the test
        Test.startTest();

        bugs = new Lead(Id = bugs.Id);

        Database.DMLOptions options = new Database.DMLOptions();
        options.assignmentRuleHeader.useDefaultRule = true;
        bugs.setOptions(options);

        update bugs;

        // Stop the test
        Test.stopTest();

        // Validate expected outcomes
        bugs = [
            SELECT Id, OwnerId, AssignJobStatus__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, bugs.AssignJobStatus__c,
                Schema.SObjectType.Lead.fields.AssignJobStatus__c.label);
        System.assertEquals(unassignable.Id, bugs.OwnerId,
                'Lead should be assigned to Unassignable queue');

        List<ProcessEvent__c> events = [
            SELECT Id, Message__c, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadAssignJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ];

        System.assertEquals(1, events.size());
        System.assertEquals(null, events[0].Message__c,
                Schema.SObjectType.ProcessEvent__c.fields.Message__c.label);
        System.assertEquals('SUCCESS', events[0].Result__c,
                Schema.SObjectType.ProcessEvent__c.fields.Message__c.label);
    }
}