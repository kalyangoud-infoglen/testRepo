/**
 * This workflow exists to allow users to continue using the native
 * "Assign using active assignment rule" checkbox when creating leads
 * to control whewther to assign the lead automatically.
 *
 * The odd-ish interplay here is that when the user marks this checkbox,
 * we want the lead to be automatically assigned sometime in the future,
 * after prerequisites (i.e., other async jobs) have been met. This means
 * that when the actual assignment workflow runs, the `AssignmentRuleHeader`
 * won't reflect that a use actually wanted to assign the lead.
 *
 * This workflow "hijacks" the header and in effect causes it to request
 * the `LeadAssignJob` to run, but avoids hijacking the header when it's
 * the _job_ that's actually invoking the assignment rule.
 */
public with sharing class LeadPreassignWorkflow extends AbstractSobjectWorkflow {

    public override void executeAfter() {
        /* do nothing */
    }

    public override void executeBefore() {
        for (Lead eachLead : (List<Lead>)this.records) {
            eachLead.AssignJobStatus__c = AsyncJobUtil.REQUESTED_STATUS;
        }
    }

    public override String getClassName() {
        return LeadPreassignWorkflow.class.getName();
    }

    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        return (Trigger.isInsert && this.qualifyInsert(newRecord))
                || (Trigger.isUpdate && this.qualifyUpdate(newRecord, oldRecord));
    }

    private Boolean qualifyInsert(Sobject newRecord) {
        return newRecord.getOptions().assignmentRuleHeader.useDefaultRule == true;
    }

    private Boolean qualifyUpdate(Sobject newRecord, Sobject oldRecord) {
        Lead newLead = (Lead)newRecord;
        Lead oldLead = (Lead)oldRecord;

        // We need to determine whether the LeadAssignJob is actually trying
        // in earnest to do the assignment for real. In this case we don't
        // want to enqueue another job assign the lead again in an infinite
        // loop. The way we know this is to check to see whether the 
        // current job status is being set to "Success" from the previous
        // job status of "Enqueued".
        Boolean isBeingAssigned =
                newLead.AssignJobStatus__c.equals(AsyncJobUtil.SUCCESS_STATUS)
                        && oldLead.AssignJobStatus__c.equals(AsyncJobUtil.ENQUEUED_STATUS);

        return newRecord.getOptions().assignmentRuleHeader.useDefaultRule == true
                && !isBeingAssigned;
    }
}