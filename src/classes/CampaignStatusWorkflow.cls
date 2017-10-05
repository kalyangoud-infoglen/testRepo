public with sharing class CampaignStatusWorkflow extends AbstractSobjectWorkflow {

    public CampaignStatusWorkflow () {
    }
    
    public static final String Camp_Type_ABD    = 'Account Based Marketing';
    public static final String Clicked_Status   = 'Clicked';
    public static final String Open_Status      = 'Open';
    
    public override void executeAfter() {
        List<CampaignMemberStatus> campaignsMemberStatusToBeAdded = new List<CampaignMemberStatus>();
        Set<Id> campaignIdSet = new Set<Id>();
        List<String> campStatusList = getCampaignStatus();
        for (Campaign cmprecord : (List<Campaign>)this.records) {
            if(!campaignIdSet.contains(cmprecord.Id)) {
                for(String status : campStatusList) {
                    CampaignMemberStatus cms = new CampaignMemberStatus();
                    cms.CampaignId = cmprecord.Id;
                    cms.Label = status ;
                    campaignsMemberStatusToBeAdded.add(cms);
                }
                campaignIdSet.add(cmprecord.Id);
            }
        }
        if(!campaignsMemberStatusToBeAdded.isempty()) {
            insertCampaignStatus(campaignsMemberStatusToBeAdded);
        }
    }
    
    private void insertCampaignStatus(List<CampaignMemberStatus> campaignsMemberStatusList) {
        if(!campaignsMemberStatusList.isempty()) {
            insert campaignsMemberStatusList;
        }
    }
    
    private List<String> getCampaignStatus() {
        List<String> campStatusList = new List<String>();
            campStatusList.add(Clicked_Status);
            campStatusList.add(Open_Status);
        return campStatusList;
    }
    
    public override void executeBefore() {
        /* do nothing */
    }

    public override String getClassName() {
        return CampaignStatusWorkflow.class.getName();
    }


    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Boolean qualified = true;
        if (Trigger.isInsert) {
            qualified = this.qualifyCampaign((Campaign)newRecord);
        }
        else {
            qualified = false;
        }
        return qualified;
    }
    
    private Boolean qualifyCampaign(Campaign cmpRecord) {
        Boolean qualified = false;
        if(cmpRecord.Type == Camp_Type_ABD) {
            qualified = true;
        }
        return qualified;
    }

}