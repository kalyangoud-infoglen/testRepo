public with sharing class LeadTrackTouchpointsWorkflow { //extends AbstractSobjectWorkflow {
    /*

    TO BE REMOVED IN PROD 
    
    public override void executeAfter() {

        // Gather a list of the record IDs for leads to assign
        List<Id> recordIds = new List<Id>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.TrackTouchpointsJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachLead.Id);
            }
        }

        // Enqueue the job if we actually have any leads to assign
        if (recordIds.size() > 0) {
            System.enqueueJob(new LeadTrackTouchpointsJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {
            AsyncJobUtil.stampEnqueued(eachLead, Schema.Lead.TrackTouchpointsJobStatus__c);
        }
    }

    public override String getClassName() {
        return LeadTrackTouchpointsWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;

        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newLead.TrackTouchpointsJobStatus__c)
                && AsyncJobUtil.qualifyPrereqStatus(newLead.MergeJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
*/
}