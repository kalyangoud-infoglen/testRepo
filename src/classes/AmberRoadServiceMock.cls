/**
 * This is an HttpCalloutMock for use by unit tests that invoke the Amber Road RPS callout
 */
global class AmberRoadServiceMock implements HttpCalloutMock {
    private Integer statusCode = 200;
    private String responseBody = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Partner Address1="" Address2="" Address3="" Address4="" City="" ' +
            'ContactName="Test Lead15" CountryCode="US" CountryName="United States of America" ' +
            'DateOfBirth="" Decision="N" EmbargoMatch="N" FlexField1="" IMOVesselNumber="" ' + 
            'Name="Rapid" OrgCode="RAPID7_LRP" PartnerID="SFLEAD_00Q4B000005I88cUAC" ' +
            'PostalCode="" SecondaryContactName="" SkipNewRPL="N" StateCode="FL" ' +
            'StateName="Florida" Version="1" WhiteListApproved="N" decisionBy="SYSTEM" ' +
            'decisionDate="05/25/2017 02:48:02 AM" screenDate="05/25/2017 02:48:02 AM" ' +
            'screenerName="INTEGRATION"/>';

    global AmberRoadServiceMock() {}

    global AmberRoadServiceMock(Integer statusCode, String responseBody) {
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