/**
 * This job is responsible for finding a Lead and updating its NetSuiteCostomerId and
 * NetSuiteClientId fields. Job runs LeadSearch service to find leads by their DUNS # 
 * as well as an email address
 */
global class LeadSearchNetsuiteJob extends AbstractProfiledAsyncJob implements Database.AllowsCallouts {

    private List<Id> recordIds;

    global LeadSearchNetsuiteJob(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * Kick off the search for a search of NetSuite Leads
     */
    global override void execute() {
 
        LeadSearchNetsuiteService service = new LeadSearchNetsuiteService();

        // Enrich leads with customers, contacts and opportunities found in NetSuite
        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampSuccess(
                        service.enrichOpportunities(
                                service.enrichLeads([
                                    SELECT Id, CompanyDunsNumber, Email,
                                        NetsuiteContactId__c,
                                        NetsuiteCustomerId__c,
                                        NetsuiteOpportunities__c
                                    FROM Lead
                                    WHERE Id IN :this.recordIds
                                ])), Schema.Lead.SearchNetsuiteJobStatus__c));
    }

    global override void finishSuccess() {
        /* do nothing to hopefully avoid the "You have uncommitted work pending"
         * error logged in PHX-1603 */
    }

    global override void finishError(System.Exception e) {
        List<Lead> errors = [
            SELECT Id
            FROM Lead
            WHERE Id IN :this.recordIds
        ];

        DatabaseUtil.updateAllowSave(
                AsyncJobUtil.stampError(errors, Schema.Lead.SearchNetsuiteJobStatus__c));
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return LeadSearchNetsuiteJob.class.getName();
    }
}