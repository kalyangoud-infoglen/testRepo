/**
 * This is an HttpCalloutMock that dispatches the correct mock response based
 * on which callout is being invoked for restricted party screening requests
 * (Amber Road or MaxMind)
 */
global class RequestRestrictedPartyServiceMock implements HttpCalloutMock {
    private AmberRoadServiceMock amberRoadMock;
    private MaxMindServiceMock maxMindMock;

	global RequestRestrictedPartyServiceMock() {
        amberRoadMock = new AmberRoadServiceMock();
        maxMindMock = new MaxMindServiceMock();
    }

    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response;
        String endpoint = req.getEndpoint();

        if (endpoint.contains('amberroad')) {
            response = amberRoadMock.respond(req);
        } else if (endpoint.contains('maxmind')) {
            response = maxMindMock.respond(req);
        }
        
        return response;
    }
}