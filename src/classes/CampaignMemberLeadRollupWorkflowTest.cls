/**
 * While there isn't a LeadRollupCampaignsWorkflow per se, this class is
 * intended to separate a large number of tests aimed solely to verify
 * that campaign history rollups are being calculated correctly.
 *
 * For efficency all rollups are calculated in a single job.
 */
@isTest
private class CampaignMemberLeadRollupWorkflowTest {

    @testSetup
    private static void setup() {

        // Create campaigns
        Campaign newspaperAd = new Campaign(
                Name = 'Newspaper Ad (TEST)',
                StartDate = Date.today().addDays(-21));

        Campaign billboardAd = new Campaign(
                Name = 'Billboard Ad (TEST)',
                StartDate = Date.today().addDays(-14));

        Campaign radioAd = new Campaign(
                Name = 'Radio Ad (TEST)',
                StartDate = Date.today().addDays(-7));

        Campaign tvAd = new Campaign(
                Name = 'TV Ad (TEST)',
                StartDate = Date.today());

        insert new List<Campaign> { newspaperAd, billboardAd, radioAd , tvAd };

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

        List<Lead> leads = new List<Lead> {
            bugs,
            daffy,
            elmer,
            tweety,
            tas,
            sylvester,
            porky,
            marvin
        };

        insert leads;

        // Tweak the Last Opened Date on the leads
        for (Lead eachLead : leads) {
            eachLead.LastOpenedDate__c = Date.today().addDays(-2);
        }

        update leads;

        // Create tasks
        CampaignMember daffyBillboardAd = new CampaignMember(
                CampaignId = billboardAd.Id,
                LeadId = daffy.Id);

        CampaignMember elmerRadioAd = new CampaignMember(
                CampaignId = radioAd.Id,
                LeadId = elmer.Id);

        CampaignMember tweetyBillboardAd = new CampaignMember(
                CampaignId = billboardAd.Id,
                LeadId = tweety.Id);

        CampaignMember tweetyTvAd = new CampaignMember(
                CampaignId = tvAd.Id,
                LeadId = tweety.Id);

        CampaignMember tasNewspaperAd = new CampaignMember(
                CampaignId = newspaperAd.Id,
                LeadId = tas.Id);

        CampaignMember sylvesterNewspaperAd = new CampaignMember(
                CampaignId = newspaperAd.Id,
                LeadId = sylvester.Id);

        CampaignMember sylvesterBillboardAd = new CampaignMember(
                CampaignId = billboardAd.Id,
                LeadId = sylvester.Id);

        CampaignMember porkyNewspaperAd = new CampaignMember(
                CampaignId = newspaperAd.Id,
                LeadId = porky.Id);

        CampaignMember porkyRadioAd = new CampaignMember(
                CampaignId = radioAd.Id,
                LeadId = porky.Id);

        CampaignMember marvinNewspaperAd = new CampaignMember(
                CampaignId = newspaperAd.Id,
                LeadId = marvin.Id);

        CampaignMember marvinBillboardAd = new CampaignMember(
                CampaignId = billboardAd.Id,
                LeadId = marvin.Id);

        CampaignMember marvinTvAd = new CampaignMember(
                CampaignId = tvAd.Id,
                LeadId = marvin.Id);

        insert new List<CampaignMember> {
            daffyBillboardAd,
            elmerRadioAd,
            tweetyBillboardAd,
            tweetyTvAd,
            tasNewspaperAd,
            sylvesterNewspaperAd,
            sylvesterBillboardAd,
            porkyNewspaperAd,
            porkyRadioAd,
            marvinNewspaperAd,
            marvinBillboardAd,
            marvinTvAd
        };

        for (CampaignMember eachMember : new List<CampaignMember> {
            tasNewspaperAd,
            sylvesterNewspaperAd,
            porkyNewspaperAd,
            marvinNewspaperAd
        }) {
            Test.setCreatedDate(eachMember.Id, DateTime.now().addDays(-18));
        }

        for (CampaignMember eachMember : new List<CampaignMember> {
            daffyBillboardAd,
            tweetyBillboardAd,
            sylvesterBillboardAd,
            marvinBillboardAd
        }) {
            Test.setCreatedDate(eachMember.Id, DateTime.now().addDays(-11));
        }

        for (CampaignMember eachMember : new List<CampaignMember> {
            elmerRadioAd,
            porkyRadioAd
        }) {
            Test.setCreatedDate(eachMember.Id, DateTime.now().addDays(-4));
        }
    }

    /**
     * GIVEN ...
     *
     * - An open lead Elmer with no campaign history
     *
     * WHEN the lead is added to the Radio Ad campaign
     * THEN ...
     *
     * - The lead's First Campaign will be Radio Ad
     * - The lead's Last Campaign will be Radio Ad
     */
    @IsTest
    private static void addLeadToFirstCampaign() {

        // Validate the given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead bugs = [
            SELECT Id,
                FirstCampaign__c,
                MostRecentCampaign__c, (
                SELECT Id, CreatedDate
                FROM CampaignMembers
                ORDER BY CreatedDate DESC
            )
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(0, bugs.CampaignMembers.size(), 'CampaignMembers.size()');
        System.assertEquals(null, bugs.FirstCampaign__c,
                Schema.SObjectType.Lead.fields.FirstCampaign__c.label);
        System.assertEquals(null, bugs.MostRecentCampaign__c,
                Schema.SObjectType.Lead.fields.MostRecentCampaign__c.label);

        // Do the when
        Test.startTest();

        insert new CampaignMember(
                CampaignId = radioAd.Id,
                LeadId = bugs.Id);

        // Validate the then
        Test.stopTest();

        bugs = [
            SELECT Id, FirstCampaign__c, MostRecentCampaign__c, (
                SELECT Id, CreatedDate
                FROM CampaignMembers
                ORDER BY CreatedDate DESC
            )
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(1, bugs.CampaignMembers.size(), 'CampaignMembers.size()');
        System.assertEquals(radioAd.Id, bugs.FirstCampaign__c,
                Schema.SObjectType.Lead.fields.FirstCampaign__c.label);
        System.assertEquals(radioAd.Id, bugs.MostRecentCampaign__c,
                Schema.SObjectType.Lead.fields.MostRecentCampaign__c.label);
    }
}