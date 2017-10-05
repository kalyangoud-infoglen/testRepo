/**
 * This is an HttpCalloutMock for use by unit tests that invoke the Max Mind callout
 */
global class MaxMindServiceMock implements HttpCalloutMock {
    private Integer statusCode = 200;
    private String responseBody = [SELECT Body FROM StaticResource WHERE Name = 'MaxMindGeoIpSuccessResponse'].Body.toString();

    global MaxMindServiceMock() {}

    global MaxMindServiceMock(Integer statusCode, String responseBody) {
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