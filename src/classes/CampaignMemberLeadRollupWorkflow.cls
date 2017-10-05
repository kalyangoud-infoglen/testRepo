public with sharing class CampaignMemberLeadRollupWorkflow extends AbstractSobjectWorkflow {

    private Map<Id, Lead> leadsById { get; set; }

    private Set<Id> leadIdSet { get; set; }

    public CampaignMemberLeadRollupWorkflow() {
        this.leadIdSet = null;
        this.leadsById = null;
    }

    public override void executeAfter() {
        if (this.records.size() > 0) {

            // Initialize a list of leads for which touchpoints should be
            // tracked (i.e., recalculated)
            Map<Id, Lead> leadMap = new Map<Id, Lead>();

            // Plan to request touchpoints to be recalculated for leads
            for (CampaignMember eachCampaignMember : (List<CampaignMember>)this.records) {
                if (!leadMap.containsKey(eachCampaignMember.LeadId)) {
                    leadMap.put(eachCampaignMember.LeadId, new Lead(
                            Id = eachCampaignMember.LeadId
                            ));
                }

                List<Lead> records = new List<Lead>();

                for (Id eachId : leadMap.keySet()) {
                    records.add(new Lead(Id = eachId));
                }

                DatabaseUtil.updateAllowSave(
                PlatformLeadService.getInstance().rollupCampaigns(records));
            }
        }
    }

    public override void executeBefore() {
        /* do nothing */
    }

    public override String getClassName() {
        return CampaignMemberLeadRollupWorkflow.class.getName();
    }

    private Lead getLead(Id recordId) {
        return this.getLeadsById().get(recordId);
    }

    private Map<Id, Lead> getLeadsById() {
        if (this.leadsById == null) {
            this.leadsById = new Map<Id, Lead>([
                SELECT Id
                FROM Lead
                WHERE Id IN :this.getLeadIdSet()
            ]);
        }

        return this.leadsById;
    }

    private Set<Id> getLeadIdSet() {
        if (this.leadIdSet == null) {
            this.leadIdSet = new Set<Id>();
            for (CampaignMember eachCampaignMember : (List<CampaignMember>)(Trigger.isDelete ? Trigger.old : Trigger.new)) {
                if (eachCampaignMember.LeadId != null) {
                    this.leadIdSet.add(eachCampaignMember.LeadId);
                }
            }
        }

        return this.leadIdSet;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Boolean qualified = true;

        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            qualified = this.qualifyLead((CampaignMember)newRecord);
        }
        else if (Trigger.isDelete) {
            qualified = this.qualifyLead((CampaignMember)oldRecord);
        }

        return qualified;
    }

    /**
     * Given a CampaignMember record, check to see whether it's related to a lead for
     * which a touchpoint calculation job can be enqueued.
     */
    public Boolean qualifyLead(CampaignMember record) {
        Boolean qualified = false;

        // The record may not actually be related to a lead. If we can't find
        // the lead, then obviously the record fails qualification.
        Lead who = this.getLead(record.LeadId);

        if (who != null) {
            qualified = true;
        }

        return qualified;
    }
}