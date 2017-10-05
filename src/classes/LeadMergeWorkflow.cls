public with sharing class LeadMergeWorkflow extends AbstractSobjectWorkflow {

    private Map<String, Lead> existingLeadsByEmail { get; set; }

    public LeadMergeWorkflow() {
        this.existingLeadsByEmail = new Map<String, Lead>();
    }

    public override void executeAfter() {

        // Gather a list of the record IDs for victims to merge, then
        // enqueue a new LeadMergeJob object with those IDs if we have
        // a non-zero list.
        List<List<Id>> duplicateIdSets = new List<List<Id>>();

        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.MergeJobStatus__c == AsyncJobUtil.ENQUEUED_STATUS) {
                duplicateIdSets.add(new List<Id> {
                    this.existingLeadsByEmail.get(eachLead.Email).Id,
                    eachLead.Id
                });
            }
        }

        if (duplicateIdSets.size() > 0) {
            System.enqueueJob(new LeadMergeJob(duplicateIdSets)); 
        }
    }

    public override void executeBefore() {

        // Aggregate the set of email addresses
        Set<String> emailSet = new Set<String>();
        /* Modified for PHX-2177*/
        Set<Id> idSet = new Set<Id>();
        Group autocloseQueue = UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE);
        Id autocloseQueueId = null;
        if(autocloseQueue != null) {
            autocloseQueueId =  autocloseQueue.Id;
        }
        else {
            autocloseQueueId = null;
        }
        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.Email != null) {
                emailSet.add(eachLead.Email);
                idSet.add(eachLead.Id);
            }
        }
        
        // Compile a list of existing leads having matching emails
        for (Lead eachLead : [
            SELECT Email
            FROM Lead
            WHERE Email IN :emailSet
            AND (Status IN :LeadContext.OPEN_STATUS_SET
                    OR (Status = 'Close' AND ClosedReason__c IN :LeadContext.REOPEN_CLOSEREASON_SET) 
                    OR (Status = 'Close' AND ClosedReason__c =: '' AND Lead.OwnerId !=: autocloseQueueId))
        ]) {
            if(!idSet.contains(eachLead.Id)) {
                this.existingLeadsByEmail.put(eachLead.Email, eachLead);
            }
        }

        // Go through every lead, and either mark the merge job as skipped
        // or requested.
        for (Lead eachLead : (List<Lead>)this.records) {
            if (eachLead.Email == null) {
                AsyncJobUtil.stampSkipped(eachLead, Schema.Lead.MergeJobStatus__c);
            }
            else {
                AsyncJobUtil.stamp(eachLead, Schema.Lead.MergeJobStatus__c,
                        this.existingLeadsByEmail.containsKey(eachLead.Email)
                                ? AsyncJobUtil.ENQUEUED_STATUS
                                : AsyncJobUtil.SKIPPED_STATUS);
            }
        }
    }

    public override String getClassName() {
        return LeadMergeWorkflow.class.getName();
    }

    public override Boolean isRerunnable() {
        return true;
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;
        return (Trigger.isInsert || Trigger.isUpdate)
                && AsyncJobUtil.qualifyStatus(newLead.MergeJobStatus__c)
                && AsyncJobUtil.qualifyPrereqStatus(newLead.JunkScrubAssignJobStatus__c)
                && AsyncJobUtil.qualifyPrereqStatus(newLead.LicenseKeyJobStatus__c)
                && Limits.getQueueableJobs() == 0;
    }
}