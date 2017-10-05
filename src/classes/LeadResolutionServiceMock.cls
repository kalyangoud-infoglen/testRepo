/**
 * This is an HttpCalloutMock for use by unit tests that invoke the Netsuite lead resolution callout
 */
global class LeadResolutionServiceMock implements HttpCalloutMock {
    private Integer statusCode = 200;
    private String responseBody = '{"id":123, "meta":{"href":"https://system.netsuite.com/app/crm/calendar/task.nl?id=123"}, "account":{"id":456, "meta":{"href":"https://system.netsuite.com/app/common/entity/custjob.nl?id=456"} }, "contact":{"id":789, "meta":{"href":"https://system.netsuite.com/app/common/entity/contact.nl?id=789"} } }';

    global LeadResolutionServiceMock() {}

    global LeadResolutionServiceMock(Integer statusCode, String responseBody) {
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