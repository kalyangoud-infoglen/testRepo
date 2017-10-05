public class MetasploitServiceMock implements SmartHttpCalloutMock {

    public static String getValidateEmailResponseBody(HttpRequest req) {
        String resourceName = 'MetasploitValidateEmail'
                + getValidateEmailResponseScenario(req);

        return [
            SELECT Body
            FROM StaticResource
            WHERE Name = :resourceName
        ].Body.toString();
    }

    public static String getValidateEmailResponseScenario(HttpRequest req) {
        String scenario = null;

        if (req.getEndpoint().contains('bugs@no.mail.server')) {
            scenario = 'BugsAtNoMailServer';
        }
        else if (req.getEndpoint().contains('bugs@slalom.com')) {
            scenario = 'BugsAtSlalomCom';
        }
        else if (req.getEndpoint().contains('bugs@gmail.com')) {
            scenario = 'BugsAtGmailCom';
        }
        else if (req.getEndpoint().contains('bugs')) {
            scenario = 'Bugs';
        }
        else if (req.getEndpoint().contains('foghorn@acme.test')) {
            scenario = 'FoghornAtAcmeTest';
        }
        else if (req.getEndpoint().contains('wile@acme.test')) {
            scenario = 'WileAtAcmeTest';
        }
        else if (req.getEndpoint().contains('marshall@eminem.test')) {
            scenario = 'MarshallAtEminemTest';
        }
        else if (req.getEndpoint().contains('104903@020.co.uk')) {
            scenario = 'BugsAtSlalomCom';
        }
        else {
            throw new ServiceException(
                    'Unknown validateEmail scenario: '
                            + req.getEndpoint());
        }

        return scenario;
    }

    public Boolean handles(HttpRequest req) {

        // TODO: Remove hard-coded value
        return req.getEndpoint().startsWith(
                'https://updates.metasploit.com/services');
    }

    public static Boolean isValidateEmailRequest(HttpRequest req) {
        return true;  // no other requests expected
    }

    public static HttpResponse newValidateEmailResponse(HttpRequest req) {

        // Initialize the response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/xml');

        // Set the body
        res.setBody(getValidateEmailResponseBody(req));

        // Return the response
        return res;
    }

    public HttpResponse respond(HttpRequest req) {

        HttpResponse res = null;

        if (isValidateEmailRequest(req)) {
            res = newValidateEmailResponse(req);
        }

        return res;
    }
}