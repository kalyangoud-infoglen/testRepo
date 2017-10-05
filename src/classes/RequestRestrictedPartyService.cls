/*
 * Provides methods related to the callout to Amber Road to perform
 * restricted party screening.
 */
public without sharing class RequestRestrictedPartyService {
    
    private static final String AR_FLAGGED = 'Flagged';
    private static final String AR_CLEARED = 'Cleared';
    private static final String AR_ERROR = 'Error';

    // constructor
    public RequestRestrictedPartyService() {}

    // do restricted party screening for a set of leads
    public List<AmberRoadRequest__c> performScreening(List<Id> requestIds) {
        List<AmberRoadRequest__c> requests = new List<AmberRoadRequest__c>();
        for (AmberRoadRequest__c request : [
                Select Id, Address1__c, Address2__c, Address3__c, City__c, 
                    Company__c, CountryCode__c, Email__c, IP__c, Name, Name__c, 
                    PostalCode__c, RestrictedPartyJobStatus__c, 
                    RestrictedPartyStatus__c, StateCode__c
                From AmberRoadRequest__c
                Where Id In :requestIds]) {

            try {
                performEmbargoCheck(request);

                if (String.isBlank(request.RestrictedPartyStatus__c)) {
                    performScreening(request);
                }
            }
            catch(Exception ex) {
                request.RestrictedPartyStatus__c = AR_ERROR;
                request.RestrictedPartyStatusDetails__c = ex.getMessage();
                request.RestrictedPartyJobStatus__c = AsyncJobUtil.ERROR_STATUS;
            }

            requests.add(request);
        }

        if (!requests.isEmpty()) {
            Database.update(requests, false);
        }

        return requests;
    }

    @TestVisible
    private void performEmbargoCheck(AmberRoadRequest__c request) {
        String ipCity = null;
        String ipCountryCode = null;
        String ipDomain = null;
        String emailDomain = null;
        String status = null;

        MaxMindService service = new MaxMindService();

        MaxMindGeoIpResult result = service.getGeoIp(request.IP__c);

        if (result.city != null) {
            ipCity = result.city.names.en;
        }

        if (result.country != null) {
            ipCountryCode = result.country.iso_code;
        }

        if (result.traits != null) {
            ipDomain = result.traits.domain;
        }

        if (String.isNotBlank(request.Email__c)) {
            List<String> emailParts = request.Email__c.split('@');
            if (!emailParts.isEmpty()) {
                emailDomain = emailParts.get(emailParts.size() - 1);
            }
        }

        // city check
        if (status == null && String.isNotBlank(ipCity) && String.isNotBlank(ipCountryCode)) {
            for (EmbargoCity__c city : EmbargoCity__c.getAll().values()) {
                if (ipCity == city.Name && ipCountryCode == city.CountryCode__c) {
                    status = AR_FLAGGED;
                    break;
                }
            }
        }

        // domain check
        if (status == null && (String.isNotBlank(ipDomain) || String.isNotBlank(emailDomain))) {
            for (EmbargoDomain__c domain : EmbargoDomain__c.getAll().values()) {
                if (String.isNotBlank(ipDomain) && ipDomain.endsWith(domain.Name)) {
                    status = AR_FLAGGED;
                    break;
                }

                if (String.isNotBlank(emailDomain) && emailDomain.endsWith(domain.Name)) {
                    status = AR_FLAGGED;
                    break;
                }
            }
        }

        if (status != null) {
            request.RestrictedPartyStatus__c = status;
            request.RestrictedPartyStatusDate__c = Date.today();
        }

        request.MaxMindServiceRequest__c = (
            String.isNotEmpty(result.rawRequest) && result.rawRequest.length() > 2000
                ? result.rawRequest.left(2000)
                : result.rawRequest
        );
        request.MaxMindServiceResponse__c = (
            String.isNotEmpty(result.rawResponse) && result.rawResponse.length() > 5000
                ? result.rawResponse.left(5000)
                : result.rawResponse
        );
    }

    @TestVisible
    private void performScreening(AmberRoadRequest__c request) {

        AmberRoadService service = new AmberRoadService();

        AmberRoadResult result = service.performScreening(
            'SFREQUEST_' + request.Id, 
            'RAPID7_LRP',
            request.Company__c,
            request.Name,
            request.Name__c,
            request.Address1__c,
            request.Address2__c,
            request.Address3__c,
            request.City__c,
            request.StateCode__c,
            null,
            request.PostalCode__c,
            request.CountryCode__c,
            null
        );

        request.RestrictedPartyStatus__c = result.status;
        request.RestrictedPartyStatusDate__c = Date.today();

        request.AmberRoadServiceRequest__c = (
            String.isNotEmpty(result.rawRequest) && result.rawRequest.length() > 2000
                ? result.rawRequest.left(2000)
                : result.rawRequest
        );
        request.AmberRoadServiceResponse__c = (
            String.isNotEmpty(result.rawResponse) && result.rawResponse.length() > 5000
                ? result.rawResponse.left(5000)
                : result.rawResponse
        );
    }
}