/*
 * Provides methods related to the callout to Netsuite to create lead, contact, and account records
 */
public without sharing class LeadResolutionService {

    public static final String LR_STATUS_SUCCESS = 'Sent to Netsuite';
    public static final String LR_STATUS_ERROR = 'Error';

    // constructor
    public LeadResolutionService() {}

    // generate LRP records in Netsuite for a collection of leads
    public List<Lead> resolveLeads(List<Id> leadIds) {

        Map<Id, String> userIdToNetsuiteEmployeeId = new Map<Id, String>();

        List<Lead> leads = [
            Select Id, City, ClosedReason__c, Company, CompanyDunsNumber, CountryCode, CreatedDate, Description, Email, FirstName, 
               Industry, InferScore__c, JobLevel__c, LastName, LeadSource, NetsuiteContactId__c, NetsuiteCustomerId__c, 
               OwnerId, Phone, PostalCode, StateCode, Status, Street, Title,
               (Select CampaignId, CreatedDate, Campaign.Name, Campaign.NetsuiteCampaignInternalId__c 
                From CampaignMembers 
                Order By CreatedDate DESC 
                Limit 1)
            From Lead
            Where Id In :leadIds
        ];

        for (Lead lead : leads) {
            userIdToNetsuiteEmployeeId.put(lead.OwnerId, null);
        }

        for (User user : [
                Select Id, NetsuiteEmployeeId__c
                From User
                Where Id in :userIdToNetsuiteEmployeeId.keySet()]) {

            userIdToNetsuiteEmployeeId.put(user.Id, user.NetsuiteEmployeeId__c);
        }

        List<Lead> updatedLeads = new List<Lead>();
        for (Lead lead : leads) {

            String netsuiteEmployeeId = userIdToNetsuiteEmployeeId.get(lead.OwnerId);

            try {
                resolveLead(lead, netsuiteEmployeeId);
            }
            catch(Exception ex) {
                String errorMessage = ex.getMessage();
                if (errorMessage.length() > 1000) {
                    errorMessage = errorMessage.left(1000);
                }
                lead.ResolutionStatus__c = LR_STATUS_ERROR;
                lead.ResolutionStatusDetails__c = errorMessage;
                lead.ResolutionJobStatus__c = AsyncJobUtil.ERROR_STATUS;
            }

            updatedLeads.add(lead);
        }

        update updatedLeads;
        return updatedLeads;
    }

    @TestVisible
    private LeadResolutionResult resolveLead(Lead lead, String netsuiteEmployeeId) {
        lead.ResolutionStatus__c = null;
        lead.ResolutionStatusDetails__c = null;
        NetsuiteService service = new NetsuiteService();
        LeadResolutionResult result = service.leadResolve(lead, netsuiteEmployeeId);
        String resultString;

        if (result == null) {
            throw new NetsuiteServiceException('LeadResolutionResult is null');
        }

        if (result.account != null && result.account.id != null) {
            lead.NetsuiteCustomerId__c = result.account.id;
        }

        if (result.contact != null && result.contact.id != null) {
            lead.NetsuiteContactId__c = result.contact.id;
        }

        lead.ResolutionStatus__c = LR_STATUS_SUCCESS;

        resultString = JSON.serialize(result);
        if (resultString.length() > 1000) {
            resultString = resultString.left(1000);
        }
        lead.ResolutionStatusDetails__c = resultString;

        return result;
    }
}