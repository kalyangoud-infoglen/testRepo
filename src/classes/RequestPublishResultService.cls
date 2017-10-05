/*
 * Provides methods related to the callout to publish the results
 * of a restricted party screeing request to an AWS SNS topic
 */
public without sharing class RequestPublishResultService {

    private static final String AR_ERROR = 'Error';

    // constructor
    public RequestPublishResultService() {}

    // publish result for a list of requests
    public List<AmberRoadRequest__c> publishResult(List<Id> requestIds) {
        List<AmberRoadRequest__c> requests = new List<AmberRoadRequest__c>();
        for (AmberRoadRequest__c request : [
                Select 
                    Id,
                    Name,
                    Address1__c,
                    Address2__c,
                    Address3__c,
                    City__c,
                    Company__c,
                    CountryCode__c,
                    Name__c,
                    PostalCode__c,
                    RestrictedPartyJobStatus__c, 
                    RestrictedPartyStatus__c,
                    RestrictedPartyStatusDate__c,
                    RestrictedPartyStatusDetails__c,
                    StateCode__c
                From AmberRoadRequest__c
                Where Id In :requestIds]) {

            try {
                publishResult(request);
            }
            catch(Exception ex) {
                request.PublishResultStatus__c = AR_ERROR;
                request.PublishResultStatusDetails__c = ex.getMessage();
            }

            requests.add(request);
        }

        if (!requests.isEmpty()) {
            Database.update(requests, false);
        }

        return requests;
    }

    @TestVisible
    private void publishResult(AmberRoadRequest__c request) {
        String status =
            (String.isNotEmpty(request.RestrictedPartyStatus__c)
                ? request.RestrictedPartyStatus__c.toUpperCase()
                : request.RestrictedPartyStatus__c);

        String screeningDate =
            (request.RestrictedPartyStatusDate__c == null
                ? null
                : String.valueOf(request.RestrictedPartyStatusDate__c));

        RequestPublishResultResponse resultMessage = new RequestPublishResultResponse();
        Attributes attribute = new Attributes();
        resultMessage.id = request.Id;
        attribute.type = 'AmberRoadRequest__c';
        attribute.url = '/services/data/v40.0/sobjects/AmberRoadRequest__c/'+ resultMessage.id;
        resultMessage.attributes = attribute;
        resultMessage.companyName = request.Company__c;
        resultMessage.contactName = request.Name;
        resultMessage.secondaryContactName = request.Name__c;
        resultMessage.streetAddress1 = request.Address1__c;
        resultMessage.streetAddress2 = request.Address2__c;
        resultMessage.streetAddress3 = request.Address3__c;
        resultMessage.city = request.City__c;
        resultMessage.stateCode = request.StateCode__c;
        resultMessage.countryCode = request.CountryCode__c;
        resultMessage.postalCode = request.PostalCode__c;
        resultMessage.status = status;
        // TODO: add these back when the Platform team can accomodate them
        //resultMessage.screeningDate = screeningDate;
        //resultMessage.errorMessage = request.RestrictedPartyStatusDetails__c;
        
        AmazonSNSService SNS = new AmazonSNSService('RestrictedScreeningSNS');

        AmazonSNSResult result = SNS.publish(JSON.serializePretty(resultMessage));

        request.PublishResultStatus__c = result.status;
        request.PublishResultStatusDetails__c = (
            String.isNotEmpty(result.errorMessage) && result.errorMessage.length() > 1000
                ? result.errorMessage.left(1000)
                : result.errorMessage
        );
        request.AmazonSNSServiceRequest__c = (
            String.isNotEmpty(result.rawRequest) && result.rawRequest.length() > 2000
                ? result.rawRequest.left(2000)
                : result.rawRequest
        );
        request.AmazonSNSServiceResponse__c = (
            String.isNotEmpty(result.rawResponse) && result.rawResponse.length() > 2000
                ? result.rawResponse.left(2000)
                : result.rawResponse
        );
    }
}