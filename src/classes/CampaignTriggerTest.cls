/**
 * This class is meant to test the CampaignTrigger test
 **/
@isTest
private class CampaignTriggerTest 
{
    @testSetup
    private static void setup() 
    {

        // Create campaigns
        Campaign newspaperAd = new Campaign(
                Name = 'Newspaper Ad (TEST)',
                Type = 'Account Based Marketing',
                StartDate = Date.today().addDays(-21));

        insert new List<Campaign>{newspaperAd};
    }

    /**
     * If the Campaign Type is 'Account Based Marketing', then the CampaignMemberStatus records for this
     * campaign get two new status values, 'Clicked', and 'Open'.
     */
    @IsTest
    private static void addLeadToFirstCampaign() 
    {

        Campaign radioAd = [SELECT Id FROM Campaign WHERE Name = 'Newspaper Ad (TEST)'];

        List<CampaignMemberStatus> status_values = [SELECT Id, Label FROM CampaignMemberStatus
                                                    WHERE CampaignId = :radioAd.Id];

        System.assertEquals(2, status_values.size());
        
        Set<String> label_values = new Set<String>{status_values[0].Label, status_values[1].Label};
        System.assertEquals(true, label_values.contains('Clicked'));
        System.assertEquals(true, label_values.contains('Open'));
            
    }
}