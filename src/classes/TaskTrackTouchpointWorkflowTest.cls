@isTest
private class TaskTrackTouchpointWorkflowTest {

    /**
     * GIVEN an open lead without any activity history,
     * WHEN an open call task is created for the lead,
     * THEN the number of touchpoints should still be 0
     */
    @isTest
    private static void openFirstTouchpointForNewLead() {

        // Validate the given
        Lead bugs = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(0, bugs.Tasks.size(), 'Tasks.size()');
        System.assertEquals(0, bugs.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, bugs.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = bugs.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.OPEN_STATUS);

        // Validate the then
        Test.stopTest();

        bugs = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(1, bugs.Tasks.size(), 'Tasks.size()');
        System.assertEquals(0, bugs.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, bugs.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }
    
    /**
     * GIVEN an open lead with one open call task,
     * WHEN the open call task is closed,
     * THEN ...
     *
     * - Num Touchpoints should be incremented to 1
     * - Num Current Touchpoints should be incremented to 1
     */
    @isTest
    private static void closeFirstTouchpointForNewLead() {

        // Validate the given
        Lead daffy = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id, Status FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Duck (TEST)'
        ];

        System.assertEquals(1, daffy.Tasks.size(), 'Tasks.size()');
        System.assertEquals('Open', daffy.Tasks[0].Status,
                Schema.SObjectType.Task.fields.Status.label);

        System.assertEquals(0, daffy.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, daffy.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        update new Task(
                Id = daffy.Tasks[0].Id,
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        daffy = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,

                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Duck (TEST)'
        ];

        System.assertEquals(1, daffy.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, daffy.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, daffy.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }
    
    /**
     * GIVEN an open lead without any activity history,
     * WHEN a closed call task is created for the lead,
     * THEN ...
     *
     * - Num Touchpoints should be incremented to 1
     * - Num Current Touchpoints should be incremented to 1
     */
    @isTest
    private static void logClosedFirstTouchpointForNewLead() {

        // Validate the given
        Lead bugs = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(0, bugs.Tasks.size(), 'Tasks.size()');
        System.assertEquals(0, bugs.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, bugs.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = bugs.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        bugs = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(1, bugs.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, bugs.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, bugs.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - no historical touchpoints
     * - one closed current touchpoint
     *
     * WHEN the closed current touchpoint is deleted,
     * THEN ...
     *
     * - Num Touchpoints should become 0
     * - Num Current Touchpoints should become 0
     */
    @isTest
    private static void deleteFirstTouchpointForNewLead() {

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

        // Do the when
        Test.startTest();

        delete elmer.Tasks[0];

        // Validate the then
        Test.stopTest();

        elmer = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,

                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Fudd (TEST)'
        ];

        System.assertEquals(0, elmer.Tasks.size(), 'Tasks.size()');
        System.assertEquals(0, elmer.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, elmer.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - no historical touchpoints
     * - one closed current touchpoint
     *
     * WHEN the closed current touchpoint is deleted and undeleted,
     * THEN ...
     *
     * - Num Touchpoints should remain 1
     * - Num Current Touchpoints should remain 1
     */
    @isTest
    private static void undeleteFirstTouchpointForNewLead() {

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

        // Do the when
        Test.startTest();

        delete elmer.Tasks[0];
        undelete elmer.Tasks[0];

        // Validate the then
        Test.stopTest();

        elmer = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Fudd (TEST)'
        ];

        System.assertEquals(1, elmer.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, elmer.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, elmer.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with one closed touchpoint,
     * WHEN a second open call task is created for the lead,
     * THEN the number of touchpoints should still be 1
     */
    @isTest
    private static void openSecondTouchpointForNewLead() {

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

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = elmer.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.OPEN_STATUS);

        // Validate the then
        Test.stopTest();

        elmer = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Fudd (TEST)'
        ];

        System.assertEquals(2, elmer.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, elmer.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, elmer.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with one completed call task and one open call task,
     * WHEN the open call task is closed,
     * THEN ...
     *
     * - Num Touchpoints should be incremented to 2
     * - Num Current Touchpoints should be incremented to 2
     */
    @isTest
    private static void closeSecondTouchpointForNewLead() {

        // Validate the given
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

        update new Task(
                Id = tweety.Tasks[0].Id,
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        tweety = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Bird (TEST)'
        ];

        System.assertEquals(2, tweety.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, tweety.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(2, tweety.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }
    
    /**
     * GIVEN an open lead with one closed touchpoint,
     * WHEN a second closed call task is created for the lead,
     * THEN ...
     *
     * - Num Touchpoints should be incremented to 2
     * - Num Current Touchpoints should be incremented to 2
     */
    @isTest
    private static void logClosedSecondTouchpointForNewLead() {

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

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = elmer.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        elmer = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Fudd (TEST)'
        ];

        System.assertEquals(2, elmer.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, elmer.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(2, elmer.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN a reopened lead with ...
     * 
     * - 1 historical, completed call task
     * - No current activity history
     *
     * WHEN an open call task is created for the lead,
     * THEN ...
     *
     * - Num Touchpoints should still be 1
     * - Num Current Touchpoints should still be 0
     */
    @isTest
    private static void openFirstTouchpointForReopenedLead() {

        // Validate the given
        Lead tas = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Devil (TEST)'
        ];

        System.assertEquals(1, tas.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, tas.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, tas.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = tas.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.OPEN_STATUS);

        // Validate the then
        Test.stopTest();

        tas = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Devil (TEST)'
        ];

        System.assertEquals(2, tas.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, tas.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, tas.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN a reopened lead with ...
     * 
     * - 1 historical, completed call task
     * - 1 open call task
     *
     * WHEN the open call task is closed,
     * THEN ...
     *
     * - Num Touchpoints should be incremented to 2
     * - Num Current Touchpoints should be incremented to 1
     */
    @isTest
    private static void closeFirstTouchpointForReopenedLead() {

        // Validate the given
        Lead sylvester = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id, Status FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pussycat (TEST)'
        ];

        System.assertEquals(2, sylvester.Tasks.size(), 'Tasks.size()');
        System.assertEquals('Open', sylvester.Tasks[0].Status,
                Schema.SObjectType.Task.fields.Status.label);

        System.assertEquals(1, sylvester.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, sylvester.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        update new Task(
                Id = sylvester.Tasks[0].Id,
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        sylvester = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pussycat (TEST)'
        ];

        System.assertEquals(2, sylvester.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, sylvester.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, sylvester.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }
    
    /**
     * GIVEN a reopened lead with ...
     * 
     * - 1 historical, completed call task
     * - No current activity history
     *
     * WHEN an completed call task is created for the lead,
     * THEN ...
     *
     * - Num Touchpoints should be incremented to 2
     * - Num Current Touchpoints should be incremented to 1
     */
    @isTest
    private static void logClosedFirstTouchpointForReopenedLead() {

        // Validate the given
        Lead tas = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Devil (TEST)'
        ];

        System.assertEquals(1, tas.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, tas.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, tas.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = tas.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        tas = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Devil (TEST)'
        ];

        System.assertEquals(2, tas.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, tas.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, tas.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - one historical touchpoint
     * - one closed current touchpoint
     *
     * WHEN the closed current touchpoint is deleted,
     * THEN ...
     *
     * - Num Touchpoints should become 1
     * - Num Current Touchpoints should become 0
     */
    @isTest
    private static void deleteFirstTouchpointForReopenedLead() {

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

        // Do the when
        Test.startTest();

        delete porky.Tasks[0];

        // Validate the then
        Test.stopTest();

        porky = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pig (TEST)'
        ];

        System.assertEquals(1, porky.Tasks.size(), 'Tasks.size()');
        System.assertEquals(1, porky.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, porky.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - one historical touchpoint
     * - one closed current touchpoint
     *
     * WHEN the closed current touchpoint is deleted and undeleted,
     * THEN ...
     *
     * - Num Touchpoints should remain 2
     * - Num Current Touchpoints should remain 1
     */
    @isTest
    private static void undeleteFirstTouchpointForReopenedLead() {

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

        // Do the when
        Test.startTest();

        delete porky.Tasks[0];
        undelete porky.Tasks[0];

        // Validate the then
        Test.stopTest();

        porky = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pig (TEST)'
        ];

        System.assertEquals(2, porky.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, porky.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, porky.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - one historical touchpoint
     * - one closed current touchpoint
     *
     * WHEN another open call task is created for the lead,
     * THEN ...
     *
     * - Num Touchpoints should remain as 2
     * - Num Current Touchpoints should remain as 1
     */
    @isTest
    private static void openSecondTouchpointForReopenedLead() {

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

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = porky.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.OPEN_STATUS);

        // Validate the then
        Test.stopTest();

        porky = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pig (TEST)'
        ];

        System.assertEquals(3, porky.Tasks.size(), 'Tasks.size()');

        System.assertEquals(2, porky.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, porky.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - one historical touchpoint
     * - one closed current touchpoint
     * - one open current call task
     *
     * WHEN the open call task is completed,
     * THEN ...
     *
     * - Num Touchpoints should become 3
     * - Num Current Touchpoints should become 2
     */
    @isTest
    private static void closeSecondTouchpointForReopenedLead() {

        // Validate the given
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

        update new Task(
                Id = marvin.Tasks[0].Id,
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        marvin = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'the Martian (TEST)'
        ];

        System.assertEquals(3, marvin.Tasks.size(), 'Tasks.size()');
        System.assertEquals(3, marvin.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(2, marvin.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    /**
     * GIVEN an open lead with ...
     * 
     * - one historical touchpoint
     * - one closed current touchpoint
     *
     * WHEN another completed call task is created for the lead,
     * THEN ...
     *
     * - Num Touchpoints should now be 3
     * - Num Current Touchpoints should now be 2
     */
    @isTest
    private static void logClosedSecondTouchpointForReopenedLead() {

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

        // Do the when
        Test.startTest();

        insert new Task(
                WhoId = porky.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(1),
                Status = TaskUtil.COMPLETED_STATUS);

        // Validate the then
        Test.stopTest();

        porky = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Pig (TEST)'
        ];

        System.assertEquals(3, porky.Tasks.size(), 'Tasks.size()');
        System.assertEquals(3, porky.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(2, porky.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    @isTest
    private static void reopenPreviouslyClosedLead() {

        // Validate the given
        Lead foghorn = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                LastOpenedDate__c, Status, ClosedReason__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Rooster (TEST)'
        ];

        System.assertEquals('Close', foghorn.Status,
                Schema.SObjectType.Lead.fields.Status.label);
        System.assertEquals('Nurture', foghorn.ClosedReason__c,
                Schema.SObjectType.Lead.fields.ClosedReason__c.label);
        System.assertEquals(2, foghorn.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, foghorn.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(1, foghorn.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);

        // Do the when
        Test.startTest();

        foghorn.Status = 'In Progress';
        foghorn.ClosedReason__c = null;
        foghorn.NurtureDetails__c = null; 
        update foghorn;

        Test.stopTest();

        foghorn = [
            SELECT Id, NumberOfTouchpoints__c, NumberOfCurrentTouchpoints__c,
                Status, ClosedReason__c,
                (SELECT Id FROM Tasks ORDER BY ActivityDate DESC)
            FROM Lead
            WHERE LastName = 'Rooster (TEST)'
        ];
        System.assertEquals('In Progress', foghorn.Status,
                Schema.SObjectType.Lead.fields.Status.label);
        System.assertEquals(null, foghorn.ClosedReason__c,
                Schema.SObjectType.Lead.fields.ClosedReason__c.label);
        System.assertEquals(2, foghorn.Tasks.size(), 'Tasks.size()');
        System.assertEquals(2, foghorn.NumberOfTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfTouchpoints__c.label);
        System.assertEquals(0, foghorn.NumberOfCurrentTouchpoints__c,
                Schema.SObjectType.Lead.fields.NumberOfCurrentTouchpoints__c.label);
    }

    @testSetup
    private static void setup() {

        // Create leads
        Lead bugs = new Lead(
                FirstName = 'Bugs',
                LastName = 'Bunny (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'bugs@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead daffy = new Lead(
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'daffy@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead elmer = new Lead(
                FirstName = 'Elmer',
                LastName = 'Fudd (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'elmer@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead tweety = new Lead(
                FirstName = 'Tweety',
                LastName = 'Bird (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'tweety@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead tas = new Lead(
                FirstName = 'Tasmanian',
                LastName = 'Devil (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'tas@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead sylvester = new Lead(
                FirstName = 'Sylvester',
                LastName = 'Pussycat (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'sylvester@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead porky = new Lead(
                FirstName = 'Porky',
                LastName = 'Pig (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'porky@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead marvin = new Lead(
                FirstName = 'Marvin',
                LastName = 'the Martian (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'marvin@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead foghorn = new Lead(
                FirstName = 'Foghorn',
                LastName = 'Rooster (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'foghorn@acme.test',
                Phone = '6173936348',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        List<Lead> leads = new List<Lead> {
            bugs,
            daffy,
            elmer,
            tweety,
            tas,
            sylvester,
            porky,
            marvin,
            foghorn
        };

        insert leads;

        // Tweak the Last Opened Date on the leads
        for (Lead eachLead : leads) {
            eachLead.LastOpenedDate__c = Date.today().addDays(-2); 
        }

        update leads;

        // Create test Campaign
        Campaign tvAd = new Campaign(
                Name = 'TV Ad (TEST)',
                StartDate = Date.today());

        insert new List<Campaign> { tvAd };
        // Crate CampaignMember
        CampaignMember foghornTvAd = new CampaignMember(
                CampaignId = tvAd.Id,
                LeadId = foghorn.Id);

        insert foghornTvAd;

        Lead foghornLead = [Select id FROM Lead WHERE Name = 'Foghorn Rooster (TEST)'];
            foghornLead.Status = 'Close';
            foghornLead.ClosedReason__c = 'Nurture';
            foghornLead.NurtureDetails__c = 'Timing'; 

        update foghornLead;

        // Create tasks
        Task foghornFirstClosedTouchpoint = new Task(
                WhoId = foghorn.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-3),
                Status = TaskUtil.COMPLETED_STATUS);

        Task foghornSecondClosedTouchpoint = new Task(
                WhoId = foghorn.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.COMPLETED_STATUS);

        Task daffyFirstOpenTouchpoint = new Task(
                WhoId = daffy.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        Task elmerFirstClosedTouchpoint = new Task(
                WhoId = elmer.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task tweetyFirstClosedTouchpoint = new Task(
                WhoId = tweety.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task tweetySecondOpenTouchpoint = new Task(
                WhoId = tweety.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        Task tasHistoricClosedTouchpoint = new Task(
                WhoId = tas.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task sylvesterHistoricClosedTouchpoint = new Task(
                WhoId = sylvester.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task sylvesterFirstOpenTouchpoint = new Task(
                WhoId = sylvester.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        Task porkyHistoricClosedTouchpoint = new Task(
                WhoId = porky.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task porkyFirstClosedTouchpoint = new Task(
                WhoId = porky.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task marvinHistoricClosedTouchpoint = new Task(
                WhoId = marvin.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task marvinFirstClosedTouchpoint = new Task(
                WhoId = marvin.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task marvinSecondOpenTouchpoint = new Task(
                WhoId = marvin.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        insert new List<Task> {
            daffyFirstOpenTouchpoint,
            elmerFirstClosedTouchpoint,
            tweetyFirstClosedTouchpoint,
            tweetySecondOpenTouchpoint,
            tasHistoricClosedTouchpoint,
            sylvesterHistoricClosedTouchpoint,
            sylvesterFirstOpenTouchpoint,
            porkyHistoricClosedTouchpoint,
            porkyFirstClosedTouchpoint,
            marvinHistoricClosedTouchpoint,
            marvinFirstClosedTouchpoint,
            marvinSecondOpenTouchpoint,
            foghornFirstClosedTouchpoint,
            foghornSecondClosedTouchpoint
        };
    }
}