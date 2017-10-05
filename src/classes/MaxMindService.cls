public class MaxMindService {

    public MaxMindService() {}

    public MaxMindGeoIpResult getGeoIp(String ipAddress) {

        MaxMindGeoIpResult result = new MaxMindGeoIpResult();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = null;
        String endpointUrl = getMaxMindRequestURL() + ipAddress;

        if (String.isBlank(ipAddress)) {
            result.errorMessage = 'ipAddress must not be null';
            return result;
        }

        request.setMethod('GET');
        request.setHeader('Accept','application/json');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Authorization', getMaxMindAuthHeader());
        request.setEndpoint(endpointUrl);

        try {
            response = http.send(request);

            if (response.getStatusCode() != 200) {

                result.errorMessage = 'HTTP Status: ' + response.getStatusCode() + ' ' + response.getStatus();

            } else {

                String responseJSON = response.getBody();

                if(String.isNotEmpty(responseJSON)) {

                    // rename attributes that are invalid identifiers in Apex
                    responseJSON = responseJSON.replace('pt-BR','pt_BR').replace('zh-CN','zh_CN');

                    // parse the JSON into our result object
                    result = (MaxMindGeoIpResult) JSON.deserialize(responseJSON, MaxMindGeoIpResult.class);
                }
            }
        }
        catch (Exception ex) {

            result.errorMessage = ex.getMessage();
        }
        finally {

            result.rawRequest = 'GET ' + endpointUrl;

            if (response != null) {
                result.rawResponse = response.getBody();
            }
        }
        
        return result;
    }

    @TestVisible
    private String getMaxMindAuthHeader() {
        // AuthorizationHeader = Basic<Space><Base 64 Encode(UserName:Password)>
        String authHeader = null;
        MaxMindSettings__c setting = MaxMindSettings__c.getInstance('AuthorizationHeader');
        if(setting != null) {
            authHeader = setting.Value__c;
        }
        return authHeader;
    }

    @TestVisible
    private String getMaxMindRequestURL() {
        String requestURL = null;
        MaxMindSettings__c setting = MaxMindSettings__c.getInstance('RequestURL');
        if(setting != null) {
            requestURL = setting.Value__c;
        }
        return requestURL;
    }
}