public class LeadWorkflowMockSuite implements HttpCalloutMock {

    public static List<SmartHttpCalloutMock> getMocks() {
        return new List<SmartHttpCalloutMock> {
            new MetasploitServiceMock(),
            new LeadSearchNetsuiteWorkflowMock()
        };
    }

    /**
     * @param req The HTTP request
     *
     * @return an appropriate response for the given request
     */
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = null;

        List<SmartHttpCalloutMock> mocks = getMocks();

        while (res == null && mocks.size() > 0) {
            SmartHttpCalloutMock mock = mocks.remove(0);
            if (mock.handles(req)) {
                res = mock.respond(req);
            }
        }

        return res;
    }
}