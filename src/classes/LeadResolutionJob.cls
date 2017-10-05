/**
 * This job is responsible for calling out to Netsuite to initiate
 * the creation of lead, contact, and account records
 */
global class LeadResolutionJob extends AbstractProfiledAsyncJob implements Database.AllowsCallouts {

    /**
     * The Lead ID expected to be passed to the job as an input parameter
     * and then used to find the reference lead in the system.
     */
    private List<Id> recordIds { get; set; }
    private List<Lead> records { get; set; }

    /**
     * @param recordIds
     */
    global LeadResolutionJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * Call out to Netsuite to create lead record
     */
    global override void execute() {
        LeadResolutionService service = new LeadResolutionService();
        records = service.resolveLeads(this.recordIds);
    }

    global override void finishSuccess() {
        List<Lead> successes = new List<Lead>();

        for (Id eachId : this.recordIds) {
            successes.add(
                    new Lead(Id = eachId,
                            ResolutionJobStatus__c = AsyncJobUtil.SUCCESS_STATUS));
        }

        update successes;
    }

    global override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        update AsyncJobUtil.stampError(errors, Schema.Lead.ResolutionJobStatus__c);
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return LeadResolutionJob.class.getName();
    }
}