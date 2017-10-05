public class AmberRoadService {

    private static final String AR_FLAGGED = 'Flagged';
    private static final String AR_CLEARED = 'Cleared';
    private static final String AR_ERROR = 'Error';

    public AmberRoadService() {}

    public AmberRoadResult performScreening(String partnerId, String orgCode, String companyName, String contactName,
                                            String secondaryContactName, String address1, String address2,
                                            String address3, String city, String stateCode, String stateName,
                                            String postalCode, String countryCode, String countryName) {
        
        AmberRoadResult result = new AmberRoadResult();
        String amberRoadXML = null;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = null;
        String truncatedResponseBody = null;

        amberRoadXML = generateAmberRoadXML(partnerId, orgCode, companyName, contactName,
                                            secondaryContactName, address1, address2,
                                            address3, city, stateCode, stateName,
                                            postalCode, countryCode, countryName);

        request.setMethod('POST');
        request.setHeader('Content-Type','text/xml');
        request.setHeader('Content-Length', String.valueOf(amberRoadXML.length()));
        request.setHeader('Authorization', getAmberRoadAuthHeader());
        request.setEndpoint(getAmberRoadRequestURL());
        request.setBody(amberRoadXML);

        result.rawRequest = amberRoadXML;

        response = http.send(request);

        result.rawResponse = response.getBody();

        if (response.getStatusCode() != 200) {
            result.status = AR_ERROR;
        } else {
            result.status = parseAmberRoadResponse(response.getBody());
        }

        return result;
    }

    @TestVisible
    private String getAmberRoadAuthHeader() {
        // AuthorizationHeader = Basic<Space><Base 64 Encode(UserName:Password)>
        String authHeader = null;
        AmberRoadSettings__c setting = AmberRoadSettings__c.getInstance('AuthorizationHeader');
        if(setting != null) {
            authHeader = setting.Value__c;
        }
        return authHeader;
    }

    @TestVisible
    private String getAmberRoadRequestURL() {
        String requestURL = null;
        AmberRoadSettings__c setting = AmberRoadSettings__c.getInstance('RequestURL');
        if(setting != null) {
            requestURL = setting.Value__c;
        }
        return requestURL;
    }

    @TestVisible
    private String generateAmberRoadXML(String partnerId, String orgCode, String companyName, String contactName,
                                        String secondaryContactName, String address1, String address2,
                                        String address3, String city, String stateCode, String stateName,
                                        String postalCode, String countryCode, String countryName) {

        String amberRoadString = '<?xml version="1.0" encoding="UTF-8"?>';
        amberRoadString += '<Partner xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="InboundXMLSchema.xsd" ';

        amberRoadString += 'PartnerID="' + partnerId + '" ';
        amberRoadString += 'Name="' + (String.isNotBlank(companyName) ? companyName : '').escapeHtml4() + '" ';
        amberRoadString += 'ContactName="' + (String.isNotBlank(contactName) ? contactName : '').escapeHtml4() + '" ';
        amberRoadString += 'SecondaryContactName="' + (String.isNotBlank(secondaryContactName) ? secondaryContactName : '').escapeHtml4() + '" ';
        amberRoadString += 'Address1="' + (String.isNotBlank(address1) ? address1 : '').escapeHtml4() + '" ';
        amberRoadString += 'Address2="' + (String.isNotBlank(address2) ? address1 : '').escapeHtml4() + '" ';
        amberRoadString += 'Address3="' + (String.isNotBlank(address3) ? address1 : '').escapeHtml4() + '" ';
        amberRoadString += 'City="' + (String.isNotBlank(city) ? city : '').escapeHtml4() + '" ';
        amberRoadString += 'StateCode="' + (String.isNotBlank(stateCode) ? stateCode : '').escapeHtml4() + '" ';
        amberRoadString += 'StateName="' + (String.isNotBlank(stateName) ? stateName : '').escapeHtml4() + '" ';
        amberRoadString += 'PostalCode="' + (String.isNotBlank(postalCode) ? postalCode : '').escapeHtml4() + '" ';
        amberRoadString += 'CountryCode="' + (String.isNotBlank(countryCode) ? countryCode : '').escapeHtml4() + '" ';
        amberRoadString += 'CountryName="' + (String.isNotBlank(countryName) ? countryName : '').escapeHtml4() + '" ';
        amberRoadString += 'OrgCode="' + orgCode + '" ';

        // hardcoded values - these values are always the same
        amberRoadString += 'PersistPartner="Y" ';
        amberRoadString += 'SkipNewRPL="N" ';
        amberRoadString += 'ReturnFullPartnerInformation="Y" ';
        amberRoadString += 'ReturnFullMatchDetail="Y" ';
        amberRoadString += 'ForceReScreen="N" ';
        amberRoadString += 'IMOVesselNumber="" ';

        amberRoadString += '/>';

        return amberRoadString;
    }

    @TestVisible
    private String parseAmberRoadResponse(String response) {
        DOM.Document responseXML = new DOM.Document();
        Dom.XMLNode responsePartnerNode = null;
        Dom.XMLNode responseErrorNode = null;
        String decision = null;
        String status = null;

        responseXML.load(response);

        // The Partner Node holds the "Decision" attribute, which needs to be returned to the initiating function
        responsePartnerNode = responseXML.getRootElement();
        
        // Check for integration errors. The <Error> node is a child of <Partner>
        responseErrorNode = responsePartnerNode.getChildElement('Error', null);
        if (responseErrorNode != null) {
            status = AR_ERROR;
        } else {
            /*
             * The screening results indicate whether Partner data that was submitted has any potential matches or not:
             *      N 􏰁􏰂no potential matches (Status - Approved) or
             *      P 􏰁􏰂has 1-n potential matches against RPL or partner country is in US embargo list (Status - Potential Match)
             *      M 􏰁􏰂has 1-n matches against RPL or partner country is a US embargo and marked as an actual match by your compliance user after review (Status - Match)
             */
            decision = responsePartnerNode.getAttributeValue('Decision', null);
            if (decision == 'P' || decision == 'M') {
                status = AR_FLAGGED; // Flagged
            } else if (decision == 'N'){
                // Only return true/approved if decision is N (No Matches)
                status = AR_CLEARED; // Cleared
            } else {
                // If none of the 3 known values then error
                status = AR_ERROR;
            }
        }

        return status;
    }
}