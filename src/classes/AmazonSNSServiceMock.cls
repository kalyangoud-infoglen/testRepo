/**
 * This is an HttpCalloutMock for use by unit tests that invoke the Amazon SNS callout
 */
global class AmazonSNSServiceMock implements HttpCalloutMock {
    private Integer statusCode = 200;
    private String responseBody =
        '<PublishResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">' +
        '<PublishResult><MessageId>94b689df-0e56-530a-aed7-dbc1e4fbd27c</MessageId></PublishResult>' +
        '<ResponseMetadata><RequestId>bcb5fed6-97ba-5d3b-89db-acc87d173c4d</RequestId></ResponseMetadata>' +
        '</PublishResponse>';

    global AmazonSNSServiceMock() {}

    global AmazonSNSServiceMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(this.responseBody);
        res.setStatusCode(this.statusCode);
        return res;
    }
}