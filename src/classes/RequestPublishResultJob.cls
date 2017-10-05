/**
 * This job is responsible for calling out to Amazon SNS to publish the result
 * of the restricted party screening for requests received through the restricted
 * party screening endpoint.
 */
global class RequestPublishResultJob extends AbstractProfiledAsyncJob implements Database.AllowsCallouts {

    /**
     * The Request ID expected to be passed to the job as an input parameter
     * and then used to find the referenced request in the system.
     */
    private List<Id> recordIds { get; set; }
    private List<AmberRoadRequest__c> records { get; set; }

    /**
     * @param recordIds
     */
    global RequestPublishResultJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * Call out to Amazon SNS to publish the result of a restricted party screening
     */
    global override void execute() {
        RequestPublishResultService service = new RequestPublishResultService();
        records = service.publishResult(this.recordIds);
    }

    global override void finishSuccess() {
        List<AmberRoadRequest__c> successes = new List<AmberRoadRequest__c>();

        for (Id eachId : this.recordIds) {
            successes.add(
                    new AmberRoadRequest__c(Id = eachId,
                            PublishResultJobStatus__c = AsyncJobUtil.SUCCESS_STATUS));
        }

        update successes;
    }

    global override void finishError(System.Exception e) {
        List<AmberRoadRequest__c> errors = [
            SELECT Id
            FROM AmberRoadRequest__c
            WHERE Id IN :this.recordIds
        ];

        update AsyncJobUtil.stampError(errors, Schema.AmberRoadRequest__c.PublishResultJobStatus__c);
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return RequestPublishResultJob.class.getName();
    }
}