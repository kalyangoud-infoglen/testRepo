public with sharing class RequestPublishResultWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {

        // Gather a list of the record IDs
        List<Id> recordIds = new List<Id>();

        for (AmberRoadRequest__c eachRequest : (List<AmberRoadRequest__c>)this.records) {
            if (eachRequest.PublishResultJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                recordIds.add(eachRequest.Id);
            }
        }

        // Enqueue the job if we actually have any leads to assign
        if (recordIds.size() > 0) {
            System.enqueueJob(new RequestPublishResultJob(recordIds));
        }
    }

    public override void executeBefore() {
        for (AmberRoadRequest__c eachRequest : (List<AmberRoadRequest__c>)this.records) {
            AsyncJobUtil.stamp(eachRequest, Schema.AmberRoadRequest__c.PublishResultJobStatus__c, AsyncJobUtil.ENQUEUED_STATUS);
        }
    }

    public override String getClassName() {
        return RequestPublishResultWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        AmberRoadRequest__c newRequest = (AmberRoadRequest__c)newRecord;
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newRequest.PublishResultJobStatus__c)
                && AsyncJobUtil.qualifyPrereqStatus(newRequest.RestrictedPartyJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}