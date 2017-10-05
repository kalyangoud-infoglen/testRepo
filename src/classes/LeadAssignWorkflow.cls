public with sharing class LeadAssignWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {

        // Gather a list of the record IDs for leads to assign
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.AssignJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        // Enqueue the job if we actually have any leads to assign
        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadAssignJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stampEnqueued(eachLead, Schema.Lead.AssignJobStatus__c);
        }
    }

    public override String getClassName() {
        return LeadAssignWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newLead.AssignJobStatus__c)
                && UserUtil.isQueueEquals(UserUtil.LEAD_SERVICE_PROCESSING_QUEUE, newLead.OwnerId)
                && AsyncJobUtil.qualifyPrereqStatus(newLead.SearchNetsuiteJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}