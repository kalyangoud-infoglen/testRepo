/**
 * This job is responsible for calling out to Netsuite to initiate
 * the creation of a LRP record and the subsequent emailing of the
 * license key.
 */
global class LeadLicenseKeyJob extends AbstractProfiledAsyncJob implements Database.AllowsCallouts {

    /**
     * The Lead ID expected to be passed to the job as an input parameter
     * and then used to find the reference lead in the system.
     */
    private List<Id> recordIds { get; set; }
    private List<Lead> records { get; set; }

    /**
     * @param recordIds
     */
    global LeadLicenseKeyJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * Call out to Netsuite to create a LRP
     */
    global override void execute() {
        LeadLicenseKeyService service = new LeadLicenseKeyService();
        records = service.generateLicenseKeys(this.recordIds);
    }

    global override void finishSuccess() {
        List<Lead> successes = new List<Lead>();

        for (Id eachId : this.recordIds) {
            successes.add(
                    new Lead(Id = eachId,
                            LicenseKeyJobStatus__c = AsyncJobUtil.SUCCESS_STATUS));
        }

        update successes;
    }

    global override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        update AsyncJobUtil.stampError(errors, Schema.Lead.LicenseKeyJobStatus__c);
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return LeadLicenseKeyJob.class.getName();
    }
}