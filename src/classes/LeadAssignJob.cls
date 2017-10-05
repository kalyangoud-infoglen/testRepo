/**
 * This job is responsible for assigning a lead using the active assignment
 * rule. The way the assignment works is simply by updating the existing lead
 * record with no changes except to add the `DmlOptions` header to run
 * the active assignment rule.
 */
global class LeadAssignJob extends AbstractProfiledAsyncJob {

    /**
     * The list of record IDs for leads to automatically assign
     */
    private List<Id> recordIds { get; set; }

    /**
     * @param recordIds
     *            The list of record IDs for leads to automatically assign
     */
    global LeadAssignJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * Assign the lead using the active assignment rule
     */
    global override void execute() {
        
        Database.DMLOptions options = new Database.DMLOptions();
        options.assignmentRuleHeader.useDefaultRule = true;

        // Construct a simplified version of each lead for the sole
        // purpose of invoking assignment rules
        List<Lead> records = new List<Lead>();

        for (Id eachId : this.recordIds) {
            records.add(new Lead(Id = eachId));
        }

        // Set the appropriate DML option to
        // update the lead such that it will fire the assignment rule
        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampSuccess(records, Schema.Lead.AssignJobStatus__c), options);
    }

    global override void finishSuccess() {
        /* do nothing because to work around the bug reported in Case 16747996
           only one update operation can be performed to avoid executing
           the active assignment rule twice */
    }

    global override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampError(errors, Schema.Lead.AssignJobStatus__c));
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return LeadAssignJob.class.getName();
    }
}