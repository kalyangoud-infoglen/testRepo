@isTest
private class LeadMergeJobTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    /**
     * To cover exception handling in `AbstractProfiledAsyncJob`, enqueue a
     * job to merge the same lead with itself.
     */
    @isTest
    private static void mergeSameLead() {

        // Validate the given
        Lead bugs = [
            SELECT Id
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        Lead daffy = [
            SELECT Id
            FROM Lead
            WHERE LastName = 'Duck (TEST)'
        ];

        List<ProcessEvent__c> events = [
            SELECT Id, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadMergeJob.class.getName()
        ];

        System.assertEquals(0, events.size(),
                'No merge job events should have been logged');

        // Do the when
        Test.startTest();

        List<List<Id>> duplicateIdSets = new List<List<Id>> {
            new List<Id> { bugs.Id, bugs.Id }
        };

        System.enqueueJob(new LeadMergeJob(duplicateIdSets));

        // Validate the then
        Test.stopTest();

        events = [
            SELECT Id, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadMergeJob.class.getName()
            
        ];

        System.assertEquals(1, events.size(),
                'One error event should have been logged');
        System.assertEquals('ERROR', events[0].Result__c,
                Schema.SObjectType.ProcessEvent__c.fields.Result__c.label);
    }

    /**
     * Maked sure Close/Nurture lead is reopened after merge
     */
    @isTest
    private static void mergeClosedLead() {

        // Validate the given
        Campaign tvAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'TV Ad (TEST)' limit 1
        ];

        Campaign billboardAd = [
            SELECT Id
            FROM Campaign 
            WHERE Name = 'Billboard Ad (TEST)'
        ];

        Lead bugs = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        Lead daffy = [
            SELECT Id, Status, ClosedReason__c
            FROM Lead
            WHERE LastName = 'Duck (TEST)'
        ];

        CampaignMember daffyBillboardAd = new CampaignMember(
            CampaignId =billboardAd.Id,
            LeadId = daffy.Id
        );

        CampaignMember bugsTvAd = new CampaignMember(
            CampaignId =tvAd.Id,
            LeadId = bugs.Id
        );

        insert new List<CampaignMember> { bugsTvAd, daffyBillboardAd };

        bugs.Status = 'Close';
        bugs.ClosedReason__c = 'Language Barrier';
        bugs.Country = 'United States'; 
        bugs.Title = 'Lead Bunny';
        bugs.Phone = '919-555-5555';
        update bugs;

        daffy.Phone = '919-555-1234';
        update daffy;

        

        List<ProcessEvent__c> events = [
            SELECT Id, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadMergeJob.class.getName()
        ];

        System.assertEquals(0, events.size(),
                'No merge job events should have been logged');
        System.assertEquals('Close', bugs.Status,
                'Before merge Status of target lead should be "Close"');

        // Do the when
        Test.startTest();

        List<List<Id>> duplicateIdSets = new List<List<Id>> {
            new List<Id> { bugs.Id, daffy.Id }
        };

        System.enqueueJob(new LeadMergeJob(duplicateIdSets));

        // Validate the then
        Test.stopTest();

        events = [
            SELECT Id, Result__c
            FROM ProcessEvent__c
            WHERE ProcessName__c = :LeadMergeJob.class.getName()
            
        ];

        System.assertEquals(1, events.size(),
                'One success event should have been logged');
        System.assertEquals('SUCCESS', events[0].Result__c,
                Schema.SObjectType.ProcessEvent__c.fields.Result__c.label);

        bugs = [
            SELECT Id, Status
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals('Not Started', bugs.Status,
                'After merge Status of target lead should be "Not Started"');
    }
}