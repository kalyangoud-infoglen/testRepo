public with sharing class LeadRestrictedPartyWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {

        // Gather a list of the record IDs
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.RestrictedPartyJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        // Enqueue the job if we actually have any leads to assign
        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadRestrictedPartyJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stamp(eachLead, Schema.Lead.RestrictedPartyJobStatus__c,
                    eachLead.LeadSource == 'Freemium' 
                    && eachLead.AccessCodeFamily__c != 'Platform'
                            ? AsyncJobUtil.ENQUEUED_STATUS
                            : AsyncJobUtil.SKIPPED_STATUS);
        }
    }

    public override String getClassName() {
        return LeadRestrictedPartyWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newLead.RestrictedPartyJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}