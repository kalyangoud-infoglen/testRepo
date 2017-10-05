/*
 * Provides methods related to the callout to Amber Road to perform
 * restricted party screening.
 */
public without sharing class LeadRestrictedPartyService {
	
    private static final String AR_FLAGGED = 'Flagged';
    private static final String AR_CLEARED = 'Cleared';
    private static final String AR_ERROR = 'Error';

    // constructor
    public LeadRestrictedPartyService() {}

    // do restricted party screening for a set of leads
    public List<Lead> performScreening(List<Id> leadIds) {

        List<Lead> leads = new List<Lead>();
        for (Lead lead : [
                Select Id, City, Company, Country, CountryCode, FirstName, 
                       LastName, PostalCode, RestrictedPartyJobStatus__c, State, StateCode, Street
                From Lead
                Where Id In :leadIds
                And LeadSource = 'Freemium']) {

            try {
                performScreening(lead);
            }
            catch(Exception ex) {
                lead.RestrictedPartyStatus__c = AR_ERROR;
                lead.RestrictedPartyStatusDetails__c = ex.getMessage();
                lead.RestrictedPartyJobStatus__c = AsyncJobUtil.ERROR_STATUS;
            }

            leads.add(lead);
        }

        if (!leads.isEmpty()) {
            Database.update(leads, false);
        }

        return leads;
    }

    @TestVisible
    private String performScreening(Lead lead) {

        String truncatedResponseBody = null;
        AmberRoadService service = new AmberRoadService();

        String fullName = (String.isNotBlank(lead.FirstName) ? lead.FirstName + ' ' : '') + 
                          (String.isNotBlank(lead.LastName) ? lead.LastName : '');

        AmberRoadResult result = service.performScreening(
            'SFLEAD_' + lead.Id, 
            'RAPID7_LRP',
            lead.Company,
            fullName,
            null,
            lead.Street,
            null,
            null,
            lead.City,
            lead.StateCode,
            lead.State,
            lead.PostalCode,
            lead.CountryCode,
            lead.Country
        );

        System.debug(result.rawRequest);
        System.debug(result.rawResponse);

        lead.RestrictedPartyStatus__c = result.status;

        if(lead.RestrictedPartyStatus__c == AR_ERROR) {
            lead.RestrictedPartyJobStatus__c = AsyncJobUtil.ERROR_STATUS;
        }

        truncatedResponseBody = result.rawResponse;
        if (truncatedResponseBody.length() > 1000) {
            truncatedResponseBody = truncatedResponseBody.left(1000);
        }
        lead.RestrictedPartyStatusDetails__c = truncatedResponseBody;

        lead.RestrictedPartyStatusDate__c = Date.today();

        return result.rawResponse; 
    }
}