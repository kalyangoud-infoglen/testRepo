@isTest
private class LeadTrackTouchpointsWorkflowTest {
  /*
    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    /**
     * GIVEN ...
     *
     * - An open new lead with one closed touchpoint
     * - Another open new lead with one closed touchpoint
     *
     * WHEN the two leads are merged,
     * THEN ...
     *
     * - The master lead's Num Touchpoints will be 2
     * - The master lead's Num Current Touchpoints will be 2
     
    @IsTest
    private static void mergeNewLeads() {

        // Validate the given
        Lead elmer = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                LastOpenedDate__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Fudd (TEST)'
        ];

        System.assertEquals(1, elmer.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, elmer.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, elmer.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        Lead tweety = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id, Status FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Bird (TEST)'
        ];

        System.assertEquals(2, tweety.Tasks.size(), 'Tasks.size()');
        System.assertEquals('Open', tweety.Tasks[0].Status,
                Schema.SObjectType.Task.fields.Status.label);

        System.assertEquals(1, tweety.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, tweety.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        MergeService service = new MergeService(Schema.SObjectType.Lead.name);
        service.mergeMany(new List<Id> { elmer.Id, tweety.Id });

        // Validate the then
        Test.stopTest();

        elmer = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                LastOpenedDate__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Fudd (TEST)'
        ];

        System.assertEquals(3, elmer.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, elmer.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(2, elmer.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN ...
     *
     * - A reopened lead with one closed touchpoint
     * - Another reopened lead with one closed touchpoint
     *
     * WHEN the two leads are merged,
     * THEN ...
     *
     * - The master lead's Num Touchpoints will be 4
     * - The master lead's Num Current Touchpoints will be 2
     
    @isTest
    private static void mergeReopenedLeads() {

        // Validate the given
        Lead porky = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                LastOpenedDate__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pig (TEST)'
        ];

        System.assertEquals(2, porky.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, porky.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, porky.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        Lead marvin = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id, Status FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'the Martian (TEST)'
        ];

        System.assertEquals(3, marvin.Tasks.size(), 'Tasks.size()');
        System.assertEquals('Open', marvin.Tasks[0].Status,
                Schema.SObjectType.Task.fields.Status.label);

        System.assertEquals(2, marvin.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, marvin.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        MergeService service = new MergeService(Schema.SObjectType.Lead.name);
        service.mergeMany(new List<Id> { porky.Id, marvin.Id });

        // Validate the then
        Test.stopTest();

        porky = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                LastOpenedDate__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pig (TEST)'
        ];

        System.assertEquals(5, porky.Tasks.size(), 'Tasks.size()');
        System.assertEquals(4, porky.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(2, porky.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }
    */
}