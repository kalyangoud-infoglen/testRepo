/**
 * This is an HttpCalloutMock for use by unit tests that invoke the Netsuite LRP creation callout
 */
global class LeadLicenseKeyServiceMock implements HttpCalloutMock {
    private Integer statusCode = 200;
    private String responseBody = '{"LRP_id": 10853016, "LRP_status": "APPROVED"}';

    global LeadLicenseKeyServiceMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    global LeadLicenseKeyServiceMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.responseBody);
        res.setStatusCode(this.statusCode);
        return res;
    }
}