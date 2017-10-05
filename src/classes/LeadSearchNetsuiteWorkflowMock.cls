public class LeadSearchNetsuiteWorkflowMock implements SmartHttpCalloutMock {

    private NetsuiteService netsuite { get; set; }

    public LeadSearchNetsuiteWorkflowMock() {
        this.netsuite = NetsuiteService.getInstance();
    }

    public Boolean handles(HttpRequest request) {
        return this.isNetsuiteLeadSearchRequest(request)
                || this.isNetsuiteOpportunitySearchRequest(request);
    }

    /**
     * Given a request, return the appropriate response for testing purposes.
     *
     * @param  request the request sent in an Apex test
     * @return the appropriate response for the tested request
     */
    public HttpResponse respond(HttpRequest request) {
        
        // Placeholder for the response
        HttpResponse res = null;

        // Determine the appropriate operation and scenario, then
        // generate the appropriate response.
        if (this.isNetsuiteLeadSearchRequest(request)) {
            res = this.newNetsuiteLeadSearchResponse(
                    this.getNetsuiteLeadSearchScenario(request));
        }
        else if (isNetsuiteOpportunitySearchRequest(request)) {
            res = this.newNetsuiteOpportunitySearchResponse(
                    this.getNetsuiteOpportunitySearchScenario(request));
        }

        return res;
    }

    /**
     * Assuming that the request is a NetSuite lead search request, determine
     * the appropriate scenario identifier so that the correct content
     * for the scenario can be retrieved from the appropriate static resource
     * and put into the response body.
     *
     * @param request The NetSuite lead search request
     *
     * @return The appropriate scenario identifier
     */
    public String getNetsuiteLeadSearchScenario(HttpRequest request) {
        String scenario = null;

        if (request.getEndpoint().contains('higuma-shinya-r@pref.naganolg.jp')) {
            scenario = '110281368';  // Nagano Prefectual Government
        }
        else if (request.getEndpoint().contains('aaron.mixedcase@meadowbrook.com')) {
            scenario = '55397';  // Meadowbrook Insurance Group Inc
        }
        else if (request.getEndpoint().contains('694505686')) {
            scenario = '110281368';  // Nagano Prefectual Government
        }
        else if (request.getEndpoint().contains('654507094')) {
            scenario = '1067034';  // Konka Group Co Ltd
        }
        else if (request.getEndpoint().contains('jon@chipotle.com')) {
            scenario = 'SuccessCustomerAndContactBody';  // Chipotle Mexican Grill, Inc.
        }
        else if (request.getEndpoint().contains('art@slalom.com')) {
            scenario = '1067034';  // Konka Group Co Ltd
        }
        else if (request.getEndpoint().contains('wayne@bruce.com')) {
            scenario = 'SuccessNoResultsBody';
        }
        else if (request.getEndpoint().contains('@acme.test')) {
            scenario = 'SuccessNoResultsBody';
        }
        else if (request.getEndpoint().contains('bugs@no.mail.server')) {
            scenario = 'SuccessNoResultsBody';
        }
        else if (request.getEndpoint().contains('104903@020.co.uk')) {
            scenario = 'SuccessNoResultsBody';
        }
        else {
            throw new ServiceException(
                    'Indeterminable NetSuite lead search scenario: ' + request);
        }

        return scenario;
    }

    /**
     * Assuming that the request is a NetSuite opportunity search request, 
     * determine the appropriate scenario identifier so that the correct content
     * for the scenario can be retrieved from the appropriate static resource
     * and put into the response body.
     *
     * @param request The NetSuite opportunity search request
     *
     * @return The appropriate scenario identifier
     */
    public String getNetsuiteOpportunitySearchScenario(HttpRequest request) {
        String scenario = null;

        if (request.getEndpoint().contains('1067034')) {
            scenario = '1067034';  // Konka Group Co Ltd
        }
        else if (request.getEndpoint().contains('110281368')) {
            scenario = '110281368';  // Nagano Prefectual Government
        }
        else if (request.getEndpoint().contains('20964')) {
            scenario = '20964';  // Chipotle Mexican Grill, Inc.
        }
        else {
            throw new ServiceException(
                    'Indeterminable NetSuite opportunity search scenario');
        }

        return scenario;
    }

    /**
     * Determine whether a given request is a NetSuite lead search request.
     * The determination is made based on the vendor ID and also the script
     * number.
     *
     * @param request The `HttpRequest` object
     *
     * @return whether the request is to perform a NetSuite lead search
     */
    public Boolean isNetsuiteLeadSearchRequest(HttpRequest request) {
        return request.getEndpoint().contains(String.join(new List<String> {
            NetsuiteService.SCRIPT_PARAM_NAME,
            this.netsuite.setting.LeadSearchScript__c
        }, '='));
    }

    /**
     * Determine whether a given request is a NetSuite
     * opportunity search request.
     *
     * @param request The `HttpRequest` object
     *
     * @return whether the request is to perform a NetSuite opportunity search
     */
    public Boolean isNetsuiteOpportunitySearchRequest(HttpRequest request) {
        return request.getEndpoint().contains(String.join(new List<String> {
            NetsuiteService.SCRIPT_PARAM_NAME,
            this.netsuite.setting.OpportunitySearchScript__c
        }, '='));
    }

    /**
     * @param  scenario
     *             The name of the scenario to use in constructing the
     *             full static resource name to locate the file containing
     *             the appropriate body content to include in the response.
     * @return the success response for a lead search
     */
    public HttpResponse newNetsuiteLeadSearchResponse(String scenario) {

        // Init
        HttpResponse res = new HttpResponse();

        // Status
        res.setStatusCode(200);

        // Headers
        res.setHeader('Content-Type', 'application/json');

        // Body
        res.setBodyAsBlob([
            SELECT Body
            FROM StaticResource
            WHERE Name = :('NetsuiteLeadSearch' + scenario)
        ].Body);

        // Return
        return res;
    }

    /**
     * @param  scenario
     *             The name of the scenario to use in constructing the
     *             full static resource name to locate the file containing
     *             the appropriate body content to include in the response.
     * @return the success response for a lead search
     */
    public HttpResponse newNetsuiteOpportunitySearchResponse(String scenario) {

        // Init
        HttpResponse res = new HttpResponse();

        // Status
        res.setStatusCode(200);

        // Headers
        res.setHeader('Content-Type', 'application/json');

        // Body
        res.setBodyAsBlob([
            SELECT Body
            FROM StaticResource
            WHERE Name = :('NetsuiteOpportunitySearch' + scenario)
        ].Body);

        // Return
        return res;        
    }
}