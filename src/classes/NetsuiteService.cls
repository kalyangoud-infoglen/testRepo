public class NetsuiteService {

    /**
     * Not sure what this is but Sahidya has "deploy=1" in all of her
     * sample requests given in Postman
     */
    public static final String DEPLOY_PARAM_NAME = 'deploy';

    private static final Map<String, Integer> TYPE_OF_USE_MAPPING = new Map<String, Integer>{
        'Business' => 1,
        'Government' => 2,
        'Student' => 3,
        'Personal' => 4
    };

    private static final Map<String, String> LEAD_STATUS_MAPPING = new Map<String, String>{
        'CompleteInSalesforce' => 'Converted',
        'Opportunity Match' => 'Open Opportunity',
        'Nurture' => 'Nurture',
        'BDR Disqualified' => 'Junk'
    };

    private static final String DEFAULT_LEAD_FIELD_VALUE = '[not provided]';

    /**
     * The name of the URL query parameter that identifies the RESTlet to
     * run in NetSuite 
     */
    public static final String SCRIPT_PARAM_NAME = 'script';

    /**
     * The name of the URL query parameter that identifies the vendor based
     * on a enumerated Vendor ID in NetSuite
     */
    public static final String VENDOR_ID_PARAM_NAME = 'vid';
    
    private OauthCredential__c credential { get; set; }
    public NetsuiteSetting__c setting { get; set; }

    /**
     * Default constructor which gets the default credential and setting
     * for use in constructing the service.
     */
    public NetsuiteService() {
        this(getCredential(), NetsuiteSetting__c.getInstance());
    }

    /**
     * @param credential An OAuth record that provides credentials
     * @param setting    A NetSuite Setting record that provides endpoint info
     */
    public NetsuiteService(OauthCredential__c credential, NetsuiteSetting__c setting) {
        this.credential = credential;
        this.setting = setting;
    }

    /**
     * @return The default OAuth Credential record for use in setting up
     *         authentication for web service callouts
     */
    public static OauthCredential__c getCredential() {
        return [
            SELECT Realm__c, ConsumerKey__c, ConsumerSecret__c, Token__c, TokenSecret__c
            FROM OauthCredential__c
            WHERE Name = 'LEAD_SEARCH_SERVICE'
        ];
    }

    public LeadSearchResult leadSearch(String email, String dunsNumber) {
        
        HttpRequest request = this.newLeadSearchRequest(email, dunsNumber);

        HttpResponse response = new Http().send(request);
        
        if (response.getStatusCode() != 200) {
            throw new NetsuiteServiceException(response.getBody());
        }
        
        LeadSearchResult result = (LeadSearchResult) JSON.deserialize(response.getBody(), LeadSearchResult.class);
        
        result.rawRequest = request.getEndpoint();
        result.rawResponse = response.getBody();
        
        return result;
    }

    /**
     * Call out to Netsuite to create a LRP record for the given 
     * Salesforce lead
     */
    public String lrpCreate(Lead lead) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;

        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');

        // Define parameters for the query string
        Map<String, String> parameterMap = new Map<String, String> {
            SCRIPT_PARAM_NAME => this.setting.LeadLicenseKeyScript__c,
            DEPLOY_PARAM_NAME => '1'
        };

        request.setEndpoint(setting.RestletEndpoint__c + '?' 
            + HttpUtil.serializeQueryString(parameterMap));
        request.setBody(generateLrpJson(lead));
        request.setTimeout(60000);

        System.debug(request.getBody());
        
        OAuthUtil.sign(request, this.credential);

        response = http.send(request);

        System.debug(response.getBody());

        if (response.getStatusCode() != 200) {
            throw new NetsuiteServiceException(response.getBody());
        }

        return response.getBody();
    }

    /**
     * Call out to Netsuite to send data about a lead that has 
     * been resolved in Salesforce
     */
    public LeadResolutionResult leadResolve(Lead lead, String netsuiteEmployeeId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        LeadResolutionResult result = null;

        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');

        // Define parameters for the query string
        Map<String, String> parameterMap = new Map<String, String> {
            SCRIPT_PARAM_NAME => this.setting.LeadResolutionScript__c,
            DEPLOY_PARAM_NAME => '1',
            VENDOR_ID_PARAM_NAME => this.setting.LeadResolutionVendorId__c
        };
        
        request.setEndpoint(setting.RestletEndpoint__c + '?' 
            + HttpUtil.serializeQueryString(parameterMap));
        request.setBody(generateLeadJson(lead, netsuiteEmployeeId));
        request.setTimeout(60000);

        System.debug(request.getBody());
        
        OAuthUtil.sign(request, this.credential);

        response = http.send(request);

        System.debug(response.getBody());

        if (response.getStatusCode() != 200) {
            throw new NetsuiteServiceException(response.getBody());
        }

        result = (LeadResolutionResult) JSON.deserialize(response.getBody(), LeadResolutionResult.class);

        return result;
    }

    /**
     * Format Salesforce lead data in the JSON format expected 
     * by the Netsuite LRP RESTlet
     */
    @TestVisible
    private String generateLrpJson(Lead lead) {
        Integer typeOfUse = null;
        String leadSource = null;
        Map<String, Map<String, Object>> lrpJson = new Map<String, Map<String, Object>>();
        Map<String, Object> lrpDetailsJson = new Map<String, Object>();

        if (String.isNotBlank(lead.TypeOfUse__c) && TYPE_OF_USE_MAPPING.containsKey(lead.TypeOfUse__c)) {
            typeOfUse = TYPE_OF_USE_MAPPING.get(lead.TypeOfUse__c);
        }

        if (!lead.CampaignMembers.isEmpty() && String.isNotBlank(lead.CampaignMembers[0].Campaign.NetsuiteCampaignInternalId__c)) {
            leadSource = lead.CampaignMembers[0].Campaign.NetsuiteCampaignInternalId__c;
        }

        lrpDetailsJson.put('ip', lead.RemoteIp__c);
        lrpDetailsJson.put('firstName', lead.FirstName);
        lrpDetailsJson.put('lastName', lead.LastName);
        lrpDetailsJson.put('countryCode', lead.CountryCode);
        lrpDetailsJson.put('jobTitle', lead.Title);
        lrpDetailsJson.put('typeOfUse', typeOfUse);
        lrpDetailsJson.put('email', lead.Email);
        lrpDetailsJson.put('phone', lead.Phone);
        lrpDetailsJson.put('companyName', lead.Company);
        lrpDetailsJson.put('recapRemoteIP', lead.RemoteIp__c);
        lrpDetailsJson.put('leadSource', leadSource);
        lrpDetailsJson.put('lrpsid', lead.LrpSid__c);
        lrpDetailsJson.put('accessCode', lead.AccessCode__c);
        lrpDetailsJson.put('referer', 'rapid7.com');
        lrpDetailsJson.put('logHeaderParams', '');
        lrpDetailsJson.put('deniedPartyStatus', lead.RestrictedPartyStatus__c);
        lrpDetailsJson.put('deniedPartyStatusDate', lead.RestrictedPartyStatusDate__c);
        lrpJson.put('lrp', lrpDetailsJson);

        return JSON.serialize(lrpJson);
    }

    /**
     * Format Salesforce lead data in the JSON format expected 
     * by the Netsuite lead resolution RESTlet
     */
    @TestVisible
    private String generateLeadJson(Lead lead, String netsuiteEmployeeId) {
        
        Map<String, Object> leadJson = new Map<String, Object>();

        // Set default values for selected required integration params
        String subject = 'Salesforce Lead';
        String leadStatus = 'Nurture';
        String ownerId = '106223954'; // internal Id of NS Admin User

        // Set default values for other required integration params
        String campaignId = DEFAULT_LEAD_FIELD_VALUE;
        String companyName = DEFAULT_LEAD_FIELD_VALUE;
        String lastName = DEFAULT_LEAD_FIELD_VALUE;
        String email = DEFAULT_LEAD_FIELD_VALUE;
        String leadSource = DEFAULT_LEAD_FIELD_VALUE;

        // non-required integration params
        String leadScore = null;
        String street = null;
        String city = null;
        String state = null;
        String country = null;
        String postalCode = null;
        String title = null;
        String firstName = null;
        String phone = null;
        String jobLevel = null;
        String description = null;
        String dunsNumber = null;

        // populate required param values from lead
        if (!lead.CampaignMembers.isEmpty()) {
            if (String.isNotBlank(lead.CampaignMembers[0].Campaign.NetsuiteCampaignInternalId__c)) {
                campaignId = lead.CampaignMembers[0].Campaign.NetsuiteCampaignInternalId__c;
            }
            if (String.isNotBlank(lead.CampaignMembers[0].Campaign.Name)) {
                subject = lead.CampaignMembers[0].Campaign.Name;
            }
        }

        if (String.isNotBlank(lead.Status)) {
            if (lead.Status == 'CompleteInSalesforce' 
                    && LEAD_STATUS_MAPPING.containsKey(lead.Status)) {
                leadStatus = LEAD_STATUS_MAPPING.get(lead.Status);
            } else if (lead.Status == 'Close' 
                    && String.isNotBlank(lead.ClosedReason__c)
                    && LEAD_STATUS_MAPPING.containsKey(lead.ClosedReason__c)) {
                leadStatus = LEAD_STATUS_MAPPING.get(lead.ClosedReason__c);
            }
        }

        if (lead.InferScore__c != null) {
            leadScore = lead.InferScore__c.toPlainString();
        }

        if (netsuiteEmployeeId != null) {
            ownerId = netsuiteEmployeeId;
        }

        if (String.isNotBlank(lead.Company)) {
            companyName = lead.Company;
        }

        if (String.isNotBlank(lead.Street)) {
            street = lead.Street;
        }

        if (String.isNotBlank(lead.City)) {
            city = lead.City;
        }

        if (String.isNotBlank(lead.StateCode)) {
            state = lead.StateCode;
        }

        if (String.isNotBlank(lead.CountryCode)) {
            country = lead.CountryCode;
        }

        if (String.isNotBlank(lead.PostalCode)) {
            postalCode = lead.PostalCode;
        }

        if (String.isNotBlank(lead.Title)) {
            title = lead.Title;
        }

        if (String.isNotBlank(lead.FirstName)) {
            firstName = lead.FirstName;
        }

        if (String.isNotBlank(lead.LastName)) {
            lastName = lead.LastName;
        }

        if (String.isNotBlank(lead.Email)) {
            email = lead.Email;
        }

        if (String.isNotBlank(lead.Phone)) {
            phone = lead.Phone;
        }

        if (String.isNotBlank(lead.JobLevel__c)) {
            jobLevel = lead.JobLevel__c;
        }

        if (String.isNotBlank(lead.Description)) {
            description = lead.Description;
            // truncate description so it fits in Netsuite memo field (PHX-1637)
            if (description.length() > 999) {
                description = description.left(999);
            }
        }

        if (String.isNotBlank(lead.LeadSource)) {
            leadSource = lead.LeadSource;
        }

        if (String.isNotBlank(lead.CompanyDunsNumber)) {
            dunsNumber = lead.CompanyDunsNumber;
        }

        // populate map
        leadJson.put(VENDOR_ID_PARAM_NAME, this.setting.LeadResolutionVendorId__c);
        leadJson.put('leadId', lead.Id);
        leadJson.put('accountId', lead.NetsuiteCustomerId__c);
        leadJson.put('companyName', companyName);
        leadJson.put('street', street);
        leadJson.put('city', city);
        leadJson.put('state', state);
        leadJson.put('postalCode', postalCode);
        leadJson.put('country', country);
        leadJson.put('contactId', lead.NetsuiteContactId__c);
        leadJson.put('title', title);
        leadJson.put('firstName', firstName);
        leadJson.put('lastName', lastName);
        leadJson.put('email', email);
        leadJson.put('phone', phone);
        leadJson.put('jobLevel', jobLevel);
        leadJson.put('leadScore', leadScore);
        leadJson.put('activityDate', lead.CreatedDate);
        // currencyIsoCode hard-coded to USD - field lead.currencyIsoCode is
        //   not available because multi-currency is not enabled in org
        leadJson.put('currencyIsoCode', 'USD'); 
        leadJson.put('description', description);
        leadJson.put('campaignId', campaignId);
        leadJson.put('leadStatus', leadStatus);
        leadJson.put('ownerId', ownerId);
        leadJson.put('subject', subject);
        leadJson.put('leadSource', leadSource);
        leadJson.put('dunsNumber', dunsNumber);

        // return JSON string
        return JSON.serialize(leadJson);
    }

    /**
     * @return A usable instance of this class
     */
    public static NetsuiteService getInstance() {
        return new NetsuiteService();
    }

    /**
     * Construct a new HttpRequest that can be sent based on a given
     * email and/or a D-U-N-S Number
     *
     * @param email
     * @param dunsNumber
     *
     * @return an HttpRequest which can be sent to perform a lead search
     */
    public HttpRequest newLeadSearchRequest(String email, String dunsNumber) {

        // Initialize the request
        HttpRequest req = new HttpRequest();

        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');

        // Define parameters for the query string
        Map<String, String> parameterMap = new Map<String, String> {
            SCRIPT_PARAM_NAME => this.setting.LeadSearchScript__c,
            DEPLOY_PARAM_NAME => '1',  // because Sahidya said so
            VENDOR_ID_PARAM_NAME => this.setting.LeadSearchVendorId__c
        };

        if (!String.isEmpty(email)) {
            parameterMap.put('email', email);
        }

        if (!String.isEmpty(dunsNumber)) {
            parameterMap.put('dunsNumber', dunsNumber);
        }

        // Set the endpoint, including the query string
        req.setEndpoint(setting.RestletEndpoint__c + '?'
                + HttpUtil.serializeQueryString(parameterMap));

        // Extend the timeout to 120 seconds for long-running operations.
        // This used to be 60 seconds before encountering the timeout
        // error logged in PHX-1603.
        req.setTimeout(120000);
        
        // Sign the request for authentication
        OAuthUtil.sign(req, this.credential);

        return req;
    }

    /**
     * Construct a new HttpRequest that can be sent based on a given
     * customer ID
     *
     * @param customerId NetSuite Customer ID
     *
     * @return an HttpRequest which can be sent to perform
     *         an opportunity search
     */
    public HttpRequest newOpportunitySearchRequest(String customerId) {
        HttpRequest req = new HttpRequest();

        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');

        Map<String, String> parameterMap = new Map<String, String> {
            SCRIPT_PARAM_NAME => this.setting.OpportunitySearchScript__c,
            DEPLOY_PARAM_NAME => '1',  // because Sahidya said so
            VENDOR_ID_PARAM_NAME => this.setting.OpportunitySearchVendorId__c,
            'accountId' => customerId
        };

        req.setEndpoint(setting.RestletEndpoint__c + '?'
                + HttpUtil.serializeQueryString(parameterMap));

        // Extend the timeout to 120 seconds for long-running operations.
        // This used to be 60 seconds before encountering the timeout
        // error logged in PHX-1603.
        req.setTimeout(120000);
        
        // Sign the request for authentication
        OAuthUtil.sign(req, this.credential);

        return req;
    }

    /**
     * Search NetSuite for opportunities associated with a given customer
     *
     * @param customerId The NetSuite Customer ID for the desired customer
     *
     * @return the result
     */
    public OpportunitySearchResult opportunitySearch(String customerId) {
        HttpRequest req = newOpportunitySearchRequest(customerId);
        HttpResponse res = new Http().send(req);

        // Examine the response and return an appropriate result
        OpportunitySearchResult result = new OpportunitySearchResult();

        if (res.getStatusCode() == 200) {
            result = (OpportunitySearchResult)JSON.deserialize(
                        res.getBody(), OpportunitySearchResult.class);
            result.setSuccess(true);
        }

        return result;
    }

    public class OpportunitySearchResult implements Result {

        public List<NetsuiteOpportunity> items { get; set; }
        public Integer size { get; set; }
        private Boolean success;

        public OpportunitySearchResult() {
            this.items = null;
            this.size = 0;
            this.success = false;
        }

        public String getDescription() {

            // Compile a list of all of the opportunity names
            List<String> opportunityNames = new List<String>();

            if (this.size > 0) {
                for (NetsuiteOpportunity eachItem : this.items) {
                    if (eachItem.probability > 0 && eachItem.probability < 100) {
                        opportunityNames.add(String.join(new List<String> {
                            eachItem.id
                        }, ' '));
                    }
                }
            }

            // Return the description of all the opportunities
            return String.join(opportunityNames, '; '); 
        }

        public Boolean isSuccess() {
            return this.success;
        }

        public void setSuccess(Boolean value) {
            this.success = value;
        }
    }
}