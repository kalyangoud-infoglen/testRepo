global class NetsuiteServiceMock implements HttpCalloutMock {

    /**
     * Given a request, return the appropriate response for testing purposes.
     *
     * @param  request the request sent in an Apex test
     * @return the appropriate response for the tested request
     */
    global HttpResponse respond(HttpRequest request) {
        return newNetsuiteLeadSearchSuccessResponse('CustomerAndContact');
    }

    /**
     * @param  scenario
     *             The name of the scenario to use in constructing the
     *             full static resource name to locate the file containing
     *             the appropriate body content to include in the response.
     * @return the success response for a lead search
     */
    global HttpResponse newNetsuiteLeadSearchSuccessResponse(String scenario) {

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
            WHERE Name = :('NetsuiteLeadSearchSuccess' + scenario + 'Body')
        ].Body);

        // Return
        return res;        
    }
}