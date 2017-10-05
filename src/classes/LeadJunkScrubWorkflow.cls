public class LeadJunkScrubWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {
 
        // Gather a list of the record IDs for leads to scrub
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.JunkScrubStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadJunkScrubJob(recordIds));
        }
    }

    public override void executeBefore() {

        // Go through every lead, and skip junk scrub if there/s
        // or requested.
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stampEnqueued(eachLead, Schema.Lead.JunkScrubStatus__c);
        }
    }

    public override String getClassName() {
        return LeadJunkScrubWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;

        // Only execute on request. This way manually created leads by default
        // skip junk scrub, and leads created by code can explicitly request
        // junk scrub to execute.
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.REQUESTED_STATUS.equals(newLead.JunkScrubStatus__c)
                && newLead.MostRecentCampaign__c != null
                && Limits.getQueueableJobs() == 0;
    }
}