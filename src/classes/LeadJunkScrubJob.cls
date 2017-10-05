public with sharing class LeadJunkScrubJob extends AbstractProfiledAsyncJob
        implements Database.AllowsCallouts {

    private List<Id> recordIds;

    public LeadJunkScrubJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public override void execute() {

        // Score the data quality of each lead
        List<Lead> records = LeadUtil.scoreDataQuality(this.getRecords());

        for (Lead eachLead : records) {

            // If the DML operation goes through, we would've successfully
            // completed junk scrub
            eachLead.JunkScrubStatus__c = AsyncJobUtil.SUCCESS_STATUS;

            // Request that the junk scrub assignment job run next
            eachLead.JunkScrubAssignJobStatus__c = AsyncJobUtil.REQUESTED_STATUS;
        }

        DatabaseUtil.updateAllowSave(records);
    }

    public override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampError(errors, Schema.Lead.JunkScrubStatus__c));
    }

    public override void finishSuccess() {}

    public override String getClassName() {
        return LeadJunkScrubJob.class.getName();
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