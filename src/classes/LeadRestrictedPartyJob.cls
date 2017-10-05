/**
 * This job is responsible for calling out to Amber Road to perform
 * restricted party screening for inbound leads.
 */
global class LeadRestrictedPartyJob extends AbstractProfiledAsyncJob implements Database.AllowsCallouts {

    /**
     * The Lead ID expected to be passed to the job as an input parameter
     * and then used to find the reference lead in the system.
     */
    private List<Id> recordIds { get; set; }
    private List<Lead> records { get; set; }

    /**
     * @param recordIds
     */
    global LeadRestrictedPartyJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * Call out to Amber Road to do restricted party screening
     */
    global override void execute() {
        LeadRestrictedPartyService service = new LeadRestrictedPartyService();
        records = service.performScreening(this.recordIds);
    }

    global override void finishSuccess() {
        List<Lead> successes = new List<Lead>();

        for (Id eachId : this.recordIds) {
            successes.add(
                    new Lead(Id = eachId,
                            RestrictedPartyJobStatus__c = AsyncJobUtil.SUCCESS_STATUS));
        }

        update successes;
    }

    global override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        update AsyncJobUtil.stampError(errors, Schema.Lead.RestrictedPartyJobStatus__c);
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return LeadRestrictedPartyJob.class.getName();
    }
}