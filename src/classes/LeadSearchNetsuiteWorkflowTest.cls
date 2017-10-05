@isTest
private class LeadSearchNetsuiteWorkflowTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    @isTest
    private static void processLeadWithCompanyDunsNumber() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        Lead shinya = new Lead(
                FirstName = 'Shinya',
                LastName = 'Higuma (TEST)',
                Company = 'Nagano Prefecture (TEST)',
                Email = 'higuma-shinya-r@pref.naganolg.jp');

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadSearchNetsuiteJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        // Run the test
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        insert shinya;

        // Stop the test
        Test.stopTest();
        
        // Validate process event
        List<ProcessEvent__c> events = [
            SELECT Id, Message__c, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadSearchNetsuiteJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ];

        System.assertEquals(1, events.size());
        System.assertEquals(null, events[0].Message__c);
        System.assertEquals('SUCCESS', events[0].Result__c);

        // Validate expected outcomes
        shinya = [
            SELECT Id, OwnerId,
                NetsuiteCustomerId__c,
                NetsuiteContactId__c,
                NetsuiteOpportunities__c,
                SearchNetsuiteJobStatus__c
            FROM Lead
            WHERE LastName = 'Higuma (TEST)'
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, shinya.SearchNetsuiteJobStatus__c,
                Schema.SObjectType.Lead.fields.SearchNetsuiteJobStatus__c.label);
        System.assertEquals('110282269', shinya.NetsuiteContactId__c,
                Schema.SObjectType.Lead.fields.NetsuiteContactId__c.label);
        System.assertEquals('110281368', shinya.NetsuiteCustomerId__c,
                Schema.SObjectType.Lead.fields.NetsuiteCustomerId__c.label);
        System.assertEquals(String.join(
                new List<String> {
                    'UP138961',
                    'UP144679',
                    'UP144893'
                }, '; '), shinya.NetsuiteOpportunities__c,
                Schema.SObjectType.Lead.fields.NetsuiteOpportunities__c.label);
    }

    @isTest
    private static void processLeadWithoutCompanyDunsNumber() {

        // Define params for the test
        DateTime startTime = DateTime.now();

        Lead shinya = new Lead(
                FirstName = 'Shinya',
                LastName = 'Higuma (TEST)',
                Company = 'Nagano Prefecture (TEST)');

        // Make sure no process events logged yet
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadSearchNetsuiteJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size());

        // Run the test
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        insert shinya;

        // Stop the test
        Test.stopTest();
        
        // Validate process event
        List<ProcessEvent__c> events = [
            SELECT Id, Message__c, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadSearchNetsuiteJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ];

        System.assertEquals(0, events.size());

        // Validate expected outcomes
        shinya = [
            SELECT Id, OwnerId, SearchNetsuiteJobStatus__c
            FROM Lead
            WHERE LastName = 'Higuma (TEST)'
        ];

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, shinya.SearchNetsuiteJobStatus__c,
                Schema.SObjectType.Lead.fields.SearchNetsuiteJobStatus__c.label);
        
        System.assertEquals(0, [
            SELECT Id, StartTime__c, EndTime__c, ExecutionTime__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadSearchNetsuiteJob.class.getName()
            AND StartTime__c >= :startTime.getTime()
        ].size(), 'Job should not have been enqueued');
    }

    /**
     * The Search Netsuite Job should be able to process two leads at once,
     * without encountering the "You have uncommitted work pending" error.
     *
     * - Given two leads with Lead Status "Not Started";
     * - When a single `update` sets Search NetSuite Job Status to "Requested"
     *   for both leads;
     * - Then the `LeadSearchNetsuiteJob` should finish successfully, as
     *   reflected in the single Process Event record and also in the
     *   Search NetSuite Job Status field for both leads
     *
     * @see PHX-1635
     */
    @isTest
    private static void processTwoLeadsWithoutCompanyDunsNumber() {

        // Given ...
        Long startTime = DateTime.now().getTime();

        Lead bugs = [
            SELECT Id, Status
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
            AND Status = 'Not Started'
        ];

        Lead daffy = [
            SELECT Id, Status
            FROM Lead
            WHERE LastName = 'Duck (TEST)'
            AND Status = 'Not Started'
        ];

        System.assertEquals(0, [
            SELECT Id
            FROM ProcessEvent__c
            WHERE StartTime__c >= :startTime
        ].size(), 'COUNT(Process Event) should be 0 to start');

        // When ...
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        bugs.SearchNetsuiteJobStatus__c = AsyncJobUtil.REQUESTED_STATUS;
        daffy.SearchNetsuiteJobStatus__c = AsyncJobUtil.REQUESTED_STATUS;

        update new List<Lead> { bugs, daffy };

        // Then ...
        Test.stopTest();

        List<ProcessEvent__c> events = [
            SELECT Id, Result__c, Message__c
            FROM ProcessEvent__c
            WHERE StartTime__c >= :startTime
            AND ProcessName__c = :LeadSearchNetsuiteJob.class.getName()
        ];

        System.assertEquals(1, events.size(),
                'COUNT(Process Event) should be 1 at end of test');
        System.assertEquals(null, events[0].Message__c,
                'logged event should have no message');
        System.assertEquals('SUCCESS', events[0].Result__c,
                'logged event should show success');
    }
}