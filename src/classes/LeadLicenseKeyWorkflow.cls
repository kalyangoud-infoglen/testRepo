public with sharing class LeadLicenseKeyWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {

        // Gather a list of the record IDs for leads that need license keys
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.LicenseKeyJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        // Enqueue the job if we actually have any leads
        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadLicenseKeyJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {

            // See LeadLicenseKeyService for corroboration of correct
            // criteria for enqueuing vs. skipping.
            AsyncJobUtil.stamp(eachLead, Schema.Lead.LicenseKeyJobStatus__c,
                    eachLead.LeadSource == 'Freemium' 
                    && eachLead.Email != null
                    && eachLead.AccessCodeFamily__c != 'Platform'
                            ? AsyncJobUtil.ENQUEUED_STATUS
                            : AsyncJobUtil.SKIPPED_STATUS);
        }
    }

    public override String getClassName() {
        return LeadLicenseKeyWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newLead.LicenseKeyJobStatus__c)
                && AsyncJobUtil.qualifyPrereqStatus(newLead.RestrictedPartyJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}