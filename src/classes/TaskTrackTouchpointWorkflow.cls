public with sharing class TaskTrackTouchpointWorkflow extends AbstractSobjectWorkflow {

    private Map<Id, Lead> leadsById { get; set; }

    private Set<Id> whoIdSet { get; set; }

    public TaskTrackTouchpointWorkflow() {
        this.whoIdSet = null;
        this.leadsById = null;
    }

    public override void executeAfter() {
        /*if (this.records.size() > 0) {
            // Initialize a list of leads for which touchpoints should be
            // tracked (i.e., recalculated)
            Map<Id, Lead> leadMap = new Map<Id, Lead>();
            // Plan to request touchpoints to be recalculated for leads
            for (Task eachTask : (List<Task>)this.records) {
                if (!leadMap.containsKey(eachTask.WhoId)) {
                    leadMap.put(eachTask.WhoId, new Lead(
                            Id = eachTask.WhoId,
                            TrackTouchpointsJobStatus__c = AsyncJobUtil.REQUESTED_STATUS));
                }
            }
            // Update the affected leads
            update leadMap.values();
        }*/
        if (this.records.size() > 0) {
            Map<Id, Lead> newLeadMap = new Map<Id, Lead>();
            // Plan to request touchpoints to be recalculated for leads
            for (Task eachTask : (List<Task>)this.records) {
                if (!newLeadMap.containsKey(eachTask.WhoId)) {
                    newLeadMap.put(eachTask.WhoId, new Lead(
                            Id = eachTask.WhoId));
                }
                List<Lead> records = new List<Lead>();
                for (Id eachId : newLeadMap.keySet()) {
                    records.add(new Lead(Id = eachId));
                }
                DatabaseUtil.updateAllowSave(
                PlatformLeadService.getInstance().rollup(records));
            }
        }
    }

    public override void executeBefore() {
        /* do nothing */
    }

    public override String getClassName() {
        return TaskTrackTouchpointWorkflow.class.getName();
    }

    private Lead getLead(Id recordId) {
        return this.getLeadsById().get(recordId);
    }

    private Map<Id, Lead> getLeadsById() {
        if (this.leadsById == null) {
            this.leadsById = new Map<Id, Lead>([
                SELECT Id, TrackTouchpointsJobStatus__c
                FROM Lead
                WHERE Id IN :this.getWhoIdSet()
            ]);
        }

        return this.leadsById;
    }

    private Set<Id> getWhoIdSet() {
        if (this.whoIdSet == null) {
            this.whoIdSet = new Set<Id>();
            for (Task eachTask : (List<Task>)(Trigger.isDelete ? Trigger.old : Trigger.new)) {
                if (eachTask.WhoId != null) {
                    this.whoIdSet.add(eachTask.WhoId);
                }
            }
        }

        return this.whoIdSet;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Boolean qualified = true;

        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            qualified = this.qualifyLead((Task)newRecord);
        }
        else if (Trigger.isDelete) {
            qualified = this.qualifyLead((Task)oldRecord);
        }

        return qualified;
    }

    /**
     * Given a Task record, check to see whether it's related to a lead for
     * which a touchpoint calculation job can be enqueued.
     */
    public Boolean qualifyLead(Task record) {
        Boolean qualified = false;

        // The record may not actually be related to a lead. If we can't find
        // the lead, then obviously the record fails qualification.
        Lead who = this.getLead(record.WhoId);

        if (who != null) {
            //qualified = who.TrackTouchpointsJobStatus__c
            //        != AsyncJobUtil.ENQUEUED_STATUS;
             qualified = true;
        }

        return qualified;
    }
}