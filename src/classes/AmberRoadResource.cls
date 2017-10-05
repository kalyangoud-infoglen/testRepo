@RestResource(urlMapping='/restricted-party-request/*')
global with sharing class AmberRoadResource {

    @HttpPost
    global static void doPost(String companyName, String contactName, String secondaryContactName, String streetAddress1, String streetAddress2, String streetAddress3, String city, String stateCode, String countryCode, String postalCode, String email, String ip) {
    
        AmberRoadRequest__c amberRoadRequest = new AmberRoadRequest__c();
        amberRoadRequest.Company__c = companyName;
        amberRoadRequest.Name = contactName;
        amberRoadRequest.Name__c = secondaryContactName;
        amberRoadRequest.Address1__c = streetAddress1;
        amberRoadRequest.Address2__c = streetAddress2;
        amberRoadRequest.Address3__c = streetAddress3;
        amberRoadRequest.City__c = city;
        amberRoadRequest.StateCode__c = stateCode;
        amberRoadRequest.CountryCode__c = countryCode;
        amberRoadRequest.PostalCode__c = postalCode;
        amberRoadRequest.Email__c = email;
        amberRoadRequest.IP__c = ip;
        
        insert amberRoadRequest;
        
        AmberRoadResponse amberResponse = new AmberRoadResponse();
        Attributes attribute = new Attributes();
        amberResponse.id = amberRoadRequest.id;
        attribute.type = 'AmberRoadRequest__c';
        attribute.url = '/services/data/v40.0/sobjects/AmberRoadRequest__c/'+ amberResponse.id;
        amberResponse.attributes = attribute;
        amberResponse.companyName = companyName;
        amberResponse.contactName = contactName;
        amberResponse.secondaryContactName = secondaryContactName;
        amberResponse.streetAddress1 = streetAddress1;
        amberResponse.streetAddress2 = streetAddress2;
        amberResponse.streetAddress3 = streetAddress3;
        amberResponse.city = city;
        amberResponse.stateCode = stateCode;
        amberResponse.countryCode = countryCode;
        amberResponse.postalCode = postalCode;
        amberResponse.email = email;
        amberResponse.ip = ip;
      
        RestResponse response = RestContext.response;
        response.addHeader('Location', URL.getSalesforceBaseUrl().toExternalForm() + '/AmberRoadRequest__c/' + amberRoadRequest.id);
        response.addHeader('Content-Type','application/json');
        response.statusCode = 201;
        response.responseBody = Blob.valueOf(JSON.serialize(amberResponse));
    }
}