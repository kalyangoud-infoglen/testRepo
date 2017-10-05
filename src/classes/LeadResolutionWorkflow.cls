public with sharing class LeadResolutionWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {

        // Gather a list of the record IDs for leads to send to Netsuite
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.ResolutionJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        // Enqueue the job if we actually have any leads to send
        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadResolutionJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stampEnqueued(eachLead, Schema.Lead.ResolutionJobStatus__c);
        }
    }

    public override String getClassName() {
        return LeadResolutionWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;

        // Previously this trigger workflow was managing whether to skip
        // or to enqueue the job. This logic was simplified by moving the
        // logic to skip the job on creation to a native workflow rule,
        // Set Resolution Job Status.
        return Trigger.isUpdate
                && AsyncJobUtil.qualifyStatus(newLead.ResolutionJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}