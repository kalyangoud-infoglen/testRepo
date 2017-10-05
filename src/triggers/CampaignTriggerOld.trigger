trigger CampaignTriggerOld on Campaign (after insert) 
{
    List<CampaignMemberStatus> campaignsMemberStatusToBeAdded = new List<CampaignMemberStatus>();
    
    for(Campaign cmp: Trigger.new)
    {
        system.debug('inside1:' + Trigger.new);
        if(cmp.Type == 'Account Based Marketing')
        {
            system.debug('inside');
            CampaignMemberStatus cms = new CampaignMemberStatus();
            cms.CampaignId = cmp.Id;
            cms.Label = 'Clicked';
            
            CampaignMemberStatus cms1 = new CampaignMemberStatus();
            cms1.CampaignId = cmp.Id;
            cms1.Label = 'Open';
            
            campaignsMemberStatusToBeAdded.add(cms);
            campaignsMemberStatusToBeAdded.add(cms1);
        }
    }
    
    insert campaignsMemberStatusToBeAdded;
    System.debug('campaignsMemberStatusToBeAdded......'+campaignsMemberStatusToBeAdded);

}