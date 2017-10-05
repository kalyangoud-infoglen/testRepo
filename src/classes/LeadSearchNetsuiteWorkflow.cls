public with sharing class LeadSearchNetsuiteWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {

        // Gather a list of the record IDs for leads to search NetSuite
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.SearchNetsuiteJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        // Enqueue the job if we actually have any leads to search NetSuite
        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadSearchNetsuiteJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stamp(eachLead, Schema.Lead.SearchNetsuiteJobStatus__c,
                    eachLead.CompanyDunsNumber == null && eachLead.Email == null
                            ? AsyncJobUtil.SKIPPED_STATUS
                            : AsyncJobUtil.ENQUEUED_STATUS);
        }
    }

    public override String getClassName() {
        return LeadSearchNetsuiteWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newLead.SearchNetsuiteJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}