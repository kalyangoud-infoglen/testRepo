public with sharing class LeadJunkScrubAssignJob extends AbstractProfiledAsyncJob
        implements Database.AllowsCallouts {

    private List<Id> recordIds;

    public LeadJunkScrubAssignJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public override void execute() {

        // Set the options
        Database.DMLOptions options = new Database.DMLOptions();
        options.assignmentRuleHeader.assignmentRuleId =
                LeadUtil.getJunkScrubAssignmentRule().Id;

        // Construct a simplified version of each lead for the sole
        // purpose of invoking assignment rules
        List<Lead> records = this.getRecords();

        for (Lead eachLead : records) {

            // If the DML operation goes through, we would've successfully
            // completed junk scrub assignment
            eachLead.JunkScrubAssignJobStatus__c = AsyncJobUtil.SUCCESS_STATUS;

            // Assuming that this job is predicated on all of the following:
            //   1. the successful run of the Junk Scrub Job, which scrubs the 
            //      data and sets the data quality score,
            //   2. having an Infer Score,
            // we should have all the data we need to run the assignment rule
            // which manages criteria for auto-junking a lead
            eachLead.setOptions(options);
        }

        // Set the appropriate DML option to
        // update the lead such that it will fire the assignment rule
        DatabaseUtil.updateAllowSave(records, options);
    }

    public override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampError(errors, Schema.Lead.JunkScrubAssignJobStatus__c));
    }

    public override void finishSuccess() {
        /* do nothing because to work around the bug reported in Case 16747996
           only one update operation can be performed to avoid executing
           the assignment rule twice */
    }

    public override String getClassName() {
        return LeadJunkScrubAssignJob.class.getName();
    }

    /**
     * @return the records with appropriate fields needed for junk scrub
     */
    private List<Lead> getRecords() {
        return [
            SELECT Id,
                Company,
                Email,
                FirstName,
                LastName,
                Phone,
                Title
            FROM Lead
            WHERE Id IN :this.recordIds
        ];
    }
}