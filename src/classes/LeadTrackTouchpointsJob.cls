/**
 * This job calculates the number of touchpoints made on a lead based on
 * defined business rules, which count all completed call and email
 * tasks related to a lead.
 */
global with sharing class LeadTrackTouchpointsJob {// extends AbstractProfiledAsyncJob {

    /**
     * The list of record IDs for leads to process
     */
   // private List<Id> recordIds { get; set; }

    /**
     * @param recordIds
     *            The list of record IDs for leads to process
     */
    //global LeadTrackTouchpointsJob(List<Id> recordIds) {
    //    this.recordIds = recordIds;
    //}

    /*
     * Assign the lead using the active assignment rule
     
    global override void execute() {
        List<Lead> records = new List<Lead>();

        for (Id eachId : this.recordIds) {
            records.add(new Lead(Id = eachId));
        }

        DatabaseUtil.updateAllowSave(
                PlatformLeadService.getInstance().rollup(records));
    }

    global override void finishSuccess() {
        List<Lead> successes = new List<Lead>();

        for (Id eachId : this.recordIds) {
            successes.add(
                    new Lead(Id = eachId,
                            TrackTouchpointsJobStatus__c = AsyncJobUtil.SUCCESS_STATUS));
        }

        DatabaseUtil.updateAllowSave(successes);
    }

    global override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampError(errors, Schema.Lead.TrackTouchpointsJobStatus__c));
    }
    */
    /**
     * @see AbstractProfiledAsyncJob
     */
    //global override String getClassName() {
     //   return LeadTrackTouchpointsJob.class.getName();
    //}
}