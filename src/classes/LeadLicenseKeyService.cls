/*
 * Provides methods related to the callout to Netsuite to generate a license key
 */
public without sharing class LeadLicenseKeyService {

    private static final Map<String, String> LRP_STATUS_MAPPING = new Map<String, String>{
        'APPROVED' => 'Approved',
        'DECLINED' => 'Declined',
        'GRAYLISTED' => 'Graylisted'
    };

    private static final String LRP_STATUS_ERROR = 'Error';

    // constructor
    public LeadLicenseKeyService() {}

    // generate LRP records in Netsuite for a collection of leads
    public List<Lead> generateLicenseKeys(List<Id> leadIds) {

        List<Lead> leads = new List<Lead>();
        for (Lead lead : [
                Select Id, AccessCode__c, Company, Country, CountryCode, Email, FirstName, LastName, LeadSource,
                       LicenseKeyStatus__c, LrpSid__c, Phone, RemoteIp__c, RestrictedPartyStatus__c, RestrictedPartyStatusDate__c, 
                       Title, TypeOfUse__c,
                       (Select CampaignId, CreatedDate, Campaign.NetsuiteCampaignInternalId__c 
                        From CampaignMembers 
                        Order By CreatedDate DESC 
                        Limit 1)
                From Lead
                Where Id In :leadIds
                And LeadSource = 'Freemium']) {

            try {
                createNetsuiteLRP(lead);
            }
            catch(Exception ex) {
                lead.LicenseKeyStatus__c = LRP_STATUS_ERROR;
                lead.LicenseKeyStatusDetails__c = ex.getMessage();
                lead.LicenseKeyJobStatus__c = AsyncJobUtil.ERROR_STATUS;
            }

            leads.add(lead);
        }

        update leads;
        return leads;
    }

    @TestVisible
    private String createNetsuiteLRP(Lead lead) {
        NetsuiteService service = new NetsuiteService();
        String responseBody = null;
        String truncatedResponseBody = null;

        try {
            responseBody = service.lrpCreate(lead);
        }
        catch (Exception ex) {
            responseBody = ex.getMessage();
            lead.LicenseKeyStatus__c = LRP_STATUS_ERROR;
        }

        if (lead.LicenseKeyStatus__c != LRP_STATUS_ERROR) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (responseMap.containsKey('error')) {
                lead.LicenseKeyStatus__c = LRP_STATUS_ERROR;
            } else if (responseMap.containsKey('LRP_status')) {
                String lrpStatus = (String) responseMap.get('LRP_status');
                if (LRP_STATUS_MAPPING.containsKey(lrpStatus)) {
                    lead.LicenseKeyStatus__c = LRP_STATUS_MAPPING.get(lrpStatus);
                } else {
                    lead.LicenseKeyStatus__c = LRP_STATUS_ERROR;
                }
            } else {
                lead.LicenseKeyStatus__c = LRP_STATUS_ERROR;
            }
        }

        if(lead.LicenseKeyStatus__c == LRP_STATUS_ERROR) {
            lead.LicenseKeyJobStatus__c = AsyncJobUtil.ERROR_STATUS;
        }

        truncatedResponseBody = responseBody;
        if (truncatedResponseBody.length() > 1000) {
            truncatedResponseBody = truncatedResponseBody.left(1000);
        }
        lead.LicenseKeyStatusDetails__c = truncatedResponseBody;

        return responseBody;
    }
}