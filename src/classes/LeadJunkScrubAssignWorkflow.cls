public class LeadJunkScrubAssignWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {
 
        // Gather a list of the record IDs for leads to assign
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.JunkScrubAssignJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadJunkScrubAssignJob(recordIds));
        }
    }

    public override void executeBefore() {

        // Go through every lead and mark the job enqueued
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stampEnqueued(eachLead, Schema.Lead.JunkScrubAssignJobStatus__c);
        }
    }

    public override String getClassName() {
        return LeadJunkScrubAssignWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;

        // Only execute on request. This way manually created leads by default
        // skip junk scrub assign.
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.REQUESTED_STATUS.equals(newLead.JunkScrubAssignJobStatus__c)
                && AsyncJobUtil.qualifyPrereqStatus(newLead.JunkScrubStatus__c)
                && newLead.MostRecentCampaign__c != null
                && newLead.InferScore2__c != null
                && Limits.getQueueableJobs() == 0;
    }
}